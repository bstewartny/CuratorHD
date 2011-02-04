    //
//  NewsletterAddItemViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/4/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterAddItemViewController.h"
#import "FeedItem.h"
#import "Newsletter.h"
#import "NewsletterSection.h"


@implementation NewsletterAddItemViewController
@synthesize tableView,newsletters,item;

// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	[tableView reloadData];
	[super viewWillAppear:animated];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.newsletters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
    
	Newsletter * newsletter=[self.newsletters objectAtIndex:indexPath.section];
	NewsletterSection * section=[newsletter.sections objectAtIndex:indexPath.row];
	
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	if([section containsItem:item])
	{
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	}
	 
	
	cell.textLabel.text = section.name;
	
	cell.detailTextLabel.text=[NSString stringWithFormat:@"%d items",[section.items count]];
	
	return cell;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[self.newsletters objectAtIndex:section] sections] count];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Newsletter * newsletter=[self.newsletters objectAtIndex:indexPath.section];
	NewsletterSection * section=[newsletter.sections objectAtIndex:indexPath.row];
	
	if([section containsItem:item])
	{
		[section removeItem:item];
	}
	else 
	{
		// add to section
		[section addItem:item];
	}
	
	[tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	Newsletter * newsletter=[self.newsletters objectAtIndex:section];
	
	return newsletter.name;	
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
	[newsletters release];
	[item release];
	[tableView release];
    [super dealloc];
}


@end
