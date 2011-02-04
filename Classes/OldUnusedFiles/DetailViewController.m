    //
//  DetailViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DetailViewController.h"
#import "FeedItem.h"
#import "NewslettersScrollViewController.h"
#import "FeedItemHTMLViewController.h"

@implementation DetailViewController
@synthesize itemHtmlView,newslettersScrollView;

- (void) showItemHtml:(FeedItem*)item
{
	[self.navigationController popToViewController:itemHtmlView animated:NO];	
	itemHtmlView.item=item;
	[itemHtmlView renderItem];
}

- (void) showNewsletters
{
	//[self.view bringSubviewToFront:newslettersScrollView.view];

	[self.navigationController popToViewController:newslettersScrollView animated:NO];

	 
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	itemHtmlView=[[FeedItemHTMLViewController alloc] initWithNibName:@"FeedItemHTMLView" bundle:nil];
	
	newslettersScrollView=[[NewslettersScrollViewController alloc] initWithNibName:@"NewslettersScrollView" bundle:nil];
	newslettersScrollView.newsletters=[[[UIApplication sharedApplication] delegate] newsletters];
	
	[self.navigationController setViewControllers:[NSArray arrayWithObjects:itemHtmlView,newslettersScrollView,nil] animated:NO];
	
//	[self.view addSubview:itemHtmlView.view];
//	[self.view addSubview:newslettersScrollView.view];
	
//	[self.view bringSubviewToFront:newslettersScrollView.view];
	
    [super viewDidLoad];
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
	[itemHtmlView release];
	[newslettersScrollView release];
	
    [super dealloc];
}


@end
