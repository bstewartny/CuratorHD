    //
//  FeedPickerViewController.m
//  Untitled
//
//  Created by Robert Stewart on 5/26/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FeedPickerViewController.h"
#import "NewsletterSection.h"
#import "Feed.h"

@implementation FeedPickerViewController
@synthesize feeds, tableView,section,delegate;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(200.0, 300.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	if(indexPath.row==0)
	{
		cell.textLabel.text=@"(None)";
		/*if(self.section.feedName==nil || [self.section.feedName length]==0)
		{
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
		}*/
	}
	else 
	{
		Feed * feed=[feeds objectAtIndex:indexPath.row-1];

		/*if(self.section.feedName)
		{
			if([feed.name isEqualToString:self.section.feedName])
			{
				cell.accessoryType=UITableViewCellAccessoryCheckmark;
			}
		}*/
		
		cell.textLabel.text=feed.name;
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [feeds count]+1;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	if(indexPath.row==0)
	{
		self.section.feedName=nil;
	}
	else 
	{
		Feed * feed=[feeds objectAtIndex:indexPath.row-1];
		
		self.section.feedName=feed.name;
	}
	
	[aTableView reloadData];
	
	if(delegate)
	{
		[delegate didPickFeed];
	}
	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
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
	[feeds release];
	[tableView release];
	[section release];
    [super dealloc];
}


@end
