//
//  EmailPublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 6/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "EmailPublishAction.h"
#import "FeedItemHTMLViewController.h"
#import "FeedItem.h"
#import "NewsletterHTMLPreviewViewController.h"
#import "ImageRepositoryClient.h"
#import "FeedItemDictionary.h"
#import "EmailHTMLRenderer.h"

@implementation EmailPublishAction
@synthesize activityIndicatorView, activityView, activityTitleLabel, activityStatusLabel, activityProgressView;

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// did user send email? if so mark last published date of newsletter to now...
	//[delegate dismissModalViewControllerAnimated:YES];
	@try 
	{
		[[[[[UIApplication sharedApplication] delegate] detailNavController] topViewController] dismissModalViewControllerAnimated:YES];
	}
	@catch (NSException * e) 
	{
	}
	@finally 
	{
	}
}

- (UIImage*)image
{
	return [UIImage imageNamed:@"mail.png"];
}

- (NSString*)title
{
	return @"email";
}

- (int)count
{
	return -1;
}

- (void) longAction:(id)sender
{
	[self retain];
	int count=0;
	
	NSString * title=@"email";
	
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
	
	
	emailLinksButtonIndex=-1;
	emailFullTextButtonIndex=-1;
		
	if(count>1)
	{
		emailLinksButtonIndex=0;
		emailFullTextButtonIndex=1;
		[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Mail %d items: links",count]];
		[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Mail %d items: full text",count]];
	}
	else 
	{
		if(count==1)
		{
			emailLinksButtonIndex=0;
			emailFullTextButtonIndex=1;
			[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Mail 1 item: link",count]];
			[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Mail 1 item: full text",count]];
		}
	}
	
	composeEmailButtonIndex=emailFullTextButtonIndex+1;
	[actionSheet addButtonWithTitle:@"Compose new email"];
	
	addFavoritesButtonIndex=composeEmailButtonIndex+1;
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
	if(buttonIndex<0) return;
	
	if(buttonIndex==composeEmailButtonIndex)
	{
		[self composeNewEmail];
		return;
	}
	if(buttonIndex==emailLinksButtonIndex)
	{
		// add items to email
		[self emailLinks];
		return;
	}
	if(buttonIndex==emailFullTextButtonIndex)
	{
		// add items to email
		[self emailFullText:YES];
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
}

- (void) action:(id)sender
{
	[self emailFullText:YES];
}

- (void) composeNewEmail
{
	// show empty email form
	[self showEmailFormWithSubject:nil andBody:nil];
}

- (NSArray*) itemsToEmail
{
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	if([selectedItems count]>0)
	{
		return selectedItems.items;
	}
	else 
	{
		return [NSArray arrayWithObject:[[[UIApplication sharedApplication] delegate] currentItem]];
	}
}

- (void) emailLinks
{
	NSArray * items=[self itemsToEmail];
	[self showEmailFormWithSubject:[self getEmailSubjectForItems:items] andBody:[self getEmailBodyForItems:items emailType:EmailTypeLinks]];
}

- (void) emailFullText:(BOOL)uploadImages
{
	NSArray * items=[self itemsToEmail];
	
	if(uploadImages && [self imageUploadRequired:items])
	{
		[self startActivityView];
		
		// update all the saved searches associated with this page...
		[self performSelectorInBackground:@selector(imageUploadStart:) withObject:items];
	}
	else 
	{
		[self showEmailFormWithSubject:[self getEmailSubjectForItems:items] andBody:[self getEmailBodyForItems:items emailType:EmailTypeText]];
	}	
}

- (NSString*) getEmailBodyForItems:(NSArray*)items emailType:(EmailType)emailType
{
	if([items count]==0)
	{
		return nil;
	}
	
	BOOL useOriginalSynopsis=NO;
	
	if([items count]==1)
	{
		useOriginalSynopsis=YES;
	}
	
	int maxSynopsisSize=0;
	
	if([items count]>1 && (emailType==EmailTypeText))
	{
		maxSynopsisSize=500;
		// make sure flattened synopsis exists for each item
		for(FeedItem * item in items)
		{
			if (item.synopsis==nil || [item.synopsis length]==0)
			{
				item.synopsis=[item.origSynopsis flattenHTML];
				[item save];
			}
		}
	}
	
	EmailHTMLRenderer * renderer=[[[EmailHTMLRenderer alloc ]initWithMaxSynopsisSize:maxSynopsisSize includeSynopsis:(emailType!=EmailTypeLinks) useOriginalSynopsis:useOriginalSynopsis embedImageData:NO] autorelease];
	
	return [renderer getHTML:items];
	
}

- (NSString*) getEmailSubjectForItems:(NSArray*)items
{
	if ([items count]==0) 
	{
		return nil;
	}
	if([items count]==1)
	{
		return [[items objectAtIndex:0] headline];
	}
	else 
	{
		NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
		[format setDateFormat:@"yyyy-MM-dd"];
		return [NSString stringWithFormat:@"Links for %@",[format stringFromDate:[NSDate date]]];
	}
}

- (void) showEmailFormWithSubject:(NSString*)subject andBody:(NSString*)body
{
	// show email client
	if ([MFMailComposeViewController canSendMail]) 
	{
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		
		picker.mailComposeDelegate = self; // <- very important step if you want feedbacks on what the user did with your email sheet
		
		if(subject)
		{
			[picker setSubject:subject];
		}	
		
		if(body)
		{
			// prefix html with a <br> so user can enter their own text/comments at the top of the email... otherwise you cant get a cursor
			
			body=[@"<BR>" stringByAppendingString:body];
			[picker setMessageBody:body isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
		}
		
		picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
		
		[[[[[UIApplication sharedApplication] delegate] detailNavController] topViewController] presentModalViewController:picker animated:YES];
		
		[picker release];
	}
	else 
	{
		UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Curator HD cannot send mail at this time.  Please verify mail settings on your iPad." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

- (BOOL) imageUploadRequired:(NSArray*)items
{
	for(FeedItem * item in items)
	{
		if(item.image)
		{
			if(item.imageUrl==nil)
			{
				return YES;
			}
		}
	}
	return NO;
}

- (void)startActivityView
{
	UIView * parentView=[[[[[UIApplication sharedApplication] delegate] detailNavController] topViewController] view];
	
	activityView = [[UIView alloc] initWithFrame:[parentView bounds]];
	[activityView setBackgroundColor:[UIColor blackColor]];
	[activityView setAlpha:0.5];
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[parentView addSubview:activityView];
	
	UIView * subView=[[UIView alloc] initWithFrame:CGRectMake(activityView.center.x-300/2, activityView.center.y-150/2, 300, 150)];
	
	[subView setBackgroundColor:[UIColor blackColor]];
	[subView setAlpha:2.10];
	
	[[subView layer] setCornerRadius:24.0f];
	[[subView layer] setMasksToBounds:YES];
	
	[activityView addSubview:subView];
	
	activityTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(110, 40, 180, 20)];
	activityStatusLabel=[[UILabel alloc] initWithFrame:CGRectMake(110, 65, 180, 20)];
	
	activityStatusLabel.textColor=[UIColor whiteColor];
	activityTitleLabel.textColor=[UIColor whiteColor];
	activityStatusLabel.backgroundColor=[UIColor clearColor];
	activityTitleLabel.backgroundColor=[UIColor clearColor];
	
	activityProgressView=[[UIProgressView alloc] initWithFrame:CGRectMake(110,95,180,20)];
	
	activityProgressView.backgroundColor=[UIColor clearColor];
	
	activityStatusLabel.text=@"";
	activityTitleLabel.text=@"";
	
	[subView addSubview:activityIndicatorView];
	[subView addSubview:activityTitleLabel];
	[subView addSubview:activityStatusLabel];
	[subView addSubview:activityProgressView];
	[activityIndicatorView setFrame:CGRectMake (20,40, 80, 80)];
	[activityIndicatorView startAnimating];
	
	[subView release];
}

-(void)endActivityView
{
	[activityIndicatorView stopAnimating];
	[activityView removeFromSuperview];
}

- (void) imageUploadStart:(NSArray*)items 
{
	// upload images if required
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[activityTitleLabel performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:NO];
	[activityStatusLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Uploading images..." waitUntilDone:NO];
	
	[self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:0.5] waitUntilDone:NO];
	
	@try 
	{
		for(FeedItem * item in items)
		{
			if(item.image)
			{
				if(item.imageUrl==nil)
				{
					item.imageUrl=[ImageRepositoryClient putImage:item.image];

					[item save];
				}
			}
		}
	}
	@catch (NSException * e) 
	{
	
	}
	@finally 
	{
	
	}
	
	[self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
	
	[pool drain];
	app.networkActivityIndicatorVisible = NO;
	[self performSelectorOnMainThread:@selector(imageUploadEnd) withObject:nil waitUntilDone:NO];
}

- (void) updateProgress:(NSNumber*) progress
{
	activityProgressView.progress=[progress floatValue];
}

- (void) imageUploadEnd
{
	[self endActivityView];
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	[self emailFullText:NO];
}

- (void) dealloc
{
	[activityIndicatorView release];
	[activityView release];
	[activityTitleLabel release];
	[activityStatusLabel release];
	[activityProgressView release];
	
	[super dealloc];
}

@end
