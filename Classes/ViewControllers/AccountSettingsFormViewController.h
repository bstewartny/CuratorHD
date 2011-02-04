//
//  AccountSettingsFormViewController.h
//  Untitled
//
//  Created by Robert Stewart on 5/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterClient;
@interface AccountSettingsFormViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView * tableView;
	id delegate;
	UITextField * googleReaderUsernameTextField;
	UITextField * googleReaderPasswordTextField;
	UITextField * infoNgenUsernameTextField;
	UITextField * infoNgenPasswordTextField;
	UITextField * twitterUsernameTextField;
	UITextField * twitterPasswordTextField;
	IBOutlet UINavigationBar * navBar;
	UITextField * activeTextField;
	
	NSOperationQueue * operationQueue;
	int num_accounts;
	int num_failed;
	int num_succeeded;
	TwitterClient * twitterClient;
	
	IBOutlet UIBarButtonItem * cancelButton;
	IBOutlet UIBarButtonItem * doneButton;
	
	BOOL keyboardVisible;
	CGFloat keyboardHeight;
	
	UILabel * googleReaderStatusLabel;
	UILabel * twitterStatusLabel;
	UILabel * infoNgenStatusLabel;
	
	
	NSString * googleReaderUsername;
	NSString * googleReaderPassword;
	NSString * infoNgenUsername;
	NSString * infoNgenPassword;
	NSString * twitterUsername;
	NSString * twitterPassword;
	
	
}
@property(nonatomic,retain) IBOutlet UINavigationBar * navBar;
@property(nonatomic,retain) UITextField * activeTextField;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * cancelButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * doneButton;

@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,assign) id delegate;

@property(nonatomic,retain) UITextField * googleReaderUsernameTextField;
@property(nonatomic,retain) UITextField * googleReaderPasswordTextField;
@property(nonatomic,retain) UITextField * infoNgenUsernameTextField;
@property(nonatomic,retain) UITextField * infoNgenPasswordTextField;
@property(nonatomic,retain) UITextField * twitterUsernameTextField;
@property(nonatomic,retain) UITextField * twitterPasswordTextField;

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField;
- (IBAction)textFieldDidEndEditing:(UITextField *)textField;

-(void) keyboardWillHide:(NSNotification *)note;
-(void) keyboardWillShow:(NSNotification *)note;

- (IBAction) cancel;
- (IBAction) done;

@end
