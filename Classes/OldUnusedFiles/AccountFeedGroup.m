//
//  AccountFeedGroup.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "AccountFeedGroup.h"
#import "SecureFeed.h"
#import "FeedAccount.h"
#import "ItemFilter.h"

@implementation AccountFeedGroup
@synthesize account;

- (void) updateWithFilter:(ItemFilter*)filter
{
	
	// get feeds and reconcile feeds with account if changed
	// verify account...
	
	if(![account isValid])
	{
		// remove all existing feeds since they are no longer valid too...
		//[self.feeds removeAllItems];
	}
	else 
	{
		BOOL feedsModified=NO;
		
		NSMutableArray * tmpFeeds=[NSMutableArray arrayWithArray:self.feeds];
		
		NSMutableArray * existingAccountFeeds = [NSMutableArray new];
		NSMutableArray * existingAccountFeedsToRemove = [NSMutableArray new];
		
		for(Feed * feed in tmpFeeds)
		{
			if([feed isKindOfClass:[SecureFeed class]])
			{
				FeedAccount * feedAccount=[feed account];
				if ([feedAccount.name isEqualToString:account.name]) 
				{
					// verify account is the same
					if ((![feedAccount.username isEqualToString:account.username]) ||
						(![feedAccount.password isEqualToString:account.password])) {
						// account is different, so we need to forget about this feed...
						[existingAccountFeedsToRemove addObject:feed];
					}
					else 
					{
						[existingAccountFeeds addObject:feed];
					}
				}
			}
		}
		
		// remove bad feeds
		for(Feed * feed in existingAccountFeedsToRemove)
		{
			[tmpFeeds removeObject:feed];
			feedsModified=YES;
		}
		
		[existingAccountFeedsToRemove release];
		
		// dynamically get account feeds (probably from network)
		NSArray * accountFeeds=[account feeds];
		
		int location=0;
		for(Feed * accountFeed in accountFeeds)
		{
			BOOL existsAlready=NO;
			// if we dont have this feed add it
			for(Feed * existingFeed in existingAccountFeeds)
			{
				if ([existingFeed.name isEqualToString:accountFeed.name]) 
				{
					// we already have this one...
					existsAlready=YES;
					break;
				}
			}
			if(!existsAlready)
			{
				if([tmpFeeds count]>location)
				{
					[tmpFeeds insertObject:accountFeed atIndex:location];
				}
				else 
				{
					[tmpFeeds addObject:accountFeed];
				}
				feedsModified=YES;
			}
			location++;
		}
		
		existingAccountFeedsToRemove = [NSMutableArray new];
		
		// remove any feeds which no longer exist (were deleted on the server)
		for(Feed * existingFeed in existingAccountFeeds)
		{
			BOOL stillExists=NO;
			for(Feed * accountFeed in accountFeeds)
			{
				if([existingFeed.name isEqualToString:accountFeed.name])
				{
					stillExists=YES;
					break;
				}
			}
			if(!stillExists)
			{
				[existingAccountFeedsToRemove addObject:existingFeed];
			}
		}
		
		for(Feed * feed in existingAccountFeedsToRemove)
		{
			[tmpFeeds removeObject:feed];
			feedsModified=YES;
		}
		
		[existingAccountFeedsToRemove release];
		
		[accountFeeds release];
		
		if(feedsModified)
		{
			NSLog(@"changing feeds from %d to %d",[self.feeds count],[tmpFeeds count]);
			self.feeds=tmpFeeds;
		}
	
		[tmpFeeds release];
	}
	
	[super updateWithFilter:filter];
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:account forKey:@"account"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super initWithCoder:decoder])
	{
		self.account=[decoder decodeObjectForKey:@"account"];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	AccountFeedGroup * copy=[super copyWithZone:zone];
	
	copy.account=[self.account copy];
	
	return copy;
}

- (void) dealloc
{
	[account release];
	[super dealloc];
}
@end
