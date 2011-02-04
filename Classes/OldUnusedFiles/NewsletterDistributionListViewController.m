    //
//  NewsletterDistributionListViewController.m
//  Untitled
//
//  Created by Robert Stewart on 3/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterDistributionListViewController.h"
#import "newsletter.h"

@implementation NewsletterDistributionListViewController
@synthesize newsletter,addressTable;


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(tableView.editing)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}

- (void) edit:(id)sender
{
	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	navController.navigationBar.topItem.rightBarButtonItem.title=@"Done";
	navController.navigationBar.topItem.rightBarButtonItem.style=UIBarButtonItemStyleDone;
	navController.navigationBar.topItem.rightBarButtonItem.action=@selector(editDone:);
	[self.addressTable setEditing:YES animated:YES];
	[self.addressTable reloadData];
	
}

- (void)editDone:(id)sender
{
	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	navController.navigationBar.topItem.rightBarButtonItem.title=@"Edit";
	navController.navigationBar.topItem.rightBarButtonItem.style=UIBarButtonItemStylePlain;
	navController.navigationBar.topItem.rightBarButtonItem.action=@selector(edit:);
	[self.addressTable setEditing:NO animated:YES];
	[self.addressTable reloadData];
	
	
}

- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSLog(@"canMoveRowAtIndexPath");
	return tableView.editing;
	//return YES;
}

- (void)tableView:(UITableView*)tableView 
moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
	  toIndexPath:(NSIndexPath*)toIndexPath
{
	NSLog(@"moveRowAtIndexPath");
	NSUInteger fromRow=[fromIndexPath row];
	NSUInteger toRow=[toIndexPath row];
	
	id object=[[self.newsletter.distributionList objectAtIndex:fromRow] retain];
	[self.newsletter.distributionList removeObjectAtIndex:fromRow];
	[self.newsletter.distributionList insertObject:object atIndex:toRow];
	[object release];
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSLog(@"commitEditingStyle");
	
	if(tableView.editing)
	{
		NSUInteger row=[indexPath	row];
		[self.newsletter.distributionList removeObjectAtIndex:row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
	
	NSLog(@"canEditRowAtIndexPath");
	
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
	[self.addressTable reloadData];
	
	[super viewWillAppear:animated];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
    
	switch (indexPath.section) {
			
		case kAddressesSection:
		{
			NSString * address=[self.newsletter.distributionList objectAtIndex:indexPath.row];
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = address;
		}
			break;
		case kAddAddressSection:
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Add Email Address...";
		}
			break;
	}
	
	return cell;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case kAddressesSection:
			return [self.newsletter.distributionList count];
		case kAddAddressSection:
			return 1;
			
			
	}
	return 0;
}
/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 switch (section) 
 {
 case kSectionsSection:
 return @"Saved Searches";
 
 }
 return nil;
 }*/

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.section==kAddAddressSection)
	{
		// creating the picker
		ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
		// place the delegate of the picker to the controll
		picker.peoplePickerDelegate = self;
		
		NSNumber* emailProp = [NSNumber numberWithInt:kABPersonEmailProperty];
		picker.displayedProperties = [NSArray arrayWithObject:emailProp];
		
		// showing the picker
		[self presentModalViewController:picker animated:YES];
		// releasing
		[picker release];
		
		
		
		
		
		
		
		
		/*NewsletterAddSectionViewController * sectionsController=[[NewsletterAddSectionViewController alloc] initWithNibName:@"NewsletterAddSectionView" bundle:nil];
		
		sectionsController.newsletter=self.newsletter;
		
		AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
		
		sectionsController.savedSearches=delegate.savedSearches;
		
		UINavigationController * navController=(UINavigationController*)[self parentViewController];
		
		[navController pushViewController:sectionsController animated:YES];
		
		navController.navigationBar.topItem.title=@"Add Saved Search...";
		
		[sectionsController release];*/
	}
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    // assigning control back to the main controller
	[self dismissModalViewControllerAnimated:YES];
}

/*- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	// setting the first name
	
	NSString * name=(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	
	NSString *email = (NSString *)ABRecordCopyValue(person, kABPersonEmailProperty);
	
	// setting the last name
    //lastName.text = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);	
	
	// setting the number
	 
	//ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty);
	//number.text = (NSString*)ABMultiValueCopyValueAtIndex(multi, 0);
	
	[self.newsletter.distributionList addObject:name];
	
	[self.addressTable reloadData];
	
	
	// remove the controller
    [self dismissModalViewControllerAnimated:YES];
	
    return NO;
}*/

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
	ABMultiValueRef emails = ABRecordCopyValue(person, property);
	CFStringRef email = ABMultiValueCopyValueAtIndex(emails, identifier);
	NSLog( (NSString *) email);
	//self.receiverEmail.text = (NSString *) email;
	
	[self.newsletter.distributionList addObject:(NSString *) email];
	
	[self.addressTable reloadData];
	// remove the controller
    [self dismissModalViewControllerAnimated:YES];
	
	return NO;
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
	[newsletter release];
	[addressTable release];
    [super dealloc];
}


@end
