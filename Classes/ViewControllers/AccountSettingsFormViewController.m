#import "AccountSettingsFormViewController.h"
#import "UserSettings.h"
#import "TwitterClient.h"
#import "InfoNgenLoginTicket.h"
#import "GoogleReaderClient.h"
#import <QuartzCore/QuartzCore.h>
#import "GoogleClientLogin.h"

@implementation AccountSettingsFormViewController
@synthesize tableView,delegate,navBar,twitterUsernameTextField,twitterPasswordTextField,googleReaderUsernameTextField,googleReaderPasswordTextField,infoNgenUsernameTextField,infoNgenPasswordTextField;
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
		// start spinner
		[cancelButton setEnabled:NO];
		[doneButton setEnabled:NO];
		
		self.navBar.topItem.title =@"Verifying Accounts...";
	}
}

- (void) maybeDone
{
	[tableView reloadData];
	
	if(num_failed + num_succeeded >= num_accounts)
	{
		if(num_failed>0)
		{
			// tell/show user we failed and they can try again or cancel
			[cancelButton setEnabled:YES];
			[doneButton setEnabled:YES];
			
			self.navBar.topItem.titleView=nil;
			self.navBar.topItem.title =@"Account Settings";
		}
		else 
		{
			[cancelButton setEnabled:YES];
			[doneButton setEnabled:YES];
			// all succeeded, close
			
			self.navBar.topItem.titleView=nil;
			self.navBar.topItem.title =@"Account Settings";
			
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
	NSLog(@"verifyTwitter");
	
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

	/*GoogleReaderClient * client=[[GoogleReaderClient alloc] initWithUsername:googleReaderUsernameTextField.text password:googleReaderPasswordTextField.text useCachedAuth:NO];
	
	if([client isValid])
	{
		[client release];
		[self performSelectorOnMainThread:@selector(verifyGoogleSucceeded) withObject:nil waitUntilDone:NO];
	}
	else 
	{
		[client release];
		[self performSelectorOnMainThread:@selector(verifyGoogleFailed) withObject:nil waitUntilDone:NO];
	}*/
}

- (void) makeAlertLabel:(UITextField*)textField 
{
	//textField.superview.layer.borderColor=[UIColor redColor].CGColor;
	//textField.superview.layer.borderWidth=2;
}

- (void) removeAlertLabel:(UITextField*)textField
{
	//textField.superview.layer.borderColor=[UIColor clearColor].CGColor;
	//textField.superview.layer.borderWidth=0;
}

- (void) verifyInfoNgenFailed
{
	num_failed++;
	infoNgenStatusLabel.textColor=[UIColor redColor];
	infoNgenStatusLabel.text=@"Failed!";
	[self makeAlertLabel:infoNgenUsernameTextField];
	[self makeAlertLabel:infoNgenPasswordTextField];
	[self maybeDone];
}

- (void) verifyTwitterFailed
{
	num_failed++;
	twitterStatusLabel.textColor=[UIColor redColor];
	twitterStatusLabel.text=@"Failed!";
	[self makeAlertLabel:twitterUsernameTextField];
	[self makeAlertLabel:twitterPasswordTextField];
	[self maybeDone];
}

- (void) verifyGoogleFailed
{
	num_failed++;
	googleReaderStatusLabel.textColor=[UIColor redColor];
	googleReaderStatusLabel.text=@"Failed!";
	[self makeAlertLabel:googleReaderUsernameTextField];
	[self makeAlertLabel:googleReaderPasswordTextField];
	[self maybeDone];
}

- (void) removeAlertLabels
{
	[self removeAlertLabel:googleReaderUsernameTextField];
	[self removeAlertLabel:googleReaderPasswordTextField];
	[self removeAlertLabel:twitterUsernameTextField];
	[self removeAlertLabel:twitterPasswordTextField];
	[self removeAlertLabel:infoNgenUsernameTextField];
	[self removeAlertLabel:infoNgenPasswordTextField];
	
	twitterStatusLabel.text=nil;
	infoNgenStatusLabel.text=nil;
	googleReaderStatusLabel.text=nil;
	
}

- (void) verifyInfoNgenSucceeded
{
	infoNgenStatusLabel.textColor=[UIColor blueColor];
	infoNgenStatusLabel.text=@"Verfied";
	num_succeeded++;
	[self maybeDone];
}

- (void) verifyTwitterSucceeded
{
	twitterStatusLabel.textColor=[UIColor blueColor];
	twitterStatusLabel.text=@"Verfied";
	num_succeeded++;
	[self maybeDone];
}

- (void) verifyGoogleSucceeded
{
	googleReaderStatusLabel.textColor=[UIColor blueColor];
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
	//l.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	l.font=[UIFont boldSystemFontOfSize:18];
	l.textColor=[UIColor darkGrayColor];
	l.backgroundColor=[UIColor clearColor];
	[v addSubview:l];
	
	UILabel * s=[[UILabel alloc] initWithFrame:CGRectMake(320, 8, 80, 22)];
	s.font=[UIFont systemFontOfSize:18];
	s.textAlignment=UITextAlignmentLeft;
	s.backgroundColor=[UIColor clearColor];
	
	[v addSubview:s];
	
	switch (section) 
	{
		case 0:
			iv.image=[UIImage imageNamed:@"32-googlreader.png"];
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
			iv.image=[UIImage imageNamed:@"32-twitter.png"];
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
			iv.image=[UIImage imageNamed:@"32-infongen.png"];
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

- (UITableViewCell *) createTextFieldCell:(NSString *)labelText textFieldSelector:(SEL)textFieldSelector value:(NSString*)value isSecure:(BOOL) isSecure
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
	UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,100,30)];
	label.text=labelText;
	label.textColor=[UIColor grayColor];
	label.font=[UIFont systemFontOfSize:18];
	label.backgroundColor=[UIColor clearColor];
	
	UITextField * textField= [[UITextField alloc] initWithFrame:CGRectMake(105,14,370,22)];
	//textField.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	textField.backgroundColor=[UIColor clearColor];
	textField.font=[UIFont systemFontOfSize:18];//:18];
	textField.text=value;
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
				return [self createTextFieldCell:@"Username:" textFieldSelector:@selector(setGoogleReaderUsernameTextField:) value:googleReaderUsername isSecure:NO];
			}
			else 
			{
				return [self createTextFieldCell:@"Password:" textFieldSelector:@selector(setGoogleReaderPasswordTextField:) value:googleReaderPassword isSecure:YES];
			}

		case 1:
			if(indexPath.row==0)
			{
				return [self createTextFieldCell:@"Username:" textFieldSelector:@selector(setTwitterUsernameTextField:)  value:twitterUsername isSecure:NO];
			}
			else 
			{
				return [self createTextFieldCell:@"Password:" textFieldSelector:@selector(setTwitterPasswordTextField:)  value:twitterPassword isSecure:YES];
			}
			
		case 2:
			if(indexPath.row==0)
			{
				return [self createTextFieldCell:@"Username:" textFieldSelector:@selector(setInfoNgenUsernameTextField:)  value:infoNgenUsername isSecure:NO];
			}
			else 
			{
				return [self createTextFieldCell:@"Password:" textFieldSelector:@selector(setInfoNgenPasswordTextField:)  value:infoNgenPassword isSecure:YES];
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)viewDidLoad 
{
	googleReaderUsername=[UserSettings getSetting:@"googlereader.username"];
	googleReaderPassword=[UserSettings getSetting:@"googlereader.password"];
	infoNgenUsername=[UserSettings getSetting:@"infongen.username"];
	infoNgenPassword=[UserSettings getSetting:@"infongen.password"];
	twitterUsername=[UserSettings getSetting:@"twitter.username"];
	twitterPassword=[UserSettings getSetting:@"twitter.password"];
	
	UIEdgeInsets insets=tableView.contentInset;
	
	insets.top=20;
	
	tableView.contentInset=insets;
	
    // Register notification when the keyboard will be show
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
}

// To be link with your TextField event "Editing Did Begin"
//  memoryze the current TextField
- (IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
	//[self removeAlertLabel:textField];
}

// To be link with your TextField event "Editing Did End"
//  release current TextField
- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    //self.activeTextField = nil;
}

