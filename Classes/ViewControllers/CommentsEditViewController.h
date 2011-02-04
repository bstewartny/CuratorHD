//
//  CommentsEditViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@class FeedItem;

@interface CommentsEditViewController : UIViewController <MFMailComposeViewControllerDelegate>{
	FeedItem * item;
	IBOutlet UITableView * tableView;
	IBOutlet UITextView * commentsTextView;
	id delegate;
	
	UIColor * commentsTextColor;
}
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) IBOutlet UITextView * commentsTextView;
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,retain) id delegate;
@property(nonatomic,retain) UIColor * commentsTextColor;
- (IBAction) dismiss;
- (IBAction) cancel;
- (IBAction) action:(id)sender;

@end
