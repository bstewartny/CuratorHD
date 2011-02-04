//
//  NewsletterPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 6/21/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterPublishAction.h"
#import "Newsletter.h"
#import "NewsletterSection.h"
#import "NewsletterItem.h"
#import "FeedItem.h"
#import "NewsletterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FeedItemDictionary.h"

@implementation NewsletterPublishAction
@synthesize newsletter;

- (UIImage*)image
{
	return [UIImage imageNamed:@"page.png"];
}

- (NSString*)title
{
	return newsletter.name;
}

- (int)count
{
	int count=0;
	
	for(NewsletterSection * section in [newsletter.sections allObjects])
	{
		count+=[section.items count];
	}
	
	return count;
}

- (void) action:(id)sender
{
	[self retain];
	int count=0;
	
	NSString * title=[NSString stringWithFormat:@"Newsletter: %@",self.newsletter.name];
	
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
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
		}
	}

	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	 
	int index=0;
	openNewsletterButtonIndex=0;
	[actionSheet addButtonWithTitle:@"Open Newsletter"];
	index++;

	int section_count=0;
	if(count>0)
	{
		if([self.newsletter.sections count]>0)
		{
			addItemsToSectionButtonIndex=index;
			for(NewsletterSection * section in self.newsletter.sortedSections)
			{
				[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Add %d to %@",count,section.name]];
				index++;
				section_count++;
				if(section_count>=5) break; // cant show too many in action sheet...
			}
		}
	
		[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Add %d to New Section...",count]];
		addItemsToNewSectionButtonIndex=index;
		index++;
	}
	else 
	{
		addItemsToSectionButtonIndex=-1;
		addItemsToNewSectionButtonIndex=-1;
	}

	addFavoritesButtonIndex=index;
	
	if(self.isFavorite)
	{
		[actionSheet addButtonWithTitle:@"Remove icon from favorites"];
	}
	else 
	{
		[actionSheet addButtonWithTitle:@"Add icon to favorites"];
	}
	
	index++;
	
	deleteNewsletterButtonIndex=index;
	
	[actionSheet addButtonWithTitle:@"Delete Newsletter"];
	
	actionSheet.destructiveButtonIndex=index;
	
	UIView * view=[sender imageView];
	
	[actionSheet showFromRect:[view frame] inView:view animated:YES];
	
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex<0) return;
	
	// open newsletter for editing
	if(buttonIndex==openNewsletterButtonIndex)
	{
		NewsletterViewController * newsletterView=[[NewsletterViewController alloc] initWithNibName:@"NewsletterView" bundle:nil];
		
		[newsletterView setViewMode:kViewModeHeadlines];
		
		newsletterView.newsletter=self.newsletter;
		newsletterView.title=self.newsletter.name;
		
		CATransition *transition = [CATransition animation];
		transition.duration = 0.5;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		transition.subtype = kCATransitionReveal;
		
		UINavigationController * navController=[[[UIApplication sharedApplication] delegate] detailNavController];
		
		[navController.view.layer addAnimation:transition forKey:nil];
		
		[navController pushViewController:newsletterView animated:NO];
		
		[newsletterView release];
		return;
	}
	
	// add items to existing section
	if(buttonIndex>=addItemsToSectionButtonIndex && buttonIndex<addItemsToNewSectionButtonIndex)
	{
		NewsletterSection * section=[[self.newsletter sortedSections] objectAtIndex:buttonIndex-1];
		
		FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
		
		if([selectedItems count]>0)
		{
			for(FeedItem * item in selectedItems.items)
			{
				[section addFeedItem:item];
				[section save];
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
				NewsletterItem * newItem=[section addFeedItem:item];
				
				[section save];
				[self actionComplete];
				return;
			}
		}
		return;
	}
	
	// add items to new section
	if(buttonIndex==addItemsToNewSectionButtonIndex)
	{
		[self addSection];
		return;
	}
	
	// add/remove icon from favorites toolbar
	if(buttonIndex==addFavoritesButtonIndex)
	{
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
	
	// delete newsletter
	if(buttonIndex==deleteNewsletterButtonIndex)
	{
		UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete '%@'",self.newsletter.name] message:[NSString stringWithFormat:@"Deleting newsletter '%@' will also delete all of its data.",self.newsletter.name] delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel",nil];
		[alertView show];
		[alertView release];
		return;
	}
}

- (BOOL) isFavorite
{
	return [self.newsletter.isFavorite boolValue];
}

- (void) setIsFavorite:(BOOL)b
{
	self.newsletter.isFavorite=[NSNumber numberWithBool:b];
	[self.newsletter save];
}

- (void) archiveNewsletter 
{
	//NSLog(@"archiveNewsletter");
	
	// set the last publish date
	/*self.newsletter.lastPublished=[NSDate date];
	
	// make a copy of the newsletter...
	Newsletter * archive=[self.newsletter copy];

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy"];

	archive.name=[archive.name stringByAppendingFormat:@" [%@]",[format stringFromDate:self.newsletter.lastPublished]];

	[format release];
	
	
	// add to newsletter archives...
	
	[[[[UIApplication sharedApplication] delegate] newsletterArchives] addObject:archive];
	
	[archive release];
	
	[self.newsletter clearAllItems];
	
	// notify of change
	[delegate publishAction];*/
}

- (void) addSection
{
	[[[UIApplication sharedApplication] delegate] addNewsletterSection:self.newsletter];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	/*if(alertView.tag==1)
	{
		UITextField * textField=[alertView viewWithTag:9001];
		
		if(textField.text && [textField.text length]>0)
		{
			NewsletterSection * newSection=[self.newsletter addSection];
			
			newSection.name=textField.text;
			
			[newSection save];
			
			FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
			
			if([selectedItems.items count]>0)
			{
				for(FeedItem * item in selectedItems.items)
				{
					[newSection addFeedItem:item];
					[newSection save];
				}
				[selectedItems removeAllItems];
			}
			else 
			{
				FeedItem * item=[[[UIApplication sharedApplication] delegate]   currentItem];
				if(item!=nil)
				{
					[newSection addFeedItem:item];
					[newSection save];
				}
			}
			[self.newsletter save];
			[self actionComplete];
		}
	}
	else 
	{*/
		if(buttonIndex==0)
		{
			[self.newsletter delete];
			[self.newsletter save];
			[self actionComplete];
		}
	//}
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView
{
	//NSLog(@"alertViewCancel");
}

- (void) dealloc
{
	//NSLog(@"NewsletterPublishAction:dealloc");
	[newsletter release];
	[super dealloc];
}
@end
