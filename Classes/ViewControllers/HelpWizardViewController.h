//
//  HelpWizardViewController.h
//  Untitled
//
//  Created by Robert Stewart on 10/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrubberPageControl.h"
#import <MessageUI/MessageUI.h>
@interface HelpWizardViewController : UIViewController<MFMailComposeViewControllerDelegate> {
	NSArray * items;
	//NSArray * screenshots;
	//NSArray * descriptions;
	IBOutlet UIScrollView * scrollView;
	IBOutlet ScrubberPageControl * pageControl;
	IBOutlet UIButton * prevButton;
	IBOutlet UIButton * nextButton;
	IBOutlet UIButton * closeButton;
	//BOOL pageControlIsChangingPage;
}

@property(nonatomic,retain) NSArray * items;
//@property(nonatomic,retain) NSArray * screenshots;
//@property(nonatomic,retain) NSArray * descriptions;
@property(nonatomic,retain) IBOutlet UIScrollView * scrollView;
@property(nonatomic,retain) IBOutlet ScrubberPageControl * pageControl;
@property(nonatomic,retain) IBOutlet UIButton * prevButton;
@property(nonatomic,retain) IBOutlet UIButton * nextButton;
@property(nonatomic,retain) IBOutlet UIButton * closeButton;

- (IBAction) prevButtonTouch:(id)sender;
- (IBAction) nextButtonTouch:(id)sender;
- (IBAction) closeButtonTouch:(id)sender;
- (IBAction) changePage:(id)sender;

@end
