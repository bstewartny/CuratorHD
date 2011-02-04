//
//  MasterViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/2/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "SavedSearchesViewController.h"
#import "MainViewController.h"

@implementation SavedSearchesViewController

@synthesize savedSearchNavController;

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
	NSLog(@"SavedSearchesViewController.viewDidLoad");
	[self.view addSubview:savedSearchNavController.view];
	[super viewDidLoad];
}
 
- (void)dealloc {
	[savedSearchNavController release];
    [super dealloc];
}

@end
