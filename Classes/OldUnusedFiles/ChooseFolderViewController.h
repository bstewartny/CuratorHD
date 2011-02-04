//
//  ChooseFolderViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FeedItem;

@interface ChooseFolderViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView * tableView;
	NSArray * folders;
	id delegate;
	FeedItem * item;
}
@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) NSArray * folders;
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,retain) FeedItem * item;
@end
