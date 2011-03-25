    //
//  NewsletterBaseViewController.m
//  Untitled
//
//  Created by Robert Stewart on 3/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterBaseViewController.h"
#import "Newsletter.h"
#import "NewsletterSection.h"
#import "NewsletterItem.h"
#import "Summarizer.h"
#import "MarkupStripper.h"

@implementation NewsletterBaseViewController
@synthesize newsletter;

- (void) renderNewsletter
{
}

- (IBAction) composeTouch:(id)sender
{
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Adjust Synopsis Length" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete All Synopsis" otherButtonTitles:@"Use original text", @"Shorten to 50 words",@"Shorten to 100 words",@"Shorten to 200 words",nil];
	actionSheet.tag=kAdjustSynopsisActionSheet;
	[actionSheet showFromBarButtonItem:sender animated:YES];
	
	[actionSheet release];
}

- (void) deleteAllSynopsis
{
	// prompt to be sure...
	for(NewsletterSection * section in self.newsletter.sections)
	{
		for(NewsletterItem * item in section.items)
		{
			item.synopsis=nil;
		}
	}
}

- (void) replaceAllOriginalSynopsis
{
	MarkupStripper * stripper=[[MarkupStripper alloc] init];
	for(NewsletterSection * section in self.newsletter.sections)
	{
		for(NewsletterItem * item in section.items)
		{
			item.synopsis=[stripper stripMarkup:item.origSynopsis];
		}
	}
	[stripper release];
}

- (void) shortenAllSynopsis50
{
	[self shortenAllSynopsis:50];
}

- (void) shortenAllSynopsis100
{
	[self shortenAllSynopsis:100];
}

- (void) shortenAllSynopsis200
{
	[self shortenAllSynopsis:200];
}

- (void) shortenAllSynopsis:(int)maxWords
{
	for(NewsletterSection * section in self.newsletter.sections)
	{
		for(NewsletterItem * item in section.items)
		{
			item.synopsis=[Summarizer shortenToMaxWords:maxWords text:item.synopsis];
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet.tag==kAdjustSynopsisActionSheet)
	{
		if(buttonIndex<0)
		{
			return;
		}
		
		if(self.view==nil || self.view.window==nil) return;
		
		// The hud will dispable all input on the view
		HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
		
		// Add HUD to screen
		[self.view.window addSubview:HUD];
		
		// Regisete for HUD callbacks so we can remove it from the window at the right time
		HUD.delegate = self;
		
		switch(buttonIndex)
		{
			case 0: // delete
				
				HUD.labelText=@"Deleting synopsis text...";
				[HUD showWhileExecuting:@selector(deleteAllSynopsis) onTarget:self withObject:nil animated:YES];
				return;
				
			case 1:
				// original
				HUD.labelText=@"Setting original synopsis text...";
				[HUD showWhileExecuting:@selector(replaceAllOriginalSynopsis) onTarget:self withObject:nil animated:YES];
				return;
				
			case 2:  
				HUD.labelText=@"Shortening synopsis text...";
				[HUD showWhileExecuting:@selector(shortenAllSynopsis50) onTarget:self withObject:nil animated:YES];
				return;
				
			case 3:  
				HUD.labelText=@"Shortening synopsis text...";
				[HUD showWhileExecuting:@selector(shortenAllSynopsis100) onTarget:self withObject:nil animated:YES];
				return;
				
			case 4:  
				HUD.labelText=@"Shortening synopsis text...";
				[HUD showWhileExecuting:@selector(shortenAllSynopsis200) onTarget:self withObject:nil animated:YES];
				return;
		}
	}
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	NSLog(@"Hud: %@", hud);
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	
	[self.newsletter save];
	[self renderNewsletter];
}

- (void)dealloc {
	//NSLog(@"NewsletterBaseViewController.dealloc");
	[newsletter release];
    [super dealloc];
}


@end
