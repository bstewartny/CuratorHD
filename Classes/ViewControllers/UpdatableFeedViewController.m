    //
//  UpdatableFeedViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/28/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "UpdatableFeedViewController.h"


@implementation UpdatableFeedViewController
@synthesize statusLabel,toolbar,refreshButton;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if([[[UIApplication sharedApplication] delegate] isUpdating])
	{
		[self startActivityView];
		
		[statusLabel setText:[[[UIApplication sharedApplication] delegate] statusText]];
	}
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(refreshButton)
	{
		[refreshButton setTarget:self];
		[refreshButton setAction:@selector(refreshButtonTouch:)];
	}
		 
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleUpdateStatusNotification:)
	 name:@"UpdateStatus"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleUpdateCompleteNotification:)
	 name:@"UpdateComplete"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleUpdateStartingNotification:)
	 name:@"UpdateStarting"
	 object:nil];

	if([[[UIApplication sharedApplication] delegate] isUpdating])
	{
		[self startActivityView];
		
		[statusLabel setText:[[[UIApplication sharedApplication] delegate] statusText]];
	}
}	

- (void) refreshButtonTouch:(id)sender
{
	UIBarButtonItem * button=(UIBarButtonItem*)sender;
	
	if([[[UIApplication sharedApplication] delegate] isUpdating])
	{
		[[[UIApplication sharedApplication] delegate] cancelUpdate];
	}
	else 
	{
		// start
		//[button setImage:[UIImage imageNamed:@"icon_delete.png"]];
		
		[[[UIApplication sharedApplication] delegate] update];
	}
}

-(void)handleUpdateStatusNotification:(NSNotification *)pNotification
{
	NSString * status=(NSString*)pNotification.object;
	
	[self.statusLabel performSelectorOnMainThread:@selector(setText:) withObject:status waitUntilDone:NO];
	
	[[[UIApplication sharedApplication] delegate] setStatusText:status];
} 

-(void)handleUpdateCompleteNotification:(NSNotification *)pNotification
{
	// stop activity view
	[self performSelectorOnMainThread:@selector(endActivityView) withObject:nil waitUntilDone:NO];
}

-(void)handleUpdateStartingNotification:(NSNotification *)pNotification
{
	// start activity view
	[self performSelectorOnMainThread:@selector(startActivityView) withObject:nil waitUntilDone:NO];
}

- (void) startActivityView
{
	if(refreshButton)
	{
		//[refreshButton setImage:[UIImage imageNamed:@"icon_delete.png"]];
	}
	
	if(activityIndicatorView)
	{
		activityIndicatorView.hidden=NO;
	
		[activityIndicatorView startAnimating];
	}
}

-(void)endActivityView
{
	if(refreshButton)
	{
		//[refreshButton setImage:[UIImage imageNamed:@"icon_circle_arrow_right.png"]];
	}
	
	if(activityIndicatorView)
	{
		[activityIndicatorView stopAnimating];
		activityIndicatorView.hidden=YES;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[statusLabel release];
	[toolbar release];
	[refreshButton release];
    [super dealloc];
}


@end
