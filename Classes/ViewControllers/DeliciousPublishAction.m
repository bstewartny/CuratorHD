//
//  DeliciousPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 8/20/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DeliciousPublishAction.h"
#import "SHKDelicious.h"
#import "FeedItem.h"
#import "SHKItem.h"

@implementation DeliciousPublishAction

- (UIImage*)image
{
	return [UIImage imageNamed:@"delicious.png"];
}

- (NSString*)title
{
	return @"Delicious";
}

- (int)count
{
	return -1;
}
- (void) longAction:(id)sender
{
	[self retain];
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Delicious" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	[actionSheet addButtonWithTitle:@"Bookmark on Delicious"];
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
		//{
		//	sharedItem.text=shareText;
		//}
		//else 
		//{
			sharedItem.text=item.notes;
		//}
		
		//UIImage * shareImage=[[[UIApplication sharedApplication] delegate] shareImage];
		
		//if(shareImage)
		//{
		//	sharedItem.image=shareImage;
		//	[sharedItem setShareType:SHKShareTypeImage];
		//}
		
		
		
		
		// Share the item
		[SHKDelicious shareItem:sharedItem];
	}
	else	
	{
		[self alertUserNoCurrentItem];
	}
}

@end
