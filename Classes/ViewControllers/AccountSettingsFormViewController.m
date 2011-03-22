#import "AccountSettingsFormViewController.h"
#import "UserSettings.h"
#import "TwitterClient.h"
#import "InfoNgenLoginTicket.h"
#import "GoogleReaderClient.h"
#import <QuartzCore/QuartzCore.h>
#import "GoogleClientLogin.h"

@implementation AccountSettingsFormViewController
@synthesize delegate,twitterUsernameTextField,twitterPasswordTextField,googleReaderUsernameTextField,googleReaderPasswordTextField,infoNgenUsernameTextField,infoNgenPasswordTextField;
@synthesize doneButton;
@synthesize cancelButton,activeTextField;

- (IBAction) cancel
{
	[delegate accountSettingsDidCancel:self];
}

- (IBAction) done
{
	[self.activeTextField resignFirstResponder];
	
	[self removeAlertLabels];
	
	googleReaderUsername= googleReaderUsernameTextField.text;
	googleReaderPassword= googleReaderPasswordTextField.text;
	
	infoNgenUsername=infoNgenUsernameTextField.text;
	infoNgenPassword=infoNgenPasswordTextField.text;
	twitterUsername=twitterUsernameTextField.text;
	twitterPassword=twitterPasswordTextField.text;

	num_accounts=0;
	num_failed=0;
	num_succeeded=0;
	
	[twitterClient release];
	twitterClient=nil;
	
	[operationQueue cancelAllOperations];
	[operationQueue release];
	operationQueue=nil;
	
	if([[[UIApplication sharedApplication] delegate] hasInternetConnection])
	{
		operationQueue=[[NSOperationQueue alloc] init];
		
		operationQueue.maxConcurrentOperationCount=1;
		if([googleReaderUsernameTextField.text length]>0)
		{
			num_accounts++;
		}
		if([twitterUsernameTextField.text length]>0)
		{
			num_accounts++;
		}
		if([infoNgenUsernameTextField.text length]>0)
		{
			num_accounts++;
		}
		if([googleReaderUsernameTextField.text length]>0)
		{
			[operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(verifyGoogle) object:nil] autorelease]];
		}
		if([twitterUsernameTextField.text length]>0)
		{
			twitterClient=[[TwitterClient alloc] init];
			[self verifyTwitter];
		}
		if([infoNgenUsernameTextField.text length]>0)
		{
			[operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(verifyInfoNgen) object:nil] autorelease]];
		}
	}
	
	if(num_accounts==0)
	{
		[self close];
	}
	else 
	{
		[cancelButton setEnabled:NO];
		[doneButton setEnabled:NO];
		self.navigationItem.title=@"Verifying Accounts...";
	}
}

- (void) maybeDone
{
	[self.tableView reloadData];
	
	if(num_failed + num_succeeded >= num_accounts)
	{
		if(num_failed>0)
		{
			// tell/show user we failed and they can try again or cancel
			[cancelButton setEnabled:YES];
			[doneButton setEnabled:YES];
			
			self.navigationItem.title=@"Account Settings";
			
			UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Failed to validate accounts. Please verify username and password." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
			
			[alertView show];
			
			[alertView release];
		}
		else 
		{
			self.navigationItem.title =@"Accounts Verified";
			
			[self performSelector:@selector(close) withObject:nil afterDelay:0.1];
		}
	}
}
		 
- (void) verifyInfoNgen
{
	InfoNgenLoginTicket * ticket=[[InfoNgenLoginTicket alloc] initWithUsername:infoNgenUsernameTextField.text password:infoNgenPasswordTextField.text useCachedCookie:NO];
	
	if([ticket.ticket length]==0)
	{
		[ticket release];
		[self performSelectorOnMainThread:@selector(verifyInfoNgenFailed) withObject:nil waitUntilDone:NO];
	}
	else 
	{
		[ticket release];
		[self performSelectorOnMainThread:@selector(verifyInfoNgenSucceeded) withObject:nil waitUntilDone:NO];
	}
}

- (void) verifyTwitter
{
	twitterClient.username=twitterUsernameTextField.text;
	twitterClient.password=twitterPasswordTextField.text;
	twitterClient.verifyDelegate=self;
	[twitterClient restoreAccessToken];
	[twitterClient tokenAccess];
}

- (void)didSucceed
{
	[self performSelectorOnMainThread:@selector(verifyTwitterSucceeded) withObject:nil waitUntilDone:NO];
}

- (void)didFail
{
	[self performSelectorOnMainThread:@selector(verifyTwitterFailed) withObject:nil waitUntilDone:NO];
}

- (void) verifyGoogle
{
	NSString * authKey=[GoogleClientLogin getAuthKeyWithUsername:googleReaderUsername  andPassword:googleReaderPassword forService:@"reader" withSource:@"CuratorHD"];
	
	if([authKey length]>0)
	{
		[self performSelectorOnMainThread:@selector(verifyGoogleSucceeded) withObject:nil waitUntilDone:NO];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(verifyGoogleFailed) withObject:nil waitUntilDone:NO];
	}
}

