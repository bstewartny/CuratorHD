//
//  FacebookPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 8/20/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FacebookPublishAction.h"
#import "SHKFacebook.h"
#import "FeedItem.h"
#import "SHKItem.h"
#import "FacebookClient.h"

@implementation FacebookPublishAction

- (UIImage*)image
{
	return [UIImage imageNamed:@"facebook.png"];
}

- (NSString*)title
{
	return @"Facebook";
}

- (int)count
{
	return -1;
}
- (void) longAction:(id)sender
{
	[self retain];
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Facebook" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	[actionSheet addButtonWithTitle:@"Share item on Facebook"];
	if(self.isFavorite)
	{
		[actionSheet addButtonWithTitle:@"Remove icon from favorites"];
	}
	else 
	{
		[actionSheet addButtonWithTitle:@"Add icon to favorites"];
	}
	
	if(self.isSource)
	{
		[actionSheet addButtonWithTitle:@"Remove icon from sources"];
	}
	else 
	{
		[actionSheet addButtonWithTitle:@"Add icon to sources"];
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
		return;
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
		return;
	}
	
	if(buttonIndex==2)
	{
		[self toggleSource];
		[[[UIApplication sharedApplication] delegate] setUpSourcesView];
		[self actionComplete];
		
		if(self.isSource)
		{
			FacebookClient * facebook=[[[FacebookClient alloc] init] autorelease];
			
			if(![facebook isAuthorized])
			{
				[facebook promptAuthorization];
			}
		}
		
		
		return;
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
		[SHKFacebook shareItem:sharedItem];
	}
	else	
	{
		[self alertUserNoCurrentItem];
	}
}

-(void)toggleSource
{
	if(self.isSource)
	{
		self.isSource=NO;
		[[[UIApplication sharedApplication] delegate] deleteAccount:@"Facebook"];
	}
	else 
	{
		self.isSource=YES;
		[[[UIApplication sharedApplication] delegate] addAccount:@"Facebook" prefix:@"facebook" image:[self image] username:nil password:nil];
	}
}



@end
