    //
//  FavoritesViewController.m
//  Untitled
//
//  Created by Robert Stewart on 4/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FavoritesViewController.h"
#import "DocumentWebViewController.h"
#import "FeedItem.h"
#import "Favorites.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterAddItemViewController.h"

@implementation FavoritesViewController
@synthesize favorites,favoritesTable,dateFormatter,addItemPopoverController,addItemViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy h:mm"];
	self.dateFormatter=format;
	[format release];
	
	self.title=@"Favorites";
	self.navigationItem.title=@"My Favorites";
    
	// create a standard "edit" button
	UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc] init];
	
	rightButtonItem.title=@"Edit";
	rightButtonItem.target=self;
	rightButtonItem.action=@selector(toggleEditPage:) ;
	rightButtonItem.style = UIBarButtonItemStyleBordered;
	
	self.navigationItem.rightBarButtonItem=rightButtonItem;
	
	[rightButtonItem release];
	
	
	
	[super viewDidLoad];
}

- (IBAction) toggleEditPage:(id)sender
{
	UIBarButtonItem * buttonItem=(UIBarButtonItem*)sender;
	
	if(self.favoritesTable.editing)
	{
		//[self deleteSelectedRows];
		
		[self.favoritesTable setEditing:NO animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleBordered;
		buttonItem.title=@"Edit";
	}
	else
	{
		[self.favoritesTable setEditing:YES animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleDone;
		buttonItem.title=@"Done";
	}
}
 
-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath 
{
	if(tableView.editing) 
	{
		return YES;
	}
	else
	{
		return NO;
	}
} 


- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}


- (void)tableView:(UITableView*)tableView 
moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
	  toIndexPath:(NSIndexPath*)toIndexPath
{
	
	NSUInteger fromRow=[fromIndexPath row];
	NSUInteger toRow=[toIndexPath row];
	
	FeedItem * item=[[self.favorites.items objectAtIndex:fromRow] retain];
	
	[self.favorites.items removeObjectAtIndex:fromRow];
	[self.favorites.items insertObject:item atIndex:toRow];
	[item release];
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	FeedItem * item=[self.favorites.items objectAtIndex:indexPath.row];
	
	[self.favorites removeItem:item];
	
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
	
	return UITableViewCellEditingStyleDelete;
	
	//return 3; // style value for multi-select delete checkboxes
	//return UITableViewCellEditingStyleDelete;
}

- (void) viewDidAppear:(BOOL)animated
{
	[self.favoritesTable reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing) 
	{
		return;
	}
	
	FeedItem * item=[self.favorites.items objectAtIndex:indexPath.row];
	
	// show search result...
	if(item.url && [item.url length]>0)
	{
		NSLog(@"Opening url...");
		
		DocumentWebViewController * docViewController=[[DocumentWebViewController alloc] initWithNibName:@"DocumentWebView" bundle:nil];
		
		docViewController.item=item;
		
		[self.navigationController pushViewController:docViewController animated:YES];
		
		[docViewController release];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * headline_identifier=@"headlineIdentifier";
	 
	UITableViewCell * cell;
	
	 
	cell=[tableView dequeueReusableCellWithIdentifier:headline_identifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:headline_identifier] autorelease];
		//cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
	}
	
	FeedItem * item=[self.favorites.items objectAtIndex:indexPath.row];
	
	UIButton * addButton=[UIButton buttonWithType:UIButtonTypeContactAdd];
	addButton.tag=indexPath.row;
	[addButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside]; 
	cell.accessoryView=addButton;
	
	
	
	cell.textLabel.text=item.headline;
	cell.textLabel.textColor=[[[UIApplication sharedApplication] delegate] headlineColor];
	
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
	FeedItem * item=[self.favorites.items objectAtIndex:[sender tag]];
	
	if(addItemViewController==nil)
	{
		addItemViewController=[[NewsletterAddItemViewController alloc] initWithNibName:@"NewsletterAddItemView" bundle:nil];
		addItemPopoverController=[[UIPopoverController alloc] initWithContentViewController:addItemViewController];
	}
	
	addItemViewController.item=item;
	addItemViewController.newsletters=[[[UIApplication sharedApplication] delegate] newsletters];
	
	[addItemPopoverController presentPopoverFromRect:CGRectMake(5, 5, 5, 5) inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.favorites.items count];
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
	[favorites release];
	[addItemPopoverController release];
	[addItemViewController release];
	[favoritesTable release];
	[dateFormatter release];
    [super dealloc];
}


@end
