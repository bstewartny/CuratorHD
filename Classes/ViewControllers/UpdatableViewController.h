//
//  UpdatableViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdatableViewController : UIViewController {
	BOOL updating;
	UIView * activityView;
	UIActivityIndicatorView * activityIndicatorView;
	BOOL updatable;
}
@property(nonatomic,retain) UIActivityIndicatorView * activityIndicatorView;
@property(nonatomic,retain) UIView * activityView;
@property(nonatomic) BOOL updatable;
- (BOOL) isUpdating;
- (IBAction) update;
- (void) doUpdate;
- (void) afterUpdate;

@end
