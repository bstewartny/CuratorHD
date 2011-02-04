//
//  TwitterPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 8/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TwitterPublishAction.h"
#import "SHKTwitter.h"
#import "FeedItem.h"
#import "SHKItem.h"
#import "UserSettings.h"
#import "FeedAccount.h"
#import "TwitterClient.h"

#define kUseTwitterAsSource YES


@implementation TwitterPublishAction

- (UIImage*)image
{
	return [UIImage imageNamed:@"twitter.png"];
}

- (NSString*)title
{
	return @"Twitter";
}

- (int)count
{
	return -1;
}

- (void) longAction:(id)sender
{
	[self retain];
	
	sendTweetButtonIndex=-1;
	newTweetButtonIndex=-1;
	retweetButtonIndex=-1;
	replyButtonIndex=-1;
	addFavoritesButtonIndex=-1;
	addSourcesButtonIndex=-1;
	addTweetToFavoritesButtonIndex=-1;
	int numButtons=0;
	
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Twitter" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	FeedItem * item=[[[UIApplication sharedApplication] delegate] currentItem];
	
	if(item)
	{
		if([item.originId isEqualToString:@"twitter"])
		{
			if([item.originUrl length]>0)
			{
				[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Reply to %@",item.originUrl]];
			
				replyButtonIndex=numButtons;
				
				numButtons++;
			}

			[actionSheet addButtonWithTitle:@"Retweet"];
			
			retweetButtonIndex=numButtons;
			
			numButtons++;
			
			[actionSheet addButtonWithTitle:@"Add tweet to favorites"];
			
			addTweetToFavoritesButtonIndex=numButtons;
			
			numButtons++;
		}
		else 
		{
			[actionSheet addButtonWithTitle:@"Share item on Twitter"];
		
			sendTweetButtonIndex=numButtons;
		
			numButtons++;
		}
	}
	
	[actionSheet addButtonWithTitle:@"Send new tweet"];
	
	newTweetButtonIndex=numButtons;
	
	numButtons++;
	
	
	if(self.isFavorite)
	{
		[actionSheet addButtonWithTitle:@"Remove icon from favorites"];
		
		addFavoritesButtonIndex=numButtons;
		
		numButtons++;
	}
	else 
	{
		[actionSheet addButtonWithTitle:@"Add icon to favorites"];
		
		addFavoritesButtonIndex=numButtons;
		
		numButtons++;
	}
	
	
	
	if(kUseTwitterAsSource)
	{
		if(self.isSource)
		{
			[actionSheet addButtonWithTitle:@"Remove icon from sources"];
			
			addSourcesButtonIndex=numButtons;
			
			numButtons++;
		}
		else 
		{
			[actionSheet addButtonWithTitle:@"Add icon to sources"];
			
			addSourcesButtonIndex=numButtons;
			
			numButtons++;
		}
	}
	
	UIView * view=[sender imageView];
	
	[actionSheet showFromRect:[view frame] inView:view animated:YES];
	
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex<0) return;
	
	if(buttonIndex==sendTweetButtonIndex)
	{
		[self sendItemAsTweet];
		return;
	}
	
	if(buttonIndex==newTweetButtonIndex)
	{
		[self composeNewTweet];
		return;
	}
	
	if(buttonIndex==retweetButtonIndex)
	{
		[self reTweet];
		return;
	}
	
	if(buttonIndex==replyButtonIndex)
	{
		[self sendReply];
		return;
	}
	
	if(buttonIndex==addTweetToFavoritesButtonIndex)
	{
		[self addTweetToFavorites];
		return;
	}
	
	if(buttonIndex==addFavoritesButtonIndex)
	{
		[self toggleFavorite];
		[self actionComplete];
		return;
	}
	
	if(buttonIndex==addSourcesButtonIndex)
	{
		[self toggleSource];
		[[[UIApplication sharedApplication] delegate] setUpSourcesView];
		
		[self actionComplete];
		
		if(self.isSource)
		{
			TwitterClient * twitter=[[[TwitterClient alloc] init] autorelease];
			
			if(![twitter isAuthorized])
			{
				[twitter promptAuthorization];
			}
		}
		
		return;
	}
}

- (void)toggleFavorite
{
	if(self.isFavorite)
	{
		self.isFavorite=NO;
	}
	else 
	{
		self.isFavorite=YES;
	}
}

