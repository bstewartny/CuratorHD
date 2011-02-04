    //
//  NewsletterDetailViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterSettingsViewController.h"
#import "TextFieldTableCell.h"
#import "Newsletter.h"
#import "SegmentedTableCell.h"
//#import "ImagePickerViewController.h"
#import "TextViewTableCell.h"
#import "NewsletterSectionsViewController.h"
#import "NewsletterDistributionListViewController.h"
#import "AppDelegate.h"
#import "NewsletterHTMLPreviewViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation NewsletterSettingsViewController
@synthesize settingsTable,imagePickerPopover;//,toolBar,imageButton ;

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"NewsletterSettingsViewController.viewWillAppear");
	//if(self.newsletter)
	//{
	//UINavigationController * navController=(UINavigationController*)[self parentViewController];
	
	//navController.navigationBar.backItem.title=self.newsletter.name;
	//}
	UINavigationController * navController=[(AppDelegate*)[[UIApplication sharedApplication] delegate] navigationController];
	navController.navigationBar.topItem.rightBarButtonItem=nil;
	
	[settingsTable reloadData];
	
	[super viewWillAppear:animated];
}

- (void) renderNewsletter
{
	[settingsTable reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}
/*
- (IBAction) preview
{
	
	NewsletterHTMLPreviewViewController * previewController=[[NewsletterHTMLPreviewViewController alloc] initWithNibName:@"NewsletterHTMLPreviewView" bundle:nil];
	
	previewController.newsletter=self.newsletter;
	
	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	
	[navController pushViewController:previewController animated:YES];
	
	navController.navigationBar.topItem.title=@"Newsletter Preview";
	
	[previewController release];
	
}*/

/*- (IBAction) chooseImage
{
	UIImagePickerController * picker=[[UIImagePickerController alloc] init];
	
	//picker.allowsImageEditing = YES;
	picker.allowsEditing = YES;
	
	picker.delegate=self;
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	else
	{
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
		{
			picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
			
		}
		else
		{
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			}
			else 
			{
				return;
			}
		}
	}
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
	
	
	
	self.imagePickerPopover=popover;
	
	//popoverController.delegate = self;
	
	//[popover presentPopoverFromRect:CGRectMake(330.0, 470.0, 0.0, 0.0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
	
	
	[popover presentPopoverFromBarButtonItem:imageButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	//[popoverController presentPopoverFromBarButtonItem:sender  permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	
	[picker release];
	
	[popover release];
}*/

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
	self.newsletter.name=textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	[textView resignFirstResponder];
	self.newsletter.summary=textView.text;
}
- (BOOL)textViewShouldReturn:(UITextView *)textView {
	[textView resignFirstResponder];
	return YES;
}
- (void) publishTypeChanged:(id)sender{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	self.newsletter.publishType=[segmentedControl titleForSegmentAtIndex:[segmentedControl selectedSegmentIndex]];
}

- (void) emailFormatChanged:(id)sender{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	self.newsletter.emailFormat=[segmentedControl titleForSegmentAtIndex:[segmentedControl selectedSegmentIndex]];
}

