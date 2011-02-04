    //
//  AddFeedViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "AddFeedViewController.h"
#import "Feed.h"
#import "GoogleReaderAccount.h"
#import "AccountFeedGroup.h"
#import "InfoNgenAccount.h"
#import "FeedAccount.h"
#import "RssFeed.h"

@implementation AddFeedViewController
@synthesize tableView,sourceType,delegate,usernameTextField,passwordTextField,urlTextField,nameTextField,segmentedControl;

- (IBAction) cancel
{
	// dismiss
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction) done
{
	// call delegate and dismiss

	//NSString * sourceType=[segmentedControl titleForSegmentAtIndex:[segmentedControl selectedSegmentIndex]];
	NSString * username=usernameTextField.text;
	NSString * password=passwordTextField.text;
	NSString * url=urlTextField.text;
	NSString * name=nameTextField.text;
	
	Feed * feed=nil;
	
	if([sourceType isEqualToString:@"Google Reader"])
	{
		if(username==nil || [username length]==0)
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No username specified" message:@"Google Reader requires a valid Google Reader username." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		id app_delegate=[[UIApplication sharedApplication] delegate];
		
		if(![app_delegate hasInternetConnection])
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"This app requires an internet connection via WiFi or cellular network to verify account info." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		GoogleReaderAccount * googleReaderAccount=[[GoogleReaderAccount alloc] initWithName:@"Google Reader" username:username password:password];
		
		if(![googleReaderAccount isValid])
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:@"Failed to validate Google Reader account.  Please verify username and password and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		AccountFeedGroup * googleReaderFeedGroup=[[AccountFeedGroup alloc] init];
		googleReaderFeedGroup.image=[UIImage imageNamed:@"GoogleReader.png"];
		googleReaderFeedGroup.account=googleReaderAccount;
		googleReaderFeedGroup.name=@"Google Reader";
		
		feed=googleReaderFeedGroup;
		
	}
	if([sourceType isEqualToString:@"InfoNgen"])
	{
		if(username==nil || [username length]==0)
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No username specified" message:@"Google Reader requires a valid Google Reader username." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		id app_delegate=[[UIApplication sharedApplication] delegate];
		
		if(![app_delegate hasInternetConnection])
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"This app requires an internet connection via WiFi or cellular network to verify account info." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		InfoNgenAccount * infoNgenAccount=[[InfoNgenAccount alloc] initWithName:@"InfoNgen" username:username password:password];
		
		if(![infoNgenAccount isValid])
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:@"Failed to validate InfoNgen account.  Please verify username and password and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		AccountFeedGroup * infoNgenFeedGroup=[[AccountFeedGroup alloc] init];
		infoNgenFeedGroup.image=[UIImage imageNamed:@"icon.png"];
		infoNgenFeedGroup.account=infoNgenAccount;
		infoNgenFeedGroup.name=@"InfoNgen";
		
		feed=infoNgenFeedGroup;
		
	}
	
	if([sourceType isEqualToString:@"RSS Feed"])
	{
		
		if(name==nil || [name length]==0)
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No name specified" message:@"Please specify a name for the RSS feed." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		if(url==nil || [url length]<12)
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No URL specified" message:@"Please specify a URL for the RSS feed." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		FeedAccount * infoNgenAccount=[[FeedAccount alloc] initWithName:name username:username password:password];
		
		RssFeed * rssFeed=[[RssFeed alloc] initWithAccount:infoNgenAccount name:name url:url];
		
		rssFeed.image=[UIImage imageNamed:@"icon_rss.png"];
		
		feed=rssFeed;
	}
	
	if([sourceType isEqualToString:@"Folder"])
	{
		//FeedAccount * infoNgenAccount=[[FeedAccount alloc] initWithName:name username:username password:password];
		
		if(name==nil || [name length]==0)
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No name specified" message:@"Please specify a name for the new folder." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			return;
		}
		
		Feed * folder=[[Feed alloc] init];
		folder.name=name;
		folder.image=[UIImage imageNamed:@"folder.png"];
		
		//RssFeed * rssFeed=[[RssFeed alloc] initWithAccount:infoNgenAccount name:name url:url];
		
		feed=folder;
	}
	
	[delegate addNewFeed:feed feedType:sourceType];

	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void) toggleSourceType:(id)sender
{
	self.sourceType=[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]];
	
	[tableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.sourceType=@"Google Reader";
}

- (UITableViewCell *) getUsernameCell
{
	static NSString * identifier=@"getUsernameCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,100,30)];
		label.text=@"Username:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(105,14,300,22)];
		textField.backgroundColor=[UIColor clearColor];
		//textField.text=self.section.name;
		//textField.clearButtonMode=UITextFieldViewModeAlways;
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		textField.keyboardType=UIKeyboardTypeEmailAddress;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		//[textField becomeFirstResponder];
		
		self.usernameTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}


