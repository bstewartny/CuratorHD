    //
//  HomeViewItemController.m
//  Untitled
//
//  Created by Robert Stewart on 4/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "HomeViewItemController.h"
#import "FeedItem.h"
#import "DocumentWebViewController.h"
#import "AppDelegate.h"
#import "Feed.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterAddItemViewController.h"
@implementation HomeViewItemController
@synthesize nameButton,resultsTable,feed ,dateFormatter,parentNavigationController,zoomButton,parentHomeViewController,addItemPopoverController,addItemViewController;

- (IBAction) zoomButtonTouch:(id)sender
{
	
	// zoom in or zoom out...
	if(zoomedIn)
	{
		// set size to original size...
		
		// set icon to zoomed out...
		[zoomButton setImage:[UIImage imageNamed:@"icon_zoom_in.png"] forState:UIControlStateNormal];
		//zoomButton.imageView.image=[UIImage imageNamed:@"icon_zoom_in.png"];
		zoomedIn=NO;
		
		[self.parentHomeViewController zoomOut:self];
	}
	else 
	{
		// set icon to zoomed in...
		
		[zoomButton setImage:[UIImage imageNamed:@"icon_zoom_out.png"] forState:UIControlStateNormal];
		//zoomButton.imageView.image=[UIImage imageNamed:@"icon_zoom_out.png"];
		// zoom into full size
		zoomedIn=YES;
	
		[self.parentHomeViewController zoomIn:self];
		
	}
	

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy h:mm"];
	self.dateFormatter=format;
	[format release];
	
	nameButton.backgroundColor=[UIColor grayColor];
	
	self.view.backgroundColor=[UIColor grayColor];
	
	zoomButton.backgroundColor=[UIColor grayColor];
	 
	[nameButton setTitle:self.feed.name forState:UIControlStateNormal];
	[nameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	
	
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FeedItem * item=[self.feed.items objectAtIndex:indexPath.row];
	
	// show search result...
	if(item.url && [item.url length]>0)
	{
		NSLog(@"Opening url...");
		
		DocumentWebViewController * docViewController=[[DocumentWebViewController alloc] initWithNibName:@"DocumentWebView" bundle:nil];
		
		docViewController.item=item;
		
		[self.parentNavigationController pushViewController:docViewController animated:YES];
		//[self.parentViewController.parentViewController.navigationController pushViewController:docViewController animated:YES];
	
		[docViewController release];
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * identifier=@"cellIdentifier";
	static NSString * zoomedIdentifier=@"zoomedIdentifier";
	
	UITableViewCell * cell;
	
	
	if(zoomedIn)
	{
		cell=[tableView dequeueReusableCellWithIdentifier:zoomedIdentifier];
		
		if(cell==nil)
		{
			cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:zoomedIdentifier] autorelease];
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			cell.textLabel.textColor=[[[UIApplication sharedApplication] delegate] headlineColor];
			[cell.imageView setImage:[UIImage imageNamed:@"star_off.png"]];
		}
	}
	else 
	{
		cell =[tableView dequeueReusableCellWithIdentifier:identifier];
		
		if(cell==nil)
		{
			cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			cell.textLabel.textColor=[[[UIApplication sharedApplication] delegate] headlineColor];
		}
	}

	FeedItem	* item=[self.feed.items objectAtIndex:indexPath.row];
	
	if(zoomedIn)
	{
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
		
	}
	
	cell.textLabel.text=item.headline;
	
	NSString *dateString = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:item.date],[item relativeDateOffset]];
	
	if (item.origin && [item.origin length]>0) {
		dateString=[dateString stringByAppendingFormat:@" - %@",item.origin];
	}
	
	cell.detailTextLabel.text=dateString;
	
	return cell;

}

- (void) add:(id)sender
{
	// show popover to select newsletter + section to add item to...
	FeedItem * item=[self.feed.items objectAtIndex:[sender tag]];
	
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
	
	FeedItem * item=[self.feed.items objectAtIndex:[sender tag]];
	
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
	
	return [self.feed.items count];
}
 
- (void) doUpdate
{
	[self.feed update];
}

- (void) afterUpdate
{
	[resultsTable reloadData];
}

- (void)dealloc {
	[nameButton release];
	[resultsTable release];
	[addItemPopoverController release];
	[addItemViewController release];

	[feed  release];
	[dateFormatter release];
	 
	[parentNavigationController release];
	[zoomButton release];
	[parentHomeViewController release];
    [super dealloc];
}

@end
