//
//  NewslettersScrollViewController.h
//  Untitled
//
//  Created by Robert Stewart on 3/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsletterBaseViewController.h"

#define kDeleteNewsletterActionSheet 1
#define kPublishNewsletterActionSheet 2

@class Newsletter;

@interface NewslettersScrollViewController : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate>{
	IBOutlet UIScrollView * scrollView;
	IBOutlet UIPageControl * pageControl;
	BOOL pageControlIsChangingPage;
	NSMutableArray * newsletters;
	NSMutableArray * scrollItems;
	IBOutlet UIToolbar * toolBar;
	IBOutlet UIBarButtonItem * deleteButton;
	IBOutlet UIBarButtonItem * sendButton;
	IBOutlet UILabel * titleLabel;
	IBOutlet UILabel * dateLabel;
	IBOutlet UILabel * publishedDateLabel;
	IBOutlet UILabel * titleDateLabel;
	IBOutlet UILabel * titlePublishedDateLabel;
	UISegmentedControl * modeControl;
}
@property(nonatomic,retain) IBOutlet UIScrollView * scrollView;
@property(nonatomic,retain) IBOutlet UIPageControl * pageControl;
@property(nonatomic,retain) NSMutableArray * newsletters;
@property(nonatomic,retain) NSMutableArray * scrollItems;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * deleteButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * sendButton;
@property(nonatomic,retain) IBOutlet UILabel * dateLabel;
@property(nonatomic,retain) IBOutlet UILabel * publishedDateLabel;
@property(nonatomic,retain) IBOutlet UILabel * titleLabel;
@property(nonatomic,retain) IBOutlet UILabel * titleDateLabel;
@property(nonatomic,retain) IBOutlet UILabel * titlePublishedDateLabel;

@property(nonatomic,retain) UISegmentedControl * modeControl;

@property(nonatomic,retain) IBOutlet UIToolbar * toolBar;


- (void) addNewsletterPage:(Newsletter*)_newsletter;
- (void) editNewsletter:(Newsletter*)newsletter;
- (IBAction)changePage:(id)sender;
//- (UIImage*)captureView:(UIView *)view ;
-(IBAction) deleteTouch:(id)sender;
-(IBAction) sendTouch:(id)sender;
- (void) scrollToPage:(int) pageNumber;
- (void) displayCurrentPageInfo;

@end
