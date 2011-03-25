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
#import "MBProgressHUD.h"

@class ItemFetcher;
@class MarkupStripper;
@interface FeedViewController : PullToRefreshViewController <UIActionSheetDelegate,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate,ItemFetcherDelegate> {
	ItemFetcher * fetcher;
	id itemDelegate;
	BOOL favoritesMode;
	BOOL editable;
	MarkupStripper * stripper;
	BOOL twitter;
	UIPopoverController * navPopoverController;
	NSString * origTitle;
	BOOL folderMode;
	BOOL editMode;
	UIBarButtonItem * organizeButton;
	UIBarButtonItem * editButton;
	MBProgressHUD * HUD;
}
@property(nonatomic) BOOL folderMode;
@property(nonatomic) BOOL twitter;
@property(nonatomic,retain) NSString * origTitle;
@property(nonatomic,retain) ItemFetcher	* fetcher;
@property(nonatomic,assign) id itemDelegate;
@property(nonatomic) BOOL favoritesMode;
@property(nonatomic) BOOL editable;
@property(nonatomic,retain) UIPopoverController * navPopoverController;

- (IBAction) actionTouch:(id)sender;

@end
