    //
//  ActivityStatusViewController.m
//  Untitled
//
//  Created by Robert Stewart on 4/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ActivityStatusViewController.h"

@implementation ActivityStatusViewController
@synthesize activityIndicatorView,titleLabel,statusLabel;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	self.view.frame=CGRectMake(0, 0, 200, 100);
	self.view.center=[self parentViewController].view.center;
	
	self.view.backgroundColor=[UIColor grayColor];
	//self.view.alpha=0.5;
	self.view.opaque=NO;
	
	[super viewDidLoad];
}

- (void) layoutSubviews
{
	self.activityIndicatorView.frame=CGRectMake(20,20,60,60);
	self.titleLabel.frame=CGRectMake(90,20,100,20);
	self.statusLabel.frame=CGRectMake(90,45,100,20);
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
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
	[activityIndicatorView release];
	[titleLabel release];
	[statusLabel release];
    [super dealloc];
}


@end
