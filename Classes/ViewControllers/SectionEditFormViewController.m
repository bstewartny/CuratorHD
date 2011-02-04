    //
//  SectionEditFormViewController.m
//  Untitled
//
//  Created by Robert Stewart on 5/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "SectionEditFormViewController.h"
#import "Newsletter.h"
#import "NewsletterSection.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterItemContentView.h"

@implementation SectionEditFormViewController
@synthesize section , nameTextField,descriptionTextView,delegate,tableView,feedPickerPopover,commentsTextColor,nameTextColor;

- (IBAction) cancel
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction) dismiss
{
	if(nameTextField.text && [nameTextField.text length]>0)
	{
		section.name=nameTextField.text;
		section.summary=descriptionTextView.text;
		[section save];
		if(delegate)
		{
			[delegate redraw];
		}
	}
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.nameTextColor=[UIColor blackColor];  // [NewsletterItemContentView colorWithHexString:@"339933"];
	self.commentsTextColor=[UIColor grayColor]; //  [NewsletterItemContentView colorWithHexString:@"b00027"];
}

- (UITableViewCell *) getNameCell
{
	static NSString * identifier=@"getNameCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,60,30)];
		label.text=@"Name:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(75,14,450,22)];
		textField.backgroundColor=[UIColor clearColor];
		textField.text=self.section.name;
		textField.clearButtonMode=UITextFieldViewModeAlways;
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		textField.textColor=self.nameTextColor;
		
		self.nameTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}

- (UITableViewCell *) getDescriptionCell
{
	static NSString * identifier=@"getDescriptionCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10, 100, 30)];
		label.text=@"Description:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(5,40, 490, 182)];
		textView.font=[UIFont systemFontOfSize:18];
		textView.backgroundColor=[UIColor clearColor];
		textView.textColor=self.commentsTextColor;
		
		textView.text=self.section.summary;
		self.descriptionTextView=textView;
		
		[cell.contentView addSubview:textView];
		[cell.contentView addSubview:label];
		
		[label release];
		
		[textView release];
	}
	
	
	return cell;
}
- (UITableViewCell *) getFeedsCell
{
	static NSString * identifier=@"getFeedsCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:identifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	
		cell.textLabel.text=@"Feed:";
		cell.textLabel.textColor=[UIColor grayColor];
		cell.textLabel.font=[UIFont systemFontOfSize:18];
	
		feedPickerView=cell.detailTextLabel;
	}
	
	return cell;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self.tableView reloadData];	
}

- (void) didPickFeed
{
	[self.feedPickerPopover dismissPopoverAnimated:YES];
	[self.tableView	reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0:
			return [self getNameCell];
		case 1:
			return [self getDescriptionCell];
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section==1) return 240;
	return 44;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
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
	[section  release];
	[nameTextField release];
	[descriptionTextView release];
	[delegate release];
	[tableView release];
	[feedPickerPopover release];
	[commentsTextColor release];
	[nameTextColor release];
    [super dealloc];
}


@end