- (void) verifyInfoNgenFailed
{
	num_failed++;
	infoNgenStatusLabel.textColor=[UIColor redColor];
	infoNgenStatusLabel.text=@"Failed!";
	[self maybeDone];
}

- (void) verifyTwitterFailed
{
	num_failed++;
	twitterStatusLabel.textColor=[UIColor redColor];
	twitterStatusLabel.text=@"Failed!";
	[self maybeDone];
}

- (void) verifyGoogleFailed
{
	num_failed++;
	googleReaderStatusLabel.textColor=[UIColor redColor];
	googleReaderStatusLabel.text=@"Failed!";
	[self maybeDone];
}

- (void) removeAlertLabels
{
	twitterStatusLabel.text=nil;
	infoNgenStatusLabel.text=nil;
	googleReaderStatusLabel.text=nil;
}

- (void) verifyInfoNgenSucceeded
{
	infoNgenStatusLabel.textColor=[UIColor colorWithRed:25.0/255.0 green:76.0/255.0 blue:127.0/255.0 alpha:1.0];
	infoNgenStatusLabel.text=@"Verfied";
	num_succeeded++;
	[self maybeDone];
}

- (void) verifyTwitterSucceeded
{
	twitterStatusLabel.textColor=[UIColor colorWithRed:25.0/255.0 green:76.0/255.0 blue:127.0/255.0 alpha:1.0];
	twitterStatusLabel.text=@"Verfied";
	num_succeeded++;
	[self maybeDone];
}

- (void) verifyGoogleSucceeded
{
	googleReaderStatusLabel.textColor=[UIColor colorWithRed:25.0/255.0 green:76.0/255.0 blue:127.0/255.0 alpha:1.0];
	googleReaderStatusLabel.text=@"Verfied";
	num_succeeded++;
	[self maybeDone];
}
		 
- (void) close
{
	// save settings
	[UserSettings saveSetting:@"googlereader.username" value:googleReaderUsername];
	
	if([googleReaderUsername length]==0)
	{
		[googleReaderPassword release];
		googleReaderPassword=nil;
	}
	
	[UserSettings saveSetting:@"googlereader.password" value:googleReaderPassword];
	[UserSettings saveSetting:@"infongen.username" value:infoNgenUsername];
	
	if([infoNgenUsername length]==0)
	{
		[infoNgenPassword release];
		infoNgenPassword=nil;
	}
	[UserSettings saveSetting:@"infongen.password" value:infoNgenPassword];
	[UserSettings saveSetting:@"twitter.username" value:twitterUsername];
	
	if([twitterUsername length]==0)
	{
		[twitterPassword release];
		twitterPassword=nil;
	}
	[UserSettings saveSetting:@"twitter.password" value:twitterPassword];
	
	[delegate accountSettingsDone:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView * v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
	v.backgroundColor=[UIColor clearColor];
	v.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	
	UIImageView * iv=[[UIImageView alloc] initWithFrame:CGRectMake(40, 0, 32, 32)];
	[v addSubview:iv];
	
	UILabel * l=[[UILabel alloc] initWithFrame:CGRectMake(76,8, 200, 22)];
	l.font=[UIFont boldSystemFontOfSize:18];
	l.textColor=[UIColor darkGrayColor];
	l.backgroundColor=[UIColor clearColor];
	[v addSubview:l];
	
	UILabel * s=[[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width-114, 8, 80, 22)];
	s.font=[UIFont systemFontOfSize:18];
	s.textAlignment=UITextAlignmentRight;
	s.backgroundColor=[UIColor clearColor];
	
	[v addSubview:s];
	
	switch (section) 
	{
		case 0:
			iv.image=[UIImage imageNamed:@"gray_googlreader.png"];
			l.text=@"Google Reader";
			if(googleReaderStatusLabel)
			{
				s.textColor=googleReaderStatusLabel.textColor;
				s.text=googleReaderStatusLabel.text;
				[googleReaderStatusLabel release];
			}
			googleReaderStatusLabel=[s retain];
			break;
		case 1:
			iv.image=[UIImage imageNamed:@"gray_twitter.png"];
			l.text=@"Twitter";
			if(twitterStatusLabel)
			{
				s.textColor=twitterStatusLabel.textColor;
				s.text=twitterStatusLabel.text;
				[twitterStatusLabel release];
			}
			twitterStatusLabel=[s retain];
			break;
		case 2:
			iv.image=[UIImage imageNamed:@"gray_infongen.png"];
			l.text=@"InfoNgen";
			if(infoNgenStatusLabel)
			{
				s.text=infoNgenStatusLabel.text;
				s.textColor=infoNgenStatusLabel.textColor;
				[infoNgenStatusLabel release];
			}
			infoNgenStatusLabel=[s retain];
			break;
	}
	[iv release];
	[l release];
	[s release];
	return [v autorelease];
}


- (UITextField*) textFieldForIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0:
			if(indexPath.row==0)
			{
				return  googleReaderUsernameTextField;  
			}
			else 
			{
				return googleReaderPasswordTextField;
			}
			
		case 1:
			if(indexPath.row==0)
			{
				return twitterUsernameTextField;
			}
			else 
			{
				return twitterPasswordTextField;
			}
			
		case 2:
			if(indexPath.row==0)
			{
				return infoNgenUsernameTextField;
			}
			else 
			{
				return infoNgenPasswordTextField;
			}
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITextField * textField=[self textFieldForIndexPath:indexPath];
	
	[textField becomeFirstResponder];
}

