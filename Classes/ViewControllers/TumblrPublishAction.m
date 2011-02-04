//
//  TumblrPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 6/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TumblrPublishAction.h"
//#import "TumblrClient.h"
#import "FeedAccount.h"
#import "FeedItem.h"
//#import "TumblrPostViewController.h"
#import "UserSettings.h"
#import "SHKTumblr.h"
#import "SHKItem.h"
@implementation TumblrPublishAction


- (UIImage*)image
{
	return [UIImage imageNamed:@"Tumblr.png"];
}

- (NSString*)title
{
	return @"Tumblr";
}

- (int)count
{
	return -1;
}
- (void) longAction:(id)sender
{
	[self retain];
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Tumblr" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	[actionSheet addButtonWithTitle:@"Send item to Tumblr"];
	if(self.isFavorite)
	{
		[actionSheet addButtonWithTitle:@"Remove icon from favorites"];
	}
	else 
	{
		[actionSheet addButtonWithTitle:@"Add icon to favorites"];
	}
	UIView * view=[sender imageView];
	
	[actionSheet showFromRect:[view frame] inView:view animated:YES];
	
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
	{
		// add items to email
		[self action:nil];
	}
	if(buttonIndex==1)
	{
		// add to favorites or remove from favorites
		if(self.isFavorite)
		{
			self.isFavorite=NO;
		}
		else 
		{
			self.isFavorite=YES;
		}
		[self actionComplete];
	}
}
- (void) action:(id)sender
{
	[self retain];
	
	FeedItem * item=[[[UIApplication sharedApplication] delegate] currentItem];
	
	if(item)
	{
		SHKItem *sharedItem;
		if([item.url length]>0)
		{
			NSURL *url = [NSURL URLWithString:item.url];
			sharedItem = [SHKItem URL:url title:item.headline];
			sharedItem.text=item.notes;
		}
		else 
		{
			sharedItem = [SHKItem text:item.synopsis];
			sharedItem.title=item.headline;
			sharedItem.text=item.synopsis;
		}

		// Share the item
		[SHKTumblr shareItem:sharedItem];
	}
	else	
	{
		[self alertUserNoCurrentItem];
	}
}

@end