-(void)toggleSource
{
	if(self.isSource)
	{
		self.isSource=NO;
		[[[UIApplication sharedApplication] delegate] deleteAccount:@"Twitter"];
	}
	else 
	{
		self.isSource=YES;
		[[[UIApplication sharedApplication] delegate] addAccount:@"Twitter" prefix:@"twitter" image:[self image] username:nil password:nil];
	}
}
- (void) action:(id)sender
{
	[self retain];
	
	[self sendItemAsTweet];
}

- (void) composeNewTweet
{
		// Share the item
	[TwitterClient shareText:@""];
}

- (void) sendItemAsTweet
{
	FeedItem * item=[[[UIApplication sharedApplication] delegate] currentItem];
	
	if(item)
	{
		if(item && [item.originId isEqualToString:@"twitter"])
		{
			[self reTweet];
		}
		else 
		{
			SHKItem *sharedItem;
			
			NSString * tweetText;
			
			NSString * selectedText=nil; //[[[UIApplication sharedApplication] delegate] shareText];
			
			if([selectedText length]>0)
			{
				tweetText=selectedText;
			}
			else 
			{
				if([item.headline length]>0)
				{
					tweetText=item.headline;
				}
				else 
				{
					tweetText=item.synopsis;
				}
			}

			if([item.url length]>0)
			{
				NSURL *url = [NSURL URLWithString:item.url];
			
				sharedItem = [SHKItem URL:url title:tweetText];
			
				//sharedItem.text=item.notes;
			}
			else 
			{
				sharedItem=[SHKItem text:tweetText];
			}

			// Share the item
			[TwitterClient shareItem:sharedItem];
		}
	}
	else	
	{
		[self composeNewTweet];
		//[self alertUserNoCurrentItem];
	}
}

- (void) sendReply
{
	FeedItem * item=[[[UIApplication sharedApplication] delegate] currentItem];
	
	if(item && [item.originId isEqualToString:@"twitter"])
	{
		// Share the item
		[TwitterClient shareText:[NSString stringWithFormat:@"@%@",item.originUrl]];
	}
	else	
	{
		[self alertUserNoCurrentItem];
	}	
}

- (void) addTweetToFavorites
{
	FeedItem * item=[[[UIApplication sharedApplication] delegate] currentItem];
	
	if(item && [item.originId isEqualToString:@"twitter"])
	{
		NSString * tweetId=[self getTweetId:item];
		if([tweetId length]>0)
		{
			SHKItem * shareItem=[[[SHKItem alloc] init] autorelease];
			
			[shareItem setCustomValue:tweetId forKey:@"id"];
			[shareItem setCustomValue:SHKFormFieldSwitchOn forKey:@"favorite"];
			[TwitterClient shareItem:shareItem];
			
			//TwitterClient * client=[[TwitterClient alloc] init];
			//[client addToFavorites:tweetId];
			//[client autorelease];
		}
		else {
			NSLog(@"Got no tweet id for item");
		}
	}
	else	
	{
		[self alertUserNoCurrentItem];
	}
	
}

- (NSString*) getTweetId:(FeedItem*)item
{
	// it should be uid, but at first we did not save as uid, so for older saved tweets, try parsing from the url...
	NSString * tweetId=item.uid;
	if([tweetId length]==0)
	{
		NSString * url=item.url;
		if(url)
		{
			// url should be in format: http://twitter.com/user/status/id
			// get last path component which should be the tweet id
			tweetId=[url lastPathComponent];
			NSLog(@"Got tweetid from URL: %@ as %@",url,tweetId);
			
		}
	}
	return tweetId;
}

- (void) reTweet
{
	UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Retweet Item" message:@"Retweet to your followers?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
	
	[alertView show];
	
	[alertView release];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1)
	{
		[self doRetweet];
	}
}

- (void) doRetweet
{
	FeedItem * item=[[[UIApplication sharedApplication] delegate] currentItem];
	
	if(item && [item.originId isEqualToString:@"twitter"])
	{
		NSString * tweetId=[self getTweetId:item];
		if([tweetId length]>0)
		{
			NSLog(@"Create SHKitem for retweet");
			SHKItem * shareItem=[[[SHKItem alloc] init] autorelease];
			
			[shareItem setCustomValue:tweetId forKey:@"id"];
			[shareItem setCustomValue:SHKFormFieldSwitchOn forKey:@"retweet"];
			NSLog(@"share item using TwitterClient");
			
			[TwitterClient shareItem:shareItem];
			
		//	TwitterClient * client=[[TwitterClient alloc] init];
		//	[client retweet:tweetId];
		//	[client autorelease];
		}
		else {
			NSLog(@"Got no tweet id for item");
		}

	}
	else	
	{
		[self alertUserNoCurrentItem];
	}
}



@end
