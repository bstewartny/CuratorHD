//
//  PullToRefreshViewController.h
//  Curator
//
//  Created by Robert Stewart on 3/10/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdatableFeedViewController.h"

@interface PullToRefreshViewController : UpdatableFeedViewController {
	IBOutlet UITableView * tableView;
	BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
	UIView * pullDownView;
	UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
	UIColor * pullDownBackgroundColor;
}
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@property(nonatomic,retain) UIView * pullDownView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property(nonatomic,retain) UIColor * pullDownBackgroundColor;
@end
