//
//  FeedViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshViewController.h"
#import <MessageUI/MessageUI.h>
#import "ItemFetcher.h"

@class ItemFetcher;
@class MarkupStripper;
@interface FeedViewController : PullToRefreshViewController <UIActionSheetDelegate,MFMailComposeViewControllerDelegate,ItemFetcherDelegate> {
	//IBOutlet UITableView * tableView;
	ItemFetcher * fetcher;
	NSDateFormatter * dateFormatter;
	id itemDelegate;
	BOOL favoritesMode;
	BOOL editable;
	//UIView *refreshHeaderView;
    //UILabel *refreshLabel;
    //UIImageView *refreshArrow;
    //UIActivityIndicatorView *refreshSpinner;
    //BOOL isDragging;
    //BOOL isLoading;
    //NSString *textPull;
    //NSString *textRelease;
    //NSString *textLoading;
	MarkupStripper * stripper;
	BOOL twitter;
	UIPopoverController * navPopoverController;
	NSString * origTitle;
	BOOL folderMode;
	BOOL editMode;
	 
	
}
@property(nonatomic) BOOL folderMode;
@property(nonatomic) BOOL twitter;
@property(nonatomic,retain) NSString * origTitle;
@property(nonatomic,retain) ItemFetcher	* fetcher;
//@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,assign) id itemDelegate;
@property(nonatomic,retain) NSDateFormatter * dateFormatter;
@property(nonatomic) BOOL favoritesMode;
@property(nonatomic) BOOL editable;
@property(nonatomic,retain) UIPopoverController * navPopoverController;
//@property (nonatomic, retain) UIView *refreshHeaderView;
//@property (nonatomic, retain) UILabel *refreshLabel;
//@property (nonatomic, retain) UIImageView *refreshArrow;
//@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
//@property (nonatomic, copy) NSString *textPull;
//@property (nonatomic, copy) NSString *textRelease;
//@property (nonatomic, copy) NSString *textLoading;

- (IBAction) actionTouch:(id)sender;

@end
