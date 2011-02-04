//
//  FolderPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 6/21/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FolderPublishAction.h"
#import "Feed.h"
#import "Folder.h"
#import "FolderItem.h"
#import "FeedItem.h"
//#import "Favorites.h"
#import "FeedItemDictionary.h"
#import "FeedViewController.h"
#import "NoteEditFormViewController.h"

@implementation FolderPublishAction
@synthesize folder;

- (UIImage*)image
{
	return [UIImage imageNamed:@"folder.png"];
}

- (NSString*)title
{
	return folder.name;
}

- (int)count
{
	return [[folder items] count];
}
- (void) longAction:(id)sender
{
	[self retain];
	int count=0;
	
	NSString * title=[NSString stringWithFormat:@"Folder: %@",self.folder.name];
	
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	BOOL useItem=NO;
	if([selectedItems count]>0)
	{
		count=[selectedItems count];
		if([selectedItems count]>1)
		{
			title=[NSString stringWithFormat:@"You have %d selected items",[selectedItems count]];
		}
		else 
		{
			title=@"You have 1 selected item";
		}
	}
	else 
	{
		FeedItem * item=[[[UIApplication sharedApplication] delegate]   currentItem];
		
		if(item)
		{
			count=1;
			useItem=YES;
		}
	}
	
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	
	if(count>0)
	{
		if(count==1 && useItem)
		{
			[actionSheet addButtonWithTitle:@"Add item to folder"];
		}
		else 
		{
			[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Add %d to folder",count]];
		}
		addItemsButtonIndex=0;
		addNewNoteButtonIndex=1;
		showItemsButtonIndex=2;
		addFavoritesButtonIndex=3;
		deleteFolderButtonIndex=4;
	}
	else 
	{
		addItemsButtonIndex=-1;
		addNewNoteButtonIndex=0;
		showItemsButtonIndex=1;
		addFavoritesButtonIndex=2;
		deleteFolderButtonIndex=3;
	}

	[actionSheet addButtonWithTitle:@"Create new note"];
	
	[actionSheet addButtonWithTitle:@"Show folder items"];
	
	if(self.isFavorite)
	{
		[actionSheet addButtonWithTitle:@"Remove icon from favorites"];
	}
	else 
	{
		[actionSheet addButtonWithTitle:@"Add icon to favorites"];
	}
	
	[actionSheet addButtonWithTitle:@"Delete Folder"];
	
	actionSheet.destructiveButtonIndex=deleteFolderButtonIndex;
	
	UIView * view=[sender imageView];
	
	[actionSheet showFromRect:[view frame] inView:view animated:YES];
	
	[actionSheet release];
}

- (void) createNewItem
{
	// show form to enter subject and body

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex<0) return;
	
	if(buttonIndex==addItemsButtonIndex)
	{
		// add items to newsletter
		[self addItemsToFolder];
		return;
	}
	if(buttonIndex==addFavoritesButtonIndex)
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
	if(buttonIndex==showItemsButtonIndex)
	{
		// show button items
		[self showFolderItems];
		return;
	}
	if(buttonIndex==addNewNoteButtonIndex)
	{
		[self addNewNote];
		return;
	}
	if(buttonIndex==deleteFolderButtonIndex)
	{
		// delete folder
		UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete '%@'",self.folder.name] message:[NSString stringWithFormat:@"Deleting folder '%@' will also delete all of its data.",self.folder.name] delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel",nil];
		[alertView show];
		[alertView release];
	}
}

// called by DocumentEditFormViewController from addNewNote
- (void) redraw:(FeedItem*)newItem
{
	// add item to folder...
	if(newItem)
	{
		newItem.origSynopsis=newItem.synopsis;
		
		[folder addFeedItem:newItem];
	
		[folder save];
	}
	
	[self actionComplete];
}

- (void) addNewNote
{
	
	NoteEditFormViewController *controller = [[NoteEditFormViewController alloc] initWithNibName:@"NoteEditFormView" bundle:nil];
	
	TempFeedItem * newItem=[[TempFeedItem alloc] init];
	
	//newItem.image=[UIImage imageNamed:@""]; // image for note
	newItem.origin=@"Note";
	newItem.originId=@"Note";
	newItem.date=[NSDate date];
	
	controller.item=newItem;
	
	[newItem release];
	
	controller.delegate=self;
	
	[controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[controller setModalPresentationStyle:UIModalPresentationPageSheet];
	
	UIViewController * parent=[[[UIApplication sharedApplication] delegate] detailNavController];
	
	[parent presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void) showFolderItems
{
	id appDelegate=[[UIApplication sharedApplication] delegate];
	
	FeedViewController * feedView=[[FeedViewController alloc] initWithNibName:@"FeedView" bundle:nil];
	
	feedView.editable=YES;
	feedView.itemDelegate=appDelegate;
	feedView.title=folder.name;
	feedView.navigationItem.title=folder.name;
	feedView.fetcher=[folder itemFetcher];
	
	// push to navigation controller...
	[[appDelegate masterNavController] pushViewController:feedView animated:YES];
	
	[feedView release];
}

- (BOOL) isFavorite
{
	return [self.folder.isFavorite boolValue];
}

- (void) setIsFavorite:(BOOL)b
{
	self.folder.isFavorite=[NSNumber numberWithBool:b];
	[self.folder save];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
	{
		[self.folder delete];
		[self.folder save];
		[self actionComplete];
	}
}
- (void) action:(id)sender
{
	[self longAction:sender];
}
- (void) addItemsToFolder
{
	[self retain];
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	if([selectedItems count]>0)
	{
		for(FeedItem * item in selectedItems.items)
		{
			[folder addFeedItem:item];
			[folder save];
		}
		[selectedItems removeAllItems];
		[self actionComplete];
		return;
	}
	else 
	{
		FeedItem * item=[[[UIApplication sharedApplication] delegate]   currentItem];
	
		if(item)
		{
			FolderItem * newItem=[folder addFeedItem:item];
			
			[folder save];
			
			[self actionComplete];
			
			return;
		}
		else	
		{
			[self alertUserNoCurrentItem];
		}
	}
}

- (void) dealloc
{
	[folder release];
	[super dealloc];
}

@end