- (UITableViewCell *) getNameCell
{
	static NSString * identifier=@"getNameCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,60,30)];
		label.text=@"Name:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(80,14,350,22)];
		textField.backgroundColor=[UIColor clearColor];
		//textField.text=self.section.name;
		//textField.clearButtonMode=UITextFieldViewModeAlways;
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		textField.keyboardType=UIKeyboardTypeAlphabet;
		textField.autocorrectionType=UITextAutocorrectionTypeYes;
		textField.autocapitalizationType=UITextAutocapitalizationTypeWords;
		//[textField becomeFirstResponder];
		
		self.nameTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}

- (UITableViewCell *) getUrlCell
{
	static NSString * identifier=@"getUrlCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,60,30)];
		label.text=@"URL:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(80,14,350,22)];
		textField.backgroundColor=[UIColor clearColor];
		//textField.text=self.section.name;
		//textField.clearButtonMode=UITextFieldViewModeAlways;
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		textField.keyboardType=UIKeyboardTypeAlphabet;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		//[textField becomeFirstResponder];
		
		textField.text=@"http://";
		
		self.urlTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}

- (UITableViewCell *) getPasswordCell
{
	static NSString * identifier=@"getPasswordCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,100,30)];
		label.text=@"Password:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(105,14,300,22)];
		textField.backgroundColor=[UIColor clearColor];
		
		
		//textField.text=self.section.name;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		textField.secureTextEntry=YES;
		//textField.clearButtonMode=UITextFieldViewModeAlways;
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		
		self.passwordTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
		// only need to handle changing source type...
	if(indexPath.section==0 && indexPath.row==0)
	{
		UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Choose Source Type" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Google Reader",@"InfoNgen",@"RSS Feed",@"Folder",nil];
		
		UITableViewCell * cell=[tableView cellForRowAtIndexPath:indexPath];
		
		[actionSheet showFromRect:cell.detailTextLabel.frame inView:cell.contentView animated:YES];
		
		[actionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch(buttonIndex)
	{
		case 0:
			self.sourceType=@"Google Reader";
			break;
		case 1:
			self.sourceType=@"InfoNgen";
			break;
			
		case 2:
			self.sourceType=@"RSS Feed";
			break;
			
		case 3:
			self.sourceType=@"Folder";
			break;
			
		default:
			break;
	}
	
	[self.tableView reloadData];
	
}
- (UITableViewCell *) getSourceTypeCell2
{
	static NSString * identifier=@"getSourceTypeCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		cell.textLabel.text=@"Source Type:";
		
		 ///@"Google Reader";
		//sourceTypeView=cell.contentView;
		//sourceTypeRect=cell.detailTextLabel.frame;
		
		
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		
		/*UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,145,30)];
		 label.text=@"Source Type:";
		 label.textColor=[UIColor grayColor];
		 label.font=[UIFont systemFontOfSize:18];
		 label.backgroundColor=[UIColor clearColor];
		 */
		
		/*segmentedControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Google Reader",@"InfoNgen",@"RSS Feed",@"Folder",nil]];
		segmentedControl.frame=CGRectMake(10,7,430,30);
		segmentedControl.selectedSegmentIndex=0;
		[segmentedControl addTarget:self action:@selector(toggleSourceType) forControlEvents:UIControlEventValueChanged];
		
		//[cell.contentView addSubview:label];
		[cell.contentView addSubview:segmentedControl];
		*/
		
		//[label release];
	}
	cell.detailTextLabel.text=self.sourceType;
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([sourceType isEqualToString:@"Folder"])
	{
		switch (indexPath.section) {
			case 0:
				return [self getSourceTypeCell2];
			case 1:
				return [self getNameCell];
			default:
				return nil;
		}
	}
	else 
	{
		if([sourceType isEqualToString:@"RSS Feed"])
		{
			switch (indexPath.section) {
				case 0:
					return [self getSourceTypeCell2];
				case 1:
					if(indexPath.row==0) return [self getNameCell];
					else {
						return [self getUrlCell];
					}

				case 2:
					if(indexPath.row==0) return [self getUsernameCell];
					else {
						return [self getPasswordCell];
					}
				default:
					return nil;
			}
		}
		else 
		{
			switch (indexPath.section) {
				case 0:
					return [self getSourceTypeCell2];
				case 1:
					if(indexPath.row==0) return [self getUsernameCell];
					else {
						return [self getPasswordCell];
					}
				default:
					return nil;
			}
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if([sourceType isEqualToString:@"Folder"])
	{
		switch (section) {
			case 0:
				return 1;
			case 1:
				return 1;
			
			default:
				return 0;
		}
	}
	else {
		
		
	

	if([sourceType isEqualToString:@"RSS Feed"])
	{
		switch (section) {
			case 0:
				return 1;
			case 1:
				return 2;
			case 2:
				return 2;
			default:
				return 0;
		}
	}
	else {
		switch (section) {
			case 0:
				return 1;
			case 1:
				return 2;
			default:
				return 0;
		}
	}
	if(section==0) return 2;
	return 1;	
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if([sourceType isEqualToString:@"RSS Feed"])
	{
		return 3;
	}
	else 
	{
		return 2;
	}

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
	[tableView release];
	[usernameTextField release];
	[passwordTextField release];
	[urlTextField release];
	[nameTextField release];
	[sourceType release];
	[segmentedControl release];
	
    [super dealloc];
}


@end
