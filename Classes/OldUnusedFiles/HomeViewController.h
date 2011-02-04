//
//  HomeViewController.h
//  Untitled
//
//  Created by Robert Stewart on 4/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHomeViewModeDashboard 0
#define kHomeViewModeRiver 1

@class HomeViewItemController;
@class RiverViewController;

@interface HomeViewController : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate>
{
	IBOutlet UIScrollView * scrollView;
	IBOutlet UIPageControl * pageControl;
	//IBOutlet UITabBar * tabBar;
	NSArray * feeds;
	NSMutableArray * scrollItems;
	BOOL pageControlIsChangingPage;
	HomeViewItemController * zoomedItem;
	CGRect zoomedOutRect;
	int viewMode;
	RiverViewController * riverViewController;
	BOOL updating;
}

@property(nonatomic,retain) IBOutlet UIScrollView * scrollView;
@property(nonatomic,retain) IBOutlet UIPageControl * pageControl;
//@property(nonatomic,retain) IBOutlet UITabBar * tabBar;
@property(nonatomic,retain) NSArray * feeds;
@property(nonatomic,retain) NSMutableArray * scrollItems;
@property(nonatomic,retain) HomeViewItemController * zoomedItem;
@property(nonatomic,retain) RiverViewController * riverViewController;

- (IBAction)changePage:(id)sender;
- (void) zoomIn:(HomeViewItemController*)item;
- (void) zoomOut:(HomeViewItemController*)item;

- (void) toggleViewMode:(id)sender;

@end
