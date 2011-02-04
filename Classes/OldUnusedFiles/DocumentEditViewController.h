//
//  DocumentEditViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kHeadlineSection 0
#define kHeadlineRow 0

#define kUrlSection 1
#define kUrlRow 0

#define kSynopsisSection 2
#define kSynopsisRow 0

#define kCommentsSection 3
#define kCommentsRow 0

#define kImageSection 4
#define kImageRow 0

@class SearchResult;

@interface DocumentEditViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate>{
	SearchResult * searchResult;
	IBOutlet UITableView * editTable;
	IBOutlet UIBarButtonItem * imageButton;
	UIPopoverController * imagePickerPopover;
	
}
@property(nonatomic,retain) IBOutlet UITableView * editTable;
@property(nonatomic,retain) UIPopoverController * imagePickerPopover;
@property(nonatomic,retain) SearchResult * searchResult;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * imageButton;

- (IBAction) getUrl;
- (void) imageTouched:(id)sender;
- (void) addImage:(id)sender;

- (IBAction) chooseImage;

@end
