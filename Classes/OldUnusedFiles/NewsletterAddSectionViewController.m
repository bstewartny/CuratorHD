    //
//  NewsletterAddSectionViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterAddSectionViewController.h"
#import "Feed.h"
#import "NewsletterSection.h"
#import "Newsletter.h"
//#import "AppDelegate.h"
#import "NewsletterBaseViewController.h"

@implementation NewsletterAddSectionViewController
@synthesize sectionsTable,newsletter ,feeds,newsletterDelegate;

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
    
	Feed * feed=[feeds objectAtIndex:indexPath.row];
	
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	 
	for (int i=0; i<[self.newsletter.sections count]; i++) {
		NewsletterSection * section=[self.newsletter sorsections objectAtIndex:i];
		if([section.feedName isEqualToString:feed.name])
		{
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
			break;
		}
	}
	
	cell.textLabel.text = feed.name;
	
	if(feed.image)
	{
		cell.imageView.image=feed.image;
	}
	
	return cell;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [feeds count];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Feed * feed=[feeds objectAtIndex:indexPath.row];
	
	for (int i=0; i<[self.newsletter.sections count]; i++) {
		NewsletterSection * section=[self.newsletter.sections objectAtIndex:i];
		if([section.feedName isEqualToString:feed.name])
		{
			[self.newsletter.sections removeObjectAtIndex:i];
			
			[aTableView reloadData];
	
			[newsletterDelegate renderNewsletter];
			
			return; // already added... so remove it...?
		}
	}
	
	NewsletterSection * section=[[NewsletterSection alloc] init];
	
	section.feedName=feed.name;
	section.name=feed.name;
	
	[self.newsletter.sections addObject:section];
	
	[section release];
	
	[aTableView reloadData];
	
	[newsletterDelegate renderNewsletter];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[sectionsTable release];
	[newsletter release];
	[feeds release];
	[newsletterDelegate release];
    [super dealloc];
}



@end
