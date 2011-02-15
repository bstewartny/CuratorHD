#import <UIKit/UIKit.h>
#import "NewsletterBaseViewController.h"
#import <MessageUI/MessageUI.h>

#define kClearItemsActionSheet 1
#define kDeleteActionSheet 2
#define kClearSelectedItemsActionSheet 3

#define kEditLogoImageActionSheet 4
#define kPublishPreviewActionSheet 5

#define kViewModeSections 0
#define kViewModeHeadlines 1
//#define kViewModeSynopsis 2

@class Newsletter;
@class NewsletterHTMLPreviewViewController;
@class NewsletterSection;

@interface NewsletterViewController : NewsletterBaseViewController< UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,MFMailComposeViewControllerDelegate> {
	IBOutlet UITableView * newsletterTableView;
	UIButton * addImageButton;
	BOOL updating;
	int viewMode;
	UIPopoverController * imagePickerPopover;
	UIToolbar * editActionToolbar;
	NSMutableArray * selectedIndexPaths;
	NewsletterSection * tmpEditSection;
	
	NSArray * cachedItems;
	
}

@property(nonatomic,retain) IBOutlet UITableView * newsletterTableView;
@property (nonatomic,retain) UIButton * addImageButton;
@property(nonatomic,retain) UIPopoverController * imagePickerPopover;
@property(nonatomic,retain) UIToolbar * editActionToolbar;

- (void) addImageTouch:(id)sender;
- (void)imageTouched:(id)sender;
- (void) setViewMode:(int)mode;
- (void) toggleViewMode:(id)sender;
- (IBAction) toggleEditPage:(id)sender;
- (void) deleteSelectedRows;

@end