- (void) rssEnabledChanged:(id)sender
{
	UISwitch * s=(UISwitch*)sender;
	
	self.newsletter.rssEnabled=s.isOn;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	switch(indexPath.section)
	{
		case kSummarySection:
			return 140.0;
			break;
		
		case kLogoImageSection:
			if(self.newsletter.logoImage)
			{
				return self.newsletter.logoImage.size.height + 20.0;
			}
			break;
	}
	return 40.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"cellForRowAtIndexPath");
	
	UITableViewCell *cell;
    
	switch (indexPath.section) {
		
		case kTitleSection:
			{
				switch (indexPath.row) {
					case kTitleRow:
					{
						TextFieldTableCell * textFormCell=[[[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
						
						textFormCell.textField.text=self.newsletter.name;
						textFormCell.textField.delegate=self;
						textFormCell.textField.keyboardType=UIKeyboardTypeDefault;
						textFormCell.textField.returnKeyType=UIReturnKeyDone;
						cell=textFormCell;
					}
					break;
				}
			}
			break;
		case kSummarySection:
		{
			switch(indexPath.row)
			{
				case kSummaryRow:
				{
					
					TextViewTableCell * textViewCell=[[[TextViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
					
					textViewCell.textView.text=self.newsletter.summary;
					textViewCell.textView.delegate=self;
					textViewCell.textView.keyboardType=UIKeyboardTypeDefault;
					textViewCell.textView.returnKeyType=UIReturnKeyDefault;
					cell=textViewCell;
				}
					break;
			}
		}
			break;
			
		case kLogoImageSection:
			{
				switch (indexPath.row) {
				 
					case kLogoImageRow:
					{
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
						//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						//cell.textLabel.text = @"Logo Image";
						if(self.newsletter.logoImage)
						{
							cell.imageView.image=self.newsletter.logoImage;
							cell.imageView.layer.masksToBounds=YES;
							cell.imageView.layer.cornerRadius=10.0;
						}
					}
					
				}
			}
			break;
		/*case kSavedSearchesSection:
		{
			switch(indexPath.row)
			{
				case kSavedSearchesRow:
				{
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					cell.textLabel.text = @"Saved Searches";
					if([self.newsletter.sections count]>0)
					{
						cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",[self.newsletter.sections count]];
					}
				}
					break;
			}
		}
			break;*/
		case kPublishingSection:
			{
				switch (indexPath.row) {
					 
					case kRssEnabledRow:
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
							
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							
							UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
							
							[mySwitch setOn:self.newsletter.rssEnabled animated:NO];
							
							[cell addSubview:mySwitch];
							cell.accessoryView = mySwitch;
							
							[(UISwitch *)cell.accessoryView addTarget:self action:@selector(rssEnabledChanged:)
													 forControlEvents:UIControlEventValueChanged];
							
							
							[mySwitch release];
							cell.textLabel.text = @"RSS Output";
						}
						break;
						
					case kEmailFormatRow:
						{
							SegmentedTableCell * segmentedCell=[[SegmentedTableCell alloc] initWithStyle:UITableViewCellStyleDefault
																						 reuseIdentifier:nil buttonNames:[NSArray arrayWithObjects:@"HTML", @"PDF", nil]];
							
							if([self.newsletter.emailFormat isEqualToString:@"PDF"])
							{
								segmentedCell.segmentedControl.selectedSegmentIndex=1;
							}
							else
							{
								segmentedCell.segmentedControl.selectedSegmentIndex=0;
							}
							
							[segmentedCell.segmentedControl addTarget:self action:@selector(emailFormatChanged:) forControlEvents:UIControlEventValueChanged];
							
							cell=segmentedCell;
							cell.textLabel.text=@"Email Format";
						}
						break;
					
					case kScheduleTypeRow:
						{
							SegmentedTableCell * segmentedCell=[[SegmentedTableCell alloc] initWithStyle:UITableViewCellStyleDefault
																						 reuseIdentifier:nil buttonNames:[NSArray arrayWithObjects:@"Preview", @"Publish", nil]];
							
							if([self.newsletter.publishType isEqualToString:@"Publish"])
							{
								segmentedCell.segmentedControl.selectedSegmentIndex=1;
							}
							else
							{
								segmentedCell.segmentedControl.selectedSegmentIndex=0;
							}
							
							[segmentedCell.segmentedControl addTarget:self action:@selector(publishTypeChanged:) forControlEvents:UIControlEventValueChanged];
							
							cell=segmentedCell;
							cell.textLabel.text=@"Publish Type";
						}
						break;
						
					case kScheduleRow:
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
							cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
							cell.textLabel.text = @"Schedule";
						}
						break;
					
					case kSubscribersRow:
						{
							
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
							cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.textLabel.text = @"Distribution List";
							if([self.newsletter.distributionList count]>0)
							{
								cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",[self.newsletter.distributionList count]];
							}
							
						}
						break;
				
				}
			}
	}
	
	return cell;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case kTitleSection:
			return 1;
		case kLogoImageSection:
			return 1;
		case kPublishingSection:
			return 5;
		//case kSavedSearchesSection:
		//	return 1;
		case kSummarySection:
			return 1;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case kTitleSection:
			return @"Title";
		case kLogoImageSection:
			return @"Logo Image";
		case kPublishingSection:
			return @"Publishing Settings";
		//case kSavedSearchesSection:
		//	return @"Saved Searches";
		case kSummarySection:
			return @"Summary";
	}
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"editingStyleForRowAtIndexPath");
	
	if(indexPath.section==kLogoImageSection && indexPath.row==kLogoImageRow)
	{
		if(self.newsletter.logoImage)
		{
			return YES;
		}
		else {
			return NO;
		}

	}
	else 
	{
		return NO;
	}

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"editingStyleForRowAtIndexPath");
	
	if(indexPath.section==kLogoImageSection && indexPath.row==kLogoImageRow)
	{
		if(self.newsletter.logoImage)
		{
			return  UITableViewCellEditingStyleDelete;
		}
		else {
			return UITableViewCellEditingStyleNone;
		}

	}
	else 
	{
		return  UITableViewCellEditingStyleNone;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"commitEditingStyle");
	if(indexPath.section==kLogoImageSection && indexPath.row==kLogoImageRow)
	{
		// user deleted the image...
		if(self.newsletter.logoImage)
		{
			self.newsletter.logoImage=nil; // should release it here...
			
			[self.settingsTable reloadData];
			//[self.settingsTable  performSelector:@selector(reloadData) withObject:nil afterDelay:1];
		}
	}
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.section==kLogoImageSection && indexPath.row==kLogoImageRow)
	{
		[self chooseImage];
	}
	
	/*if(indexPath.section==kSavedSearchesSection && indexPath.row==kSavedSearchesRow)
	{
		NewsletterSectionsViewController * sectionsController=[[NewsletterSectionsViewController alloc] initWithNibName:@"NewsletterSectionsView" bundle:nil];
		
		sectionsController.newsletter=self.newsletter;
		
		UINavigationController * navController=(UINavigationController*)[self parentViewController];
		
		[navController pushViewController:sectionsController animated:YES];
		
		navController.navigationBar.topItem.title=@"Newsletter Saved Searches";
		
		UIBarButtonItem * rightButton=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:sectionsController action:@selector(edit:)];
		
		navController.navigationBar.topItem.rightBarButtonItem=rightButton;
		
		[rightButton release];
		
		[sectionsController release];
	}*/
	
	
	if(indexPath.section==kPublishingSection && indexPath.row==kSubscribersRow)
	{
		NewsletterDistributionListViewController * distributionListController=[[NewsletterDistributionListViewController alloc] initWithNibName:@"NewsletterDistributionListView" bundle:nil];
		
		distributionListController.newsletter=self.newsletter;
		
		UINavigationController * navController=(UINavigationController*)[self parentViewController];
		
		[navController pushViewController:distributionListController animated:YES];
		
		navController.navigationBar.topItem.title=@"Newsletter Distribution List";
		
		UIBarButtonItem * rightButton=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:distributionListController action:@selector(edit:)];
		
		navController.navigationBar.topItem.rightBarButtonItem=rightButton;
		
		[rightButton release];
		
		[distributionListController release];
	}
}


- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	
    // Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imagePickerPopover dismissPopoverAnimated:YES];
	//[imagePickerPopover release];
	
	self.newsletter.logoImage=image;
	
	[self.settingsTable reloadData];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    //[picker dismissModalViewControllerAnimated:YES];
    [imagePickerPopover dismissPopoverAnimated:YES];
	//[imagePickerPopover release];
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
	[imagePickerPopover release];
	[settingsTable release];
	[super dealloc];
}


@end
