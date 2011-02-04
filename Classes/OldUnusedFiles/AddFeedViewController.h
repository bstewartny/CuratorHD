//
//  AddFeedViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddFeedViewController : UIViewController <UIActionSheetDelegate>
{
	IBOutlet UITableView * tableView;
	id delegate;
	UITextField * usernameTextField;
	UITextField * passwordTextField;
	UITextField * urlTextField;
	UITextField * nameTextField;
	UISegmentedControl * segmentedControl;
	//UIView * sourceTypeView;
	NSString * sourceType;
	//CGRect sourceTypeRect;
}

@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) UITextField * usernameTextField;
@property(nonatomic,retain) UITextField * passwordTextField;
@property(nonatomic,retain) UITextField * urlTextField;
@property(nonatomic,retain) UITextField * nameTextField;
@property(nonatomic,retain) UISegmentedControl * segmentedControl;
@property(nonatomic,retain) NSString * sourceType;

- (IBAction) cancel;
- (IBAction) done;

@end
