//
//  RiverViewController.h
//  Untitled
//
//  Created by Robert Stewart on 4/26/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdatableViewController.h"

@class NewsletterAddItemViewController;
@interface RiverViewController : UpdatableViewController {
	NSArray * feeds;
	NSArray * searchResults;
	NSDictionary * feedsMap;
	NSDateFormatter * dateFormatter;
	UINavigationController * parentNavigationController;
	IBOutlet UITableView * resultsTable;
	UIPopoverController * addItemPopoverController;
	NewsletterAddItemViewController * addItemViewController;
}
@property(nonatomic,retain) NSArray * feeds;
@property(nonatomic,retain) NSDateFormatter * dateFormatter;
@property(nonatomic,retain) NSArray * searchResults;
@property(nonatomic,retain) NSDictionary * feedsMap;
@property(nonatomic,retain) UINavigationController * parentNavigationController;
@property(nonatomic,retain) IBOutlet UITableView * resultsTable;
@property(nonatomic,retain) UIPopoverController * addItemPopoverController;
@property(nonatomic,retain) NewsletterAddItemViewController * addItemViewController;

- (void) setRiverResults;
@end
