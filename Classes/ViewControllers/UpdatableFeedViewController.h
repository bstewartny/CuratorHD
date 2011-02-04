//
//  UpdatableFeedViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/28/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdatableViewController.h"

@interface UpdatableFeedViewController : UpdatableViewController {
	IBOutlet UIToolbar * toolbar;
	UIBarButtonItem * refreshButton;
	//UIActivityIndicatorView * activityIndicatorView;
	UILabel * statusLabel;
}
@property(nonatomic,retain) IBOutlet UIToolbar * toolbar;
@property(nonatomic,retain) UILabel *	statusLabel;
@property(nonatomic,retain) UIBarButtonItem * refreshButton;
//@property(nonatomic,retain) UIActivityIndicatorView * activityIndicatorView;


@end
