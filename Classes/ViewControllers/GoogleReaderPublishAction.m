//
//  GoogleReaderPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 9/9/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//


#import "GoogleReaderPublishAction.h"
#import "SHKGoogleReader.h"
#import "FeedItem.h"
#import "SHKItem.h"
#import "UserSettings.h"
#import "SHK.h"

@implementation GoogleReaderPublishAction

- (UIImage*)image
{
	return [UIImage imageNamed:@"GoogleShare.png"];
}

- (NSString*)title
{
	return @"Google Reader";
}

- (int)count
{
	return -1;
}
- (void) longAction:(id)sender
{
	[self retain];
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Google Reader" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	[actionSheet addButtonWithTitle:@"Share on Google Reader"];
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
		NSURL *url = [NSURL URLWithString:item.url];
		
		SHKItem *sharedItem = [SHKItem URL:url title:item.headline];
		
		//sharedItem.image=item.image;
		//sharedItem.text=item.notes;
		
		//NSString * shareText=[[[UIApplication sharedApplication] delegate] shareText];
		
		//if(shareText)
		///{
		//	sharedItem.text=shareText;
		//}
		//else 
		//{
			sharedItem.text=item.notes;
		//}
		
		
		
		// see if user already has google reader account settings and use those instead of prompting for username/password...
		NSString * username=[UserSettings getSetting:@"googlereader.username"];
		NSString * password=[UserSettings getSetting:@"googlereader.password"];
		
		if([username length]>0)
		{
			NSString * gr_username=[SHK getAuthValueForKey:@"email" forSharer:[SHKGoogleReader sharerId]];
			if(![gr_username isEqualToString:username])
			{
				[SHK setAuthValue:username forKey:@"email" forSharer:[SHKGoogleReader sharerId]];
			}
			NSString * gr_password=[SHK getAuthValueForKey:@"password" forSharer:[SHKGoogleReader sharerId]];
			if(![gr_password isEqualToString:password])
			{
				[SHK setAuthValue:password forKey:@"password" forSharer:[SHKGoogleReader sharerId]];
			}
		}
		
		[SHKGoogleReader shareItem:sharedItem];
	}
	else	
	{
		[self alertUserNoCurrentItem];
	}
}

@end
