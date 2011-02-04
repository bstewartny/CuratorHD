    //
//  RiverViewController.m
//  Untitled
//
//  Created by Robert Stewart on 4/26/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "RiverViewController.h"
#import "FeedItem.h"
#import "Feed.h"
#import "DocumentWebViewController.h"
#import "Favorites.h"

#import <QuartzCore/QuartzCore.h>
#import "NewsletterAddItemViewController.h"
@implementation RiverViewController
@synthesize feeds,dateFormatter,searchResults,feedsMap,resultsTable,parentNavigationController,addItemPopoverController,addItemViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy h:mm"];
	self.dateFormatter=format;
	[format release];
    
	[self setRiverResults];
	
	[super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FeedItem * item=[self.searchResults objectAtIndex:indexPath.row];
	
	// show search result...
	if(item.url && [item.url length]>0)
	{
		NSLog(@"Opening url...");
		
		DocumentWebViewController * docViewController=[[DocumentWebViewController alloc] initWithNibName:@"DocumentWebView" bundle:nil];
		
		docViewController.item=item;
		
		[self.parentNavigationController pushViewController:docViewController animated:YES];
		
		[docViewController release];
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * identifier=@"cellIdentifier";
	
	UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor=[[[UIApplication sharedApplication] delegate] headlineColor];
		[cell.imageView setImage:[UIImage imageNamed:@"star_off.png"]];
		
	}
	
	FeedItem * item=[self.searchResults objectAtIndex:indexPath.row];
	
	
	UIButton * addButton=[UIButton buttonWithType:UIButtonTypeContactAdd];
	addButton.tag=indexPath.row;
	[addButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside]; 
	cell.accessoryView=addButton;
	
	UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
	
	button.frame=CGRectMake(0,0,32,32);
	
	button.tag=indexPath.row;
	
	[cell.contentView addSubview:button];
	
	Favorites * favorites=[[[UIApplication sharedApplication] delegate] favorites];
	
	if([favorites containsItem:item])
	{
		[button setImage:[UIImage imageNamed:@"star_on.png"] forState:UIControlStateNormal];
	}
	else 
	{
		[button setImage:[UIImage imageNamed:@"star_off.png"] forState:UIControlStateNormal];
	}
	
	[button addTarget:self action:@selector(favoritesTouch:) forControlEvents:UIControlEventTouchUpInside];
	
	
	
	
	cell.textLabel.text=item.headline;
	
	NSString *dateString = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:item.date],[item relativeDateOffset]];
	
	if (item.origin && [item.origin length]>0) {
		dateString=[dateString stringByAppendingFormat:@" - %@",item.origin];
	}
	
	//Feed  * feed=[self.feedsMap objectForKey:item.headline];
	
	cell.detailTextLabel.text=dateString;//[NSString stringWithFormat:@"%@ - %@",feed.name,dateString];
	
	return cell;
	
}

- (void) add:(id)sender
{
	// show popover to select newsletter + section to add item to...
	FeedItem * item=[self.searchResults objectAtIndex:[sender tag]];
	
	 
	if(addItemViewController==nil)
	{
		addItemViewController=[[NewsletterAddItemViewController alloc] initWithNibName:@"NewsletterAddItemView" bundle:nil];
		addItemPopoverController=[[UIPopoverController alloc] initWithContentViewController:addItemViewController];
	}
	
	addItemViewController.item=item;
	addItemViewController.newsletters=[[[UIApplication sharedApplication] delegate] newsletters];
	
	[addItemPopoverController presentPopoverFromRect:CGRectMake(5, 5, 5, 5) inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	
}


- (void) favoritesTouch:(id)sender
{
	Favorites * favorites=[[[UIApplication sharedApplication] delegate] favorites];
	
	FeedItem * item=[self.searchResults objectAtIndex:[sender tag]];
	
	if([favorites containsItem:item])
	{
		[sender setImage:[UIImage imageNamed:@"star_off.png"] forState:UIControlStateNormal];
		[favorites removeItem:item];
	}
	else 
	{
		[sender setImage:[UIImage imageNamed:@"star_on.png"] forState:UIControlStateNormal];
		[favorites addItem:item];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(updating) return 0;
	
	return [self.searchResults count];
}


- (void) setRiverResults
{
	NSMutableArray * tmp=[[NSMutableArray alloc] init];
	
	NSMutableDictionary * tmpDict=[[NSMutableDictionary alloc] init];
	
	NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
	
	for(int i=0;i<[self.feeds count];i++)
	{
		Feed  * feed =[self.feeds objectAtIndex:i];
		
		for (FeedItem * item in feed.items)
		{
			// filter out duplicate items which are included in more than one saved search so they only show up in river once...
			// items with same headline get filtered out (TODO: maybe filter out by same URI as well?)
			if ([dict objectForKey:item.headline]==nil) {
				
				
				[tmp addObject:item];
				
				[dict setObject:item forKey:item.headline];
				
				[tmpDict setObject:item forKey:item.headline];
			}
		}
	}
	
	// now sort result by date in descending order...
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	
	[tmp sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[sortDescriptor release];
	
	self.searchResults=tmp;
	self.feedsMap=tmpDict;
	
	[dict release];
	[tmpDict release];
	[tmp release];
}

- (void) doUpdate
{
	for (Feed  * feed in self.feeds)
	{
		[feed update];
		
	}
	
	[self setRiverResults];
}

- (void) afterUpdate
{
	[resultsTable reloadData];
}

- (void)dealloc {
	[feeds release];
	[addItemPopoverController release];
	[addItemViewController release];
	[dateFormatter release];
	[searchResults release];
	[feedsMap release];
	[resultsTable release];
	[parentNavigationController release];
    [super dealloc];
}

@end