- (UITableViewCell *) createTextFieldCell:(NSString *)labelText textFieldSelector:(SEL)textFieldSelector value:(NSString*)value isSecure:(BOOL) isSecure
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
	UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,8,100,30)];
	label.text=labelText;
	label.textColor=[UIColor blackColor];
	label.font=[UIFont boldSystemFontOfSize:17];
	label.backgroundColor=[UIColor clearColor];
	
	UITextField * textField= [[UITextField alloc] initWithFrame:CGRectMake(105,12,370,22)];
	textField.backgroundColor=[UIColor clearColor];
	textField.font=[UIFont systemFontOfSize:17];//:18];
	textField.text=value;
	textField.textColor=[UIColor colorWithRed:25.0/255.0 green:76.0/255.0 blue:127.0/255.0 alpha:1.0];
	textField.delegate=self;
	textField.clearButtonMode=UITextFieldViewModeWhileEditing;
	
	if(isSecure)
	{
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		textField.secureTextEntry=YES;
	}
	else 
	{
		textField.keyboardType=UIKeyboardTypeEmailAddress;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
	}
	if(textFieldSelector!=NULL)
	{
		[self performSelector:textFieldSelector withObject:textField];
	}
	[cell.contentView addSubview:label];
	[cell.contentView addSubview:textField];
		
	[textField release];
	[label release];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0:
			if(indexPath.row==0)
			{
				return [self createTextFieldCell:@"Username" textFieldSelector:@selector(setGoogleReaderUsernameTextField:) value:googleReaderUsername isSecure:NO];
			}
			else 
			{
				return [self createTextFieldCell:@"Password" textFieldSelector:@selector(setGoogleReaderPasswordTextField:) value:googleReaderPassword isSecure:YES];
			}

		case 1:
			if(indexPath.row==0)
			{
				return [self createTextFieldCell:@"Username" textFieldSelector:@selector(setTwitterUsernameTextField:)  value:twitterUsername isSecure:NO];
			}
			else 
			{
				return [self createTextFieldCell:@"Password" textFieldSelector:@selector(setTwitterPasswordTextField:)  value:twitterPassword isSecure:YES];
			}
			
		case 2:
			if(indexPath.row==0)
			{
				return [self createTextFieldCell:@"Username" textFieldSelector:@selector(setInfoNgenUsernameTextField:)  value:infoNgenUsername isSecure:NO];
			}
			else 
			{
				return [self createTextFieldCell:@"Password" textFieldSelector:@selector(setInfoNgenPasswordTextField:)  value:infoNgenPassword isSecure:YES];
			}
			
			
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)viewDidLoad 
{
	self.navigationItem.title=@"Account Settings";
	
	self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
	self.cancelButton=self.navigationItem.leftBarButtonItem;
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
	self.doneButton=self.navigationItem.rightBarButtonItem;
	
	googleReaderUsername=[UserSettings getSetting:@"googlereader.username"];
	googleReaderPassword=[UserSettings getSetting:@"googlereader.password"];
	infoNgenUsername=[UserSettings getSetting:@"infongen.username"];
	infoNgenPassword=[UserSettings getSetting:@"infongen.password"];
	twitterUsername=[UserSettings getSetting:@"twitter.username"];
	twitterPassword=[UserSettings getSetting:@"twitter.password"];
	
	UIEdgeInsets insets=self.tableView.contentInset;
	
	insets.top=20;
	
	self.tableView.contentInset=insets;
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
   
}

- (void)dealloc 
{
	[googleReaderUsernameTextField release];
	[googleReaderPasswordTextField release];
	[infoNgenUsernameTextField release];
	[infoNgenPasswordTextField release];
	[twitterUsernameTextField release];
	[twitterPasswordTextField release];
	
	[operationQueue release];
	[twitterClient release];
	[doneButton release];
	[cancelButton release];
	[activeTextField release];
	
	[googleReaderStatusLabel release];
	[twitterStatusLabel release];
	[infoNgenStatusLabel release];
	
	googleReaderStatusLabel =nil;
	twitterStatusLabel  =nil;
	infoNgenStatusLabel =nil;
    [super dealloc];
}


@end
