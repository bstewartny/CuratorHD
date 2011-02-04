//
//  PagesViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/2/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NewslettersViewController.h"
#import "Newsletter.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "NewsletterSectionsViewController.h"
#import "SavedSearchesViewController.h"

@implementation NewslettersViewController
@synthesize newsletters,newslettersTable,editButton,addButton;

- (void)viewWillAppear:(BOOL)animated
{
	[newslettersTable reloadData];
	
	[super viewWillAppear:animated];
}

-(IBAction) toggleEditMode
{
	if(self.newslettersTable.editing)
	{
		[self.newslettersTable setEditing:NO animated:YES];
		self.editButton.style=UIBarButtonItemStyleBordered;
		self.editButton.title=@"Edit";
		self.addButton.enabled=YES;
	}
	else
	{
		[self.newslettersTable setEditing:YES animated:YES];
		self.editButton.style=UIBarButtonItemStyleDone;
		self.editButton.title=@"Done";
		self.addButton.enabled=NO;
	}
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{    
	return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
	
	return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSUInteger row=[indexPath	row];
	
	Newsletter * newsletter=[[self.newsletters objectAtIndex:row] retain];
	
	[self.newsletters removeObjectAtIndex:row];
	
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	[delegate deleteNewsletter:newsletter];
	
	[newsletter release];
}

- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return NO;
}

- (IBAction) newNewsletter
{
	Newsletter  * newNewsletter=[[Newsletter alloc] initWithName:@"Untitled"];
	
	[self.newsletters addObject:newNewsletter];

	[newNewsletter release];
	
	[newslettersTable reloadData];
}

// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [newsletters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
    // Get the object to display and set the value in the cell.
    Newsletter * newsletter=[newsletters objectAtIndex:indexPath.row];
	
	cell.textLabel.text = newsletter.name;
	
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Newsletter * newsletter=[self.newsletters objectAtIndex:indexPath.row];
	
	AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	[delegate setCurrentNewsletter:newsletter];

	NewsletterSectionsViewController * sectionsController=[[NewsletterSectionsViewController alloc] initWithNibName:@"NewsletterSectionsView" bundle:nil];
	
	sectionsController.newsletter=newsletter;
	
	UINavigationController * nav = (UINavigationController*)[self parentViewController];
	
	[nav pushViewController:sectionsController animated:YES];
	
	[sectionsController release];
}

- (void)dealloc {
	[newsletters release];
	[newslettersTable release];
	[editButton release];
	[addButton release];
    [super dealloc];
}

@end
