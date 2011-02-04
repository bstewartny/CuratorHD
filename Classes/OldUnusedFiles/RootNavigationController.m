    //
//  RootNavigationController.m
//  Untitled
//
//  Created by Robert Stewart on 3/30/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "RootNavigationController.h"
#import "Newsletter.h"
#import "NewslettersScrollViewController.h"
#import "NewsletterViewController.h"

@implementation RootNavigationController
@synthesize navController,newsletters,savedSearches;


- (void) initWithRootViewController:(UIViewController*)viewController
{
	[super initwithr
}

- (IBAction) editNewsletter:(Newsletter*)newsletter
{
	NewsletterViewController * newsletterViewController=[[NewsletterViewController alloc] initWithNibName:@"NewsletterView" bundle:nil];

	newsletterViewController.newsletter=newsletter;
	
	[self.navController pushViewController:newsletterViewController animated:NO];
	
	[newsletterViewController release];
}

- (IBAction) deleteNewsletter:(Newsletter*)newsletter
{
	[self.newsletters removeObject:newsletter];
}

- (IBAction) newNewsletter
{
	Newsletter * newNewsletter=[[Newsletter alloc] init];
	
	[self.newsletters addObject:newNewsletter];
	
	[self editNewsletter:newNewsletter];
}

- (IBAction) viewNewsletters
{
	[self.navController popToRootViewControllerAnimated:NO];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	NewslettersScrollViewController * scrollController= (NewslettersScrollViewController*)[self.navController topViewController];
	
	scrollController.newsletters=self.newsletters;
	/*
	
	scrollController.newsletters=self.newsletters;
	
	UINavigationController * controller=[[UINavigationController alloc] initWithRootViewController:scrollController];
    
	controller.navigationBar.barStyle=UIBarStyleBlack;
	
	UIBarButtonItem *button=[[UIBarButtonItem alloc] init];
	
	button.title=@"New Newsletter";
	button.target=self;
	button.action=@selector(newNewsletter);
	
	controller.navigationBar.topItem.leftBarButtonItem=button;
	
	[button release];
	
	controller.delegate=self;
	
	self.navController=controller;
	
	[controller release];
	
	self.view=navController.view;
	
	*/
	
	//[self.view addSubview:navController.view];
	
	[super viewDidLoad];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
	[navController release];
	[newsletters release];
	[savedSearches release];
    [super dealloc];
}


@end
