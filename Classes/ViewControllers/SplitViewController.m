    //
//  SplitViewController.m
//  Untitled
//
//  Created by Robert Stewart on 9/21/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "SplitViewController.h"


@implementation SplitViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(finishStartup) withObject:nil afterDelay:0.1]; 
	
	
	[[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(finishStartup) withObject:nil waitUntilDone:NO]; 
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}


@end
