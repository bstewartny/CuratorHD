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

- (void)dealloc {
	NSLog(@"NewsletterBaseViewController.dealloc");
	[newsletter release];
    [super dealloc];
}


@end
