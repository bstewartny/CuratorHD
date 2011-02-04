//
//  SectionEditFormViewController.h
//  Untitled
//
//  Created by Robert Stewart on 5/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewsletterSection;

@interface SectionEditFormViewController : UIViewController {
	NewsletterSection * section;
	IBOutlet UITableView * tableView;
	IBOutlet UITextField * nameTextField;
	IBOutlet UITextView * descriptionTextView;
	id delegate;
	UIPopoverController * feedPickerPopover;
	UIView * feedPickerView;
	UIColor * commentsTextColor;
	UIColor * nameTextColor;
}
@property(nonatomic,retain) NewsletterSection * section;
@property(nonatomic,retain) IBOutlet UITextField * nameTextField;
@property(nonatomic,retain) IBOutlet UITextView * descriptionTextView;
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,retain) UIPopoverController * feedPickerPopover;
@property(nonatomic,retain) UIColor * commentsTextColor;
@property(nonatomic,retain) UIColor * nameTextColor;

@property(nonatomic,retain) id delegate;
- (IBAction) dismiss;
- (IBAction) cancel;

@end
