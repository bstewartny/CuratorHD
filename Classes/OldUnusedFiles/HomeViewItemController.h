//
//  HomeViewItemController.h
//  Untitled
//
//  Created by Robert Stewart on 4/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdatableViewController.h"

@class Feed ;
@class NewsletterAddItemViewController;
@interface HomeViewItemController : UpdatableViewController {
	IBOutlet UIButton * nameButton;
	IBOutlet UITableView * resultsTable;
	IBOutlet UIButton * zoomButton;
	Feed * feed;
	NSDateFormatter * dateFormatter;
	 
	UINavigationController * parentNavigationController;
	BOOL zoomedIn;
	UIViewController * parentHomeViewController;
	UIPopoverController * addItemPopoverController;
	NewsletterAddItemViewController * addItemViewController;

}	
@property(nonatomic,retain) IBOutlet UIButton * nameButton;
@property(nonatomic,retain) IBOutlet UIButton * zoomButton;

@property(nonatomic,retain) IBOutlet UITableView * resultsTable;
@property(nonatomic,retain) Feed 	 * feed;

@property(nonatomic,retain) NSDateFormatter * dateFormatter;
@property(nonatomic,retain) UINavigationController * parentNavigationController;
@property(nonatomic,retain) UIViewController * parentHomeViewController;
@property(nonatomic,retain) UIPopoverController * addItemPopoverController;
@property(nonatomic,retain) NewsletterAddItemViewController * addItemViewController;


 

- (IBAction) zoomButtonTouch:(id)sender;


 
@end
