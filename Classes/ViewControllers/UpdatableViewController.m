    //
//  UpdatableViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "UpdatableViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation UpdatableViewController
@synthesize activityIndicatorView,activityView,updatable;

- (BOOL) isUpdating
{
	return updating;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if(updating) return NO;
	return YES;
}

- (void) update
{
	// show activity indicator
	
	// do update on background thread
	
	if(!updating)
	{
		updating=YES;
		
		[self startActivityView];
		
		// update all the saved searches associated with this page...
		[self performSelectorInBackground:@selector(updateStart) withObject:nil];
	}
}

- (void) doUpdate
{
	// implement in subclass to do the work of update on background thread (make sync web request, etc.)
}

- (void) afterUpdate
{
	// implement in subclass to do stuff on main UI thread after update in complete, such as reload table view
}

- (void) updateStart
{
	// run end update on UI thread
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	@try 
	{
		[self doUpdate];
	}
	@catch (NSException * e) 
	{
	
	}
	@finally 
	{
	
	}
	
	app.networkActivityIndicatorVisible = NO;
	[pool drain];
	[self performSelectorOnMainThread:@selector(endUpdate) withObject:nil waitUntilDone:NO];
}

- (void) endUpdate
{
	updating=NO;
	
	// hide acitivity indicator
	[self endActivityView];
	
	[self afterUpdate];
}

- (void) startActivityView
{
	[activityView release];
	
	activityView = [[UIView alloc] initWithFrame:[[self view] bounds]];
	[activityView setBackgroundColor:[UIColor blackColor]];
	[activityView setAlpha:0.5];
	[[self view] addSubview:activityView];
	
	UIView * subView=[[UIView alloc] initWithFrame:CGRectMake(activityView.center.x-100/2, activityView.center.y-100/2, 100, 100)];
	
	[subView setBackgroundColor:[UIColor blackColor]];
	[subView setAlpha:2.10];
	
	subView.layer.cornerRadius=24;
	subView.layer.masksToBounds=YES;
	
	[activityView addSubview:subView];
	
	[activityIndicatorView release];
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	[activityIndicatorView setFrame:CGRectMake (20,20, 60, 60)];
	
	[subView addSubview:activityIndicatorView];
	
	[activityIndicatorView startAnimating];
	
	[subView release];
}

-(void)endActivityView
{
	[activityIndicatorView stopAnimating];
	[activityView removeFromSuperview];
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

- (void)dealloc 
{
	[activityIndicatorView release];
	[activityView release];
    [super dealloc];
}


@end
