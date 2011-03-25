//
//  NewsletterBaseViewController.h
//  Untitled
//
//  Created by Robert Stewart on 3/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define kAdjustSynopsisActionSheet 9996


@class Newsletter;

@interface NewsletterBaseViewController : UIViewController <MBProgressHUDDelegate,UIActionSheetDelegate>{
	Newsletter * newsletter;
	MBProgressHUD * HUD;
}
@property(nonatomic,retain) Newsletter * newsletter;

- (void) renderNewsletter;

@end
