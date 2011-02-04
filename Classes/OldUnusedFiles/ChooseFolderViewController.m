    //
//  ChooseFolderViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ChooseFolderViewController.h"
#import "Feed.h"
#import "FeedItem.h"

@implementation ChooseFolderViewController
@synthesize folders,delegate,tableView,item;


- (void)viewDidLoad {
	
	self.title=@"Add Item to Folder";
	
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"cellForRowAtIndexPath");
	
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1	reuseIdentifier:nil] autorelease];
	
	if(indexPath.row < [folders count])
	{
		Feed * folder=[folders objectAtIndex:indexPath.row];
		cell.textLabel.text=folder.name;
		if([folder containsItem:item])
		{
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
		}
		cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",[folder.items count]];
		cell.imageView.image=[UIImage imageNamed:@"folder.png"];
	}
	else 
	{
		cell.textLabel.text=@"Add New Folder...";
		cell.imageView.image=[UIImage imageNamed:@"folder_add.png"];
	}

	return cell;
}

/*- (void) viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}*/
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView reloadData];
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row<[folders count])
	{
		Feed * folder=[folders objectAtIndex:indexPath.row];
	
		if(![folder containsItem:item])
		{
			[folder addItem:item];
			[delegate publishAction];
		}		
	}
	else 
	{
		// add new folder...
		[delegate addFolderFromPopover];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
	
	// dynamic size based on how many folders
	CGFloat height=220; // min
	
	height=44 + (44 * ([folders count] + 1));
	
	if(height>600)
	{
		height=600; //max
	}
	
	
    return CGSizeMake(320.0, height);
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"numberOfRowsInSection");
	NSInteger rows= [folders count] + 1;
	
	NSLog(@"rows=%d",rows);
	return rows;
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
	[folders release];
	[item release];
	[tableView release];
    [super dealloc];
}


@end
