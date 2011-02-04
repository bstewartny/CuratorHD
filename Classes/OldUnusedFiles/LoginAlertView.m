//
//  LoginAlertView.m
//  Untitled
//
//  Created by Robert Stewart on 5/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "LoginAlertView.h"


@implementation LoginAlertView
@synthesize usernameTextField,passwordTextField,accountTypeSegmentedControl;


- (id)initWithAccountTypes:(NSArray*)accountTypes delegate:(id)delegate 
{
    if (self = [super initWithTitle:@"Enter Account Info" message:@"\n\n\n\n\n" delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil])
    {
		usernameTextField=[[UITextField alloc] initWithFrame:CGRectMake(12.0,45.0,260.0,25.0)];
		usernameTextField.backgroundColor=[UIColor whiteColor];
		usernameTextField.placeholder=@"Username";
		
		passwordTextField=[[UITextField alloc] initWithFrame:CGRectMake(12.0,75.0,260.0,25.0)];
		passwordTextField.backgroundColor=[UIColor whiteColor];
		passwordTextField.placeholder=@"Password";
		passwordTextField.secureTextEntry = YES;
		
		accountTypeSegmentedControl=[[UISegmentedControl alloc] initWithItems:accountTypes];
		accountTypeSegmentedControl.frame=CGRectMake(12.0, 105.0, 260.0, 30.0);
		accountTypeSegmentedControl.selectedSegmentIndex=0;
		accountTypeSegmentedControl.segmentedControlStyle=UISegmentedControlStyleBar;							 
		[self addSubview:usernameTextField];
		[self addSubview:passwordTextField];
		[self addSubview:accountTypeSegmentedControl];
		
		
		CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
        [self setTransform:translate];
    }
    return self;
}
- (void)show
{
    [usernameTextField becomeFirstResponder];
    [super show];
}
- (NSString*) username
{
	return self.usernameTextField.text;
}
- (NSString*) password
{
	return self.passwordTextField.text;
}
- (NSString*) accountType
{
	return [self.accountTypeSegmentedControl titleForSegmentAtIndex:self.accountTypeSegmentedControl.selectedSegmentIndex];
}
- (void) dealloc
{
	[usernameTextField release];
	[passwordTextField release];
	[accountTypeSegmentedControl release];
}

@end
