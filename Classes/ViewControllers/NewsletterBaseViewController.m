    //
//  NewsletterBaseViewController.m
//  Untitled
//
//  Created by Robert Stewart on 3/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterBaseViewController.h"
#import "Newsletter.h"

@implementation NewsletterBaseViewController
@synthesize newsletter;

- (void) renderNewsletter
{
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
	//NSLog(@"NewsletterBaseViewController.dealloc");
	[newsletter release];
    [super dealloc];
}


@end