CGRect IASKCGRectSwap(CGRect rect) {
	CGRect newRect;
	newRect.origin.x = rect.origin.y;
	newRect.origin.y = rect.origin.x;
	newRect.size.width = rect.size.height;
	newRect.size.height = rect.size.width;
	return newRect;
}

- (void)keyboardWillShow:(NSNotification*)notification {
     
	NSDictionary* userInfo = [notification userInfo];
	
	// we don't use SDK constants here to be universally compatible with all SDKs ≥ 3.0
	NSValue* keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
	if (!keyboardFrameValue) 
	{
		keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
	}
	
	CGRect keyboardFrame=[keyboardFrameValue CGRectValue];
	
	keyboardHeight=keyboardFrame.size.height;
	
	keyboardVisible=YES;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
	
	[self adjustTableViewHeightForKeyboard];
	
	[UIView commitAnimations];
	
	// iOS 3 sends hide and show notifications right after each other
	// when switching between textFields, so cancel -scrollToOldPosition requests
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:self.activeTextField.superview.superview] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification 
{
	NSDictionary* userInfo = [notification userInfo];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
	
	CGRect rect = self.view.bounds;
	rect.size.
	height-=44;
	rect.origin.y=44;
	self.tableView.frame=rect;
	
	[UIView commitAnimations];
	
	keyboardVisible=NO;
	keyboardHeight=0;
	
	
}  

- (void) adjustTableViewHeightForKeyboard
{
	CGRect frame=self.tableView.frame;

	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) 
	{
		screenBounds = IASKCGRectSwap(screenBounds);
	}
	
	CGFloat screenHeight=screenBounds.size.height;
	
	if(screenHeight - keyboardHeight < (self.tableView.frame.size.height+64))
	{
		frame.size.height=(screenHeight - keyboardHeight) - 64;
		self.tableView.frame=frame;
	}
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(keyboardVisible)
	{
		[self adjustTableViewHeightForKeyboard];
	}
}

- (void)dealloc 
{
	[tableView release];
	
	[navBar release];
	
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
