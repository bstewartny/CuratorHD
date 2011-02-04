//
//  RssFeedItem.m
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "RssFeedItem.h"
#import "RssFeed.h"

@implementation RssFeedItem
@dynamic feed;

- (void) markAsRead
{
	NSLog(@"RssFeedItem.markAsRead");
	if(![self.isRead boolValue])
	{
		self.isRead=[NSNumber numberWithBool:YES];
		
		@try 
		{
			[self save];
			
			// decrement unread count for the feed
			NSNumber * unreadCount=[[self feed] unreadCount];
		
			if([unreadCount intValue]>0)
			{
				NSLog(@"Decrementing unread count on feed...");
				[[self feed] setUnreadCount:[NSNumber numberWithInt:([unreadCount intValue]-1)]];
				[[self feed] save];
			}
		}
		@catch (NSException * e) 
		{
			NSLog(@"Error in RssFeedItem.markAsRead: %@",[e userInfo]);
		}
		@finally 
		{
			 
		}
		
		@try 
		{
			NSLog(@"Calling markAsRead on app delegate...");
			[[[UIApplication sharedApplication] delegate] markAsRead:self];
		}
		@catch (NSException * e) 
		{
			NSLog(@"Error in FeedAccount.markAsRead: %@",[e userInfo]);
		}
		@finally 
		{
			
		}
	}
}
@end
