//
//  LoginAlertView.h
//  Untitled
//
//  Created by Robert Stewart on 5/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginAlertView : UIAlertView {
	UITextField * usernameTextField;
	UITextField * passwordTextField;
	UISegmentedControl * accountTypeSegmentedControl;
}
@property(nonatomic,retain) UITextField * usernameTextField;
@property(nonatomic,retain) UITextField * passwordTextField;
@property(nonatomic,retain) UISegmentedControl * accountTypeSegmentedControl;

- (id)initWithAccountTypes:(NSArray*)accountTypes delegate:(id)delegate ;

@end
