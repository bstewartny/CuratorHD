//
//  NewsletterDetailViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsletterBaseViewController.h"

#define kTitleSection 0
#define kTitleRow 0

#define kSummarySection 1
#define kSummaryRow 0

#define kLogoImageSection 2
#define kLogoImageRow 0

#define kPublishingSection 3
#define kScheduleTypeRow 0
#define kScheduleRow 1
#define kRssEnabledRow 2
#define kEmailFormatRow 3
#define kSubscribersRow 4

//#define kSavedSearchesSection 4
//#define kSavedSearchesRow 0

@class Newsletter;

@interface NewsletterSettingsViewController : NewsletterBaseViewController <UITextFieldDelegate,UITextViewDelegate> {
	IBOutlet UITableView * settingsTable;
	UIPopoverController * imagePickerPopover;
	//IBOutlet UIToolbar * toolBar;
	//IBOutlet UIBarButtonItem * imageButton;
}

@property(nonatomic,retain) IBOutlet UITableView * settingsTable;
@property(nonatomic,retain) UIPopoverController * imagePickerPopover;
//@property(nonatomic,retain) IBOutlet UIToolbar * toolBar;
//@property(nonatomic,retain) IBOutlet UIBarButtonItem * imageButton;

- (void) emailFormatChanged:(id)sender;
- (void) publishTypeChanged:(id)sender;
- (void) rssEnabledChanged:(id)sender;
//- (IBAction) chooseImage;
- (IBAction) preview;

@end
