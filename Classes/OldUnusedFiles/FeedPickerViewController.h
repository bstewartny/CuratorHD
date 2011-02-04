//
//  FeedPickerViewController.h
//  Untitled
//
//  Created by Robert Stewart on 5/26/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewsletterSection;

@interface FeedPickerViewController : UIViewController {
	NSArray * feeds;
	IBOutlet UITableView * tableView;
	NewsletterSection * section;
	id delegate;
}

@property(nonatomic,retain) NSArray * feeds;
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,assign) id delegate;

@property(nonatomic,retain) NewsletterSection * section;

@end
