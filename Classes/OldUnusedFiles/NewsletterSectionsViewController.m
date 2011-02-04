    //
//  NewsletterSectionsViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterSectionsViewController.h"
#import "NewsletterAddSectionViewController.h"
#import "NewsletterSection.h"
#import "AppDelegate.h"
#import "Newsletter.h";

@implementation NewsletterSectionsViewController
@synthesize sectionsTable,newsletter,addButton,editButton;

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [newsletter.sections count];
}

- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return tableView.editing;
}

- (void)tableView:(UITableView*)tableView 
moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
	  toIndexPath:(NSIndexPath*)toIndexPath
{
	NSUInteger fromRow=[fromIndexPath row];
	NSUInteger toRow=[toIndexPath row];
	
	id object=[[self.newsletter.sections objectAtIndex:fromRow] retain];
	[self.newsletter.sections removeObjectAtIndex:fromRow];
	[self.newsletter.sections insertObject:object atIndex:toRow];
	[object release];
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(tableView.editing)
	{
		NSUInteger row=[indexPath	row];
		[self.newsletter.sections removeObjectAtIndex:row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
	
	if(tableView.editing) 
	{
		return YES;
	}
	else
	{
		return NO;
	}
} 

- (void)viewWillAppear:(BOOL)animated
{
	[self.sectionsTable reloadData];
	
	[super viewWillAppear:animated];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    // Get the object to display and set the value in the cell.
    NewsletterSection * section	= [newsletter.sections objectAtIndex:indexPath.row];
	
	cell.textLabel.text = section.savedSearchName;
	
    return cell;		
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// scroll to selected saved search in newsletter view
	NewsletterSection * section	= [newsletter.sections objectAtIndex:indexPath.row];
	
	AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];

	//if(delegate.tabBarController.selectedIndex==0 ||
	//   delegate.tabBarController.selectedIndex==1)
	//{
//		[delegate.tabBarController.selectedViewController scrollToSection:section.name];/
//	}
	
	//[delegate.newsletterViewController scrollToSection:section.name];	
}

- (IBAction) addSavedSearch
{
	NewsletterAddSectionViewController * sectionsController=[[NewsletterAddSectionViewController alloc] initWithNibName:@"NewsletterAddSectionView" bundle:nil];
	
	sectionsController.newsletter=self.newsletter;
	
	AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	sectionsController.savedSearches=delegate.savedSearches;
	
	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	
	[navController pushViewController:sectionsController animated:YES];
	
	navController.navigationBar.topItem.title=@"Add Saved Search";
	
	[sectionsController release];
}


-(IBAction) toggleEditMode
{
	if(self.sectionsTable.editing)
	{
		[self.sectionsTable setEditing:NO animated:YES];
		self.editButton.style=UIBarButtonItemStyleBordered;
		self.editButton.title=@"Edit";
		self.addButton.enabled=YES;
		
		AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
		
		[delegate renderNewsletter];	
	}
	else
	{
		[self.sectionsTable setEditing:YES animated:YES];
		self.editButton.style=UIBarButtonItemStyleDone;
		self.editButton.title=@"Done";
		self.addButton.enabled=NO;
	}
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
	[addButton release];
	[editButton release];
    [super dealloc];
}


@end
