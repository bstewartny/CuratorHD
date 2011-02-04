//
//  NewsletterAddSectionViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Newsletter ;
@class NewsletterBaseViewController;

@interface NewsletterAddSectionViewController : UIViewController {
	IBOutlet UITableView * sectionsTable;
	Newsletter * newsletter;
	NSArray * feeds;
	NewsletterBaseViewController * newsletterDelegate;
}
@property(nonatomic,retain) IBOutlet UITableView * sectionsTable;
@property(nonatomic,retain) Newsletter * newsletter;
@property(nonatomic,retain) NewsletterBaseViewController * newsletterDelegate;
@property(nonatomic,retain) NSArray * feeds;

@end
