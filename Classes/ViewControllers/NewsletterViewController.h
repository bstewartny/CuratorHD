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
#define kViewModeSynopsis 2

@class Newsletter;
@class NewsletterHTMLPreviewViewController;
@class NewsletterUpdateFormViewController;
@class ActivityStatusViewController;

@interface NewsletterViewController : NewsletterBaseViewController< UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,MFMailComposeViewControllerDelegate> {
	IBOutlet UITableView * newsletterTableView;
	IBOutlet UIBarButtonItem * editMoveButton;
	IBOutlet UIButton * addImageButton;
	BOOL updating;
	int viewMode;
	UIPopoverController * addSectionPopover;
	UIPopoverController * imagePickerPopover;
	UIPopoverController * navPopoverController;
	NewsletterUpdateFormViewController * updateFormViewController;
	ActivityStatusViewController * activityStatusViewController;
	UIActivityIndicatorView * activityIndicatorView;
	UIView * activityView;
	UILabel * activityTitleLabel;
	UILabel * activityStatusLabel;
	UIProgressView * activityProgressView;
	UIToolbar * editActionToolbar;
	NSMutableArray * selectedIndexPaths;
	UIBarButtonItem * actionButton;
	UIBarButtonItem * addButton;
	UIBarButtonItem * refreshButton;
}

@property(nonatomic,retain) UIPopoverController * navPopoverController;
@property(nonatomic,retain) IBOutlet UITableView * newsletterTableView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * editMoveButton;
@property (nonatomic,retain) IBOutlet UIButton * addImageButton;
@property (nonatomic,retain) UIPopoverController * addSectionPopover;
@property(nonatomic,retain) UIPopoverController * imagePickerPopover;
@property(nonatomic,retain) NewsletterUpdateFormViewController * updateFormViewController;
@property(nonatomic,retain) ActivityStatusViewController * activityStatusViewController;
@property(nonatomic,retain) UIActivityIndicatorView * activityIndicatorView;
@property(nonatomic,retain) UIView * activityView;
@property(nonatomic,retain) UILabel * activityTitleLabel;
@property(nonatomic,retain) UILabel * activityStatusLabel;
@property(nonatomic,retain) UIProgressView * activityProgressView;
@property(nonatomic,retain) UIToolbar * editActionToolbar;

- (void) updateProgress:(NSNumber*) progress;
- (void)startActivityView;
- (void)endActivityView;
- (void)popNavigationItem;
- (void) addImageTouch:(id)sender;
- (void) addTouch:(id)sender;
- (void) closePreview;
- (void) scrollToSection:(NSString*)sectionName;
- (void)imageTouched:(id)sender;
- (void) setViewMode:(int)mode;
- (void) toggleViewMode:(id)sender;
- (void) setCurrentNewsletter:(Newsletter*)newsletter;
- (IBAction) clearNewsletterItems;
- (IBAction) deleteNewsletter;
- (IBAction) toggleEditPage:(id)sender;
- (IBAction) settings;
- (IBAction) preview;
- (IBAction) update;
-(IBAction) toggleCollapseNewsletterHeader:(id)sender;
- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
- (void) setButtonsEnabled:(BOOL)enabled;
- (void) deleteSelectedRows;
- (void) actionTouch:(id)sender;

@end
