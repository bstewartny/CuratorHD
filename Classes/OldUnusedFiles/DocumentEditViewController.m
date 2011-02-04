    //
//  DocumentEditViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DocumentEditViewController.h"
#import "SearchResult.h"
#import "DocumentTextViewController.h"
#import "DocumentWebViewController.h"
#import "TextFieldTableCell.h"
#import "TextViewTableCell.h"

@implementation DocumentEditViewController
@synthesize searchResult,editTable,imageButton,imagePickerPopover;

- (IBAction) getUrl
{
	if(self.searchResult.url && [self.searchResult.url length]>0)
	{
		DocumentWebViewController * docViewController=[[DocumentWebViewController alloc] initWithNibName:@"DocumentWebView" bundle:nil];
		
		docViewController.searchResult=self.searchResult;
		
		UINavigationController * navController=(UINavigationController*)[self parentViewController];
		
		[navController pushViewController:docViewController animated:YES];
		[docViewController release];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (IBAction) chooseImage
{
	UIImagePickerController * picker=[[UIImagePickerController alloc] init];
	
	//picker.allowsImageEditing = YES;
	picker.allowsEditing = YES;
	
	picker.delegate=self;
	
	//picker.navigationBar.topItem.title=@"Choose Logo Image";
	
	//picker.title=@"Choose Logo Image";
	
	
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
}


- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	
    // Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imagePickerPopover dismissPopoverAnimated:YES];
	//[imagePickerPopover release];
	
	self.searchResult.image=image;
	
	[self.editTable reloadData];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    //[picker dismissModalViewControllerAnimated:YES];
    [imagePickerPopover dismissPopoverAnimated:YES];
	//[imagePickerPopover release];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {
	[textView resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.searchResult.headline=textField.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if(textView.tag==kCommentsSection)
	{
		self.searchResult.notes=textView.text;
	}
	if(textView.tag==kSynopsisSection)
	{
		self.searchResult.synopsis=textView.text;
	}
}

/*- (IBAction) getText
{
	// get javascript file from bundle...
	
	NSString * path=[[NSBundle mainBundle] pathForResource:@"readability" ofType:@"js"];
	
	if (path) {
		NSString *javascript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		
		if(javascript)
		{
			// insert javascript functions into the document
			[self getString:javascript];
			
			NSString * text=[self getString:@"readability.extractArticleText()"];
			
			text=[self flattenHTML:text];
			
			NSLog(text);
			
			// render extracted text in scrollable text view and allow user to select portions of the text for the synopsis
			
			DocumentTextViewController * textController=[[DocumentTextViewController alloc] initWithNibName:@"DocumentTextView" bundle:nil];
			
			textController.searchResult=self.searchResult;
			textController.text=text;
			
			UINavigationController * navController=(UINavigationController*)[self parentViewController];
			
			[navController pushViewController:textController animated:YES];
			[textController release];
		}
	}
}*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"documentEditViewController.viewWillAppear");

	//self.imageView.image=searchResult.image;
	//self.synopsisTextView.text=searchResult.synopsis;
	NSLog(@"calling reloaddata");
	[self.editTable reloadData];
	
	[super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSLog(@"numberOfSectionsInTableView");
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
    
	NSLog(@"cellForRowAtIndexPath");
	
	switch(indexPath.section)
	{
		case kHeadlineSection:
		{
			TextFieldTableCell * textFormCell=[[[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
			textFormCell.textField.text=self.searchResult.headline;
			textFormCell.textField.delegate=self;
			textFormCell.textField.returnKeyType=UIReturnKeyDone;
			cell=textFormCell;
		}
		break;
		case kUrlSection:
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			cell.textLabel.text = self.searchResult.url;
		}
		break;
		case kSynopsisSection:	
		{
			TextViewTableCell * textViewCell=[[[TextViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
			
			textViewCell.textView.text=self.searchResult.synopsis;
			textViewCell.textView.tag=kSynopsisSection;
			textViewCell.textView.delegate=self;
			
			cell=textViewCell;
		}
			break;
		case kCommentsSection:
		{
			TextViewTableCell * textViewCell=[[[TextViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
			
			textViewCell.textView.text=self.searchResult.notes;
			textViewCell.textView.tag=kCommentsSection;
			textViewCell.textView.delegate=self;
			
			cell=textViewCell;
		}
			break;
		case kImageSection:
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil] autorelease];
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			
			if(self.searchResult.image)
			{
				//cell.imageView.image=self.searchResult.image;
				//cell.imageView.layer.masksToBounds=YES;
				//cell.imageView.layer.cornerRadius=10.0;
				
				UIButton * button=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
				button.frame=CGRectMake(10,10,self.searchResult.image.size.width,self.searchResult.image.size.height);
				[button setBackgroundImage:self.searchResult.image forState:UIControlStateNormal];
				
				[button addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
				
				//button.frame=CGRectMake(10, 10, 80, 80);
				//[button setTitle:@"Add Image" forState:UIControlStateNormal];
				//[cell addSubview:button];
				[cell.contentView addSubview:button];
				
			}
			else
			{
				UIButton * button=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
				button.frame=CGRectMake(10, 10, 80, 80);
				[button setTitle:@"Add Image" forState:UIControlStateNormal];
				
				[button addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
				
				//[cell addSubview:button];
				[cell.contentView addSubview:button];
				//[cell.contentView addSubView:button];
				//[cell.imageView addSubview:button];
				//[button release];
			}
			break;
		}
	}
		 
	return cell;
}


- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet:willDismissWithButtonIndex %d",buttonIndex);
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
	{
		// choose existing image
		
		// get image view cell
		UITableViewCell * cell=[self.editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kImageRow inSection:kImageSection]];
		
		// get image button
		
		[self addImage:cell.contentView];
	}
	if(buttonIndex==1)
	{
		// delete image
		self.searchResult.image=nil;
		[self.editTable reloadData];
	}
}
- (void) imageTouched:(id)sender
{
	UIView * button=(UIView*)sender;
	
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	[actionSheet addButtonWithTitle:@"Choose Existing Image"];
	[actionSheet addButtonWithTitle:@"Delete Image"];
	
	[actionSheet showInView:self.view];
	
	[actionSheet release];
}




- (void) addImage:(id)sender
{
	UIImagePickerController * picker=[[UIImagePickerController alloc] init];
	
	//picker.allowsImageEditing = YES;
	picker.allowsEditing = YES;
	
	picker.delegate=self;
	
	//picker.navigationBar.topItem.title=@"Choose Logo Image";
	
	//picker.title=@"Choose Logo Image";
	
	
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
	
	UIView * button=(UIView*)sender;
	
	[popover presentPopoverFromRect:[button convertRect:button.frame toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	
	//[popover presentPopoverFromBarButtonItem:imageButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	//[popoverController presentPopoverFromBarButtonItem:sender  permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	
	[picker release];
	
	[popover release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"numberOfRowsInSection");
	
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case kHeadlineSection:
			return @"Headline";
		case kUrlSection:
			return @"Link";
		case kSynopsisSection:
			return @"Synopsis";
		case kCommentsSection:
			return @"Comments";
		case kImageSection:
			return @"Image";
	}
	return nil;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	switch(indexPath.section)
	{
		case kSynopsisSection:
			return 220.0;
		case kCommentsSection:
			return 220.0;
		case kImageSection:
			if(self.searchResult.image)
			{
				return self.searchResult.image.size.height + 20.0;
			}
			else {
				return 100.0;
			}

	}
	return 40.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.section==kUrlSection && indexPath.row==kUrlRow)
	{
		// open page
		[self getUrl];
	}
	//if(indexPath.section==kImageSection && indexPath.row==kImageRow)
	//{
	//	[self chooseImage];
	//}
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"editingStyleForRowAtIndexPath");
	
	/*if(indexPath.section==kImageSection && indexPath.row==kImageRow)
	{
		if(self.searchResult.image)
		{
			return YES;
		}
		else {
			return NO;
		}
		
	}
	else 
	{*/
		return NO;
	//}
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"editingStyleForRowAtIndexPath");
	
	/*if(indexPath.section==kImageSection && indexPath.row==kImageRow)
	{
		if(self.searchResult.image)
		{
			return  UITableViewCellEditingStyleDelete;
		}
		else {
			return UITableViewCellEditingStyleNone;
		}
		
	}
	else 
	{*/
		return  UITableViewCellEditingStyleNone;
	//}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"commitEditingStyle");
	/*if(indexPath.section==kImageSection && indexPath.row==kImageRow)
	{
		// user deleted the image...
		if(self.searchResult.image)
		{
			self.searchResult.image=nil; // should release it here...
			
			
			[self.editTable reloadData];
			//[self.settingsTable  performSelector:@selector(reloadData) withObject:nil afterDelay:1];
		}
	}*/
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
	[searchResult release];
		[editTable release];
	[imageButton release];
	[imagePickerPopover release];
    [super dealloc];
}


@end
