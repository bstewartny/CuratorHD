//
//  DetailViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedItemHTMLViewController;
@class NewslettersScrollViewController;
@interface DetailViewController : UIViewController {
	FeedItemHTMLViewController * itemHtmlView;
	NewslettersScrollViewController * newslettersScrollView;
}
@property(nonatomic,retain) FeedItemHTMLViewController * itemHtmlView;
@property(nonatomic,retain) NewslettersScrollViewController * newslettersScrollView;

@end
