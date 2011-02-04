//
//  InstapaperPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 8/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "InstapaperPublishAction.h"
//#import "InstapaperClient.h"
#import "FeedAccount.h"
#import "FeedItem.h"
#import "UserSettings.h"
#import "SHKInstapaper.h"
#import "SHKItem.h"
@implementation InstapaperPublishAction

- (UIImage*)image
{
	return [UIImage imageNamed:@"instapaper.png"];
}

- (NSString*)title
{
	return @"Instapaper";
}

- (int)count
{
	return -1;
}

- (void) longAction:(id)sender
{
	[self retain];
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Instapaper" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	[actionSheet addButtonWithTitle:@"Send item to Instapaper"];
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
		if([item.url length]>0)
		{
			NSURL *url = [NSURL URLWithString:item.url];
			
			SHKItem *sharedItem = [SHKItem URL:url title:item.headline];
		
			// Share the item
			[SHKInstapaper shareItem:sharedItem];
		}
		else 
		{
			UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Item has no URL" message:@"Instapaper requires a URL to share." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
			[alertView show];
			[alertView release];
		}
	}
	else	
	{
		[self alertUserNoCurrentItem];
	}
}

@end
