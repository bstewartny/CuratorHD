//
//  FavoritesViewController.h
//  Untitled
//
//  Created by Robert Stewart on 4/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Favorites;
@class NewsletterAddItemViewController;
@interface FavoritesViewController : UIViewController {
	Favorites * favorites;
	IBOutlet UITableView * favoritesTable;
	NSDateFormatter * dateFormatter;
	UIPopoverController * addItemPopoverController;
	NewsletterAddItemViewController * addItemViewController;
}
@property(nonatomic,retain) Favorites * favorites;
@property(nonatomic,retain) IBOutlet UITableView * favoritesTable;
@property(nonatomic,retain) NSDateFormatter * dateFormatter;
@property(nonatomic,retain) UIPopoverController * addItemPopoverController;
@property(nonatomic,retain) NewsletterAddItemViewController * addItemViewController;

@end
