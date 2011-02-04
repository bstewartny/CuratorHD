//
//  TumblrPostViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdatableViewController.h"
#import "TumblrClient.h"

@class FeedItem;
@class TumblrPost;
 

@interface TumblrPostViewController : UpdatableViewController {
	FeedItem * item;
	IBOutlet UIScrollView * scrollView;
	
	IBOutlet UITableView * tableView;
	IBOutlet UITextField * titleTextField;
	IBOutlet UITextField * urlTextField;
	IBOutlet UITextView * bodyTextView;
	IBOutlet UITextField * tagsTextField;
	
	IBOutlet UIButton * textButton;
	IBOutlet UIButton * linkButton;
	IBOutlet UIButton * quoteButton;
	IBOutlet UIButton * photoButton;
	IBOutlet UIButton * videoButton;
	
	//TumblrPostType postType;
	
	TumblrPost * post;
}

@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) IBOutlet UITextField * titleTextField;
@property(nonatomic,retain) IBOutlet UITextField * urlTextField;
@property(nonatomic,retain) IBOutlet UITextView * bodyTextView;
@property(nonatomic,retain) IBOutlet UITextField * tagsTextField;
@property(nonatomic,retain) IBOutlet UITableView * tableView;
//@property(nonatomic) TumblrPostType postType;
@property(nonatomic,retain) IBOutlet UIScrollView * scrollView;

@property(nonatomic,retain) IBOutlet UIButton * textButton;
@property(nonatomic,retain) IBOutlet UIButton * linkButton;
@property(nonatomic,retain) IBOutlet UIButton * quoteButton;
@property(nonatomic,retain) IBOutlet UIButton * photoButton;
@property(nonatomic,retain) IBOutlet UIButton * videoButton;



- (IBAction) dismiss;
- (IBAction) cancel;
- (IBAction) doText:(id)sender;
- (IBAction) doLink:(id)sender;
- (IBAction) doQuote:(id)sender;
- (IBAction) doPhoto:(id)sender;
- (IBAction) doVideo:(id)sender;


@end
