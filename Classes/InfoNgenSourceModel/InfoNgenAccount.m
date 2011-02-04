//
//  InfoNgenAccount.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "InfoNgenAccount.h"
#import "InfoNgenLoginTicket.h"
#import "InfoNgenSearchClient.h"

@implementation InfoNgenAccount

- (BOOL) isValid
{
	InfoNgenLoginTicket * ticket=[[InfoNgenLoginTicket alloc] initWithAccount:self useCachedCookie:NO];
	
	if(ticket.ticket==nil || [ticket.ticket length]==0)
	{
		[ticket release];
		return NO;
	}
	else 
	{
		[ticket release];
		return YES;
	}
}

- (NSArray*) feeds
{
	InfoNgenSearchClient * client=[[InfoNgenSearchClient alloc] initWithServer:kDefaultInfoNgenServerURL account:self];
	
	NSArray * feeds=[client getSavedSearchesForAccount:self imageCache:nil];
	
	[client release];
	
	return feeds;
}

@end
