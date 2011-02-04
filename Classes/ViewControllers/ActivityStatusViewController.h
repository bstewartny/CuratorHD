//
//  ActivityStatusViewController.h
//  Untitled
//
//  Created by Robert Stewart on 4/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ActivityStatusViewController : UIViewController {
	IBOutlet UIActivityIndicatorView * activityIndicatorView;
	IBOutlet UILabel * titleLabel;
	IBOutlet UILabel * statusLabel;
}
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView * activityIndicatorView;
@property(nonatomic,retain) IBOutlet UILabel * titleLabel;
@property(nonatomic,retain) IBOutlet UILabel * statusLabel;

@end
