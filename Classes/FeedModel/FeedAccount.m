//
//  Account.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FeedAccount.h"
#import "FeedFetcher.h"
#import "FeedItem.h"
#import "AccountUpdater.h"
#import "InfoNgenAccountUpdater.h"
#import "GoogleAccountUpdater.h"
#import "TwitterAccountUpdater.h"
#import "FacebookAccountUpdater.h"

@implementation FeedAccount
@dynamic name,username,password,feeds,image;

- (ItemFetcher*) feedFetcher
{
	// create new fetcher for this account to get all feeds
	AccountFeedFetcher * feedFetcher=[[AccountFeedFetcher alloc] init];
	
	feedFetcher.accountName=self.name;
	
	return [feedFetcher autorelease];
}

- (BOOL) editable
{
	return NO;
}
- (void) markAsRead:(FeedItem *)item
{
	NSLog(@"FeedAccount.markAsRead");
	
	
}

- (AccountUpdater*) accountUpdater
{
	NSLog(@"FeedAccount accountUpdater: %@",self.name);
	if([self.name isEqualToString:@"InfoNgen"])
	{
		return [[[InfoNgenAccountUpdater alloc] initWithAccount:self] autorelease];
	}
	else 
	{
		if([self.name isEqualToString:@"Google Reader"])
		{
			return [[[GoogleAccountUpdater alloc] initWithAccount:self] autorelease];
		}
		else
		{
			if([self.name isEqualToString:@"Twitter"])
			{
				return [[[TwitterAccountUpdater alloc] initWithAccount:self] autorelease];
			}
			else {
				if([self.name isEqualToString:@"Facebook"])
				{
					return [[[FacebookAccountUpdater alloc] initWithAccount:self] autorelease];
				}
				
				
			}

		}
	}
	return nil;
}

- (BOOL) isValid
{
	NSLog(@"FeedAccount.isValid");
	return [[self accountUpdater] isAccountValid];
}

- (void) authorize
{
	// do any user thread authorization such as asking for oath input...
	if(![self isValid])
	{
		[[self accountUpdater] authorize];
	}
}

@end
