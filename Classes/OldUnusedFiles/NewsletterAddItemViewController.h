//
//  NewsletterAddItemViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/4/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedItem;

@interface NewsletterAddItemViewController : UIViewController {
	IBOutlet UITableView * tableView;
	NSArray * newsletters;
	FeedItem * item;
}
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,retain) NSArray * newsletters;
@property(nonatomic,retain) FeedItem * item;
@end
