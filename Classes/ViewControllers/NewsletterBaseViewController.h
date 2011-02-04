//
//  NewsletterBaseViewController.h
//  Untitled
//
//  Created by Robert Stewart on 3/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Newsletter;

@interface NewsletterBaseViewController : UIViewController {
	Newsletter * newsletter;
}
@property(nonatomic,retain) Newsletter * newsletter;

- (void) renderNewsletter;

@end
