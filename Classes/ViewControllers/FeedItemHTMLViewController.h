#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ItemViewController.h"

@class FeedItem;
@class ScrubberView;
@class ItemFetcher;

#define kShareSelectedTextActionSheet 1003
#define kShareImageActionSheet 1004
#define kSetItemImageActionSheet 1005
@class FeedItemHTMLRenderer;

@interface FeedItemHTMLViewController : ItemViewController <UIActionSheetDelegate, UIPopoverControllerDelegate, UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate> {
	NSInteger itemIndex;
	ItemFetcher * fetcher;
	NSMutableArray * publishActions;
	IBOutlet UIBarButtonItem * backButton;
	IBOutlet UIBarButtonItem * forwardButton;
	IBOutlet UIBarButtonItem * upButton;
	IBOutlet UIBarButtonItem * downButton;
	UIActivityIndicatorView * activityView;
	IBOutlet UIWebView * webView;
	IBOutlet UIWebView * prevWebView;
	IBOutlet UIWebView * nextWebView;
	UIPopoverController * organizePopover;
	UIWebView * tmpWebView;
	UIBarButtonItem * actionButton;
	IBOutlet UIButton * favoritesButton;
	FeedItem * item;
	UIBarButtonItem * publishButton;
	BOOL showPublishView;
	UIPopoverController *navPopoverController;
	UIPopoverController * imageListPopover;
	NSString * selectedImageSource;
	NSString * selectedImageLink;
	UIMenuItem *appendSynopsisItem;
	UIMenuItem *replaceSynopsisItem;
	UIMenuItem *shareSelectedTextItem;
	NSString * shareText;
	BOOL sharingText;
	
	FeedItemHTMLRenderer * renderer;//=[[[FeedItemHTMLRenderer alloc ]init] autorelease];
	
}

@property(nonatomic,retain) NSString * shareText;
@property(nonatomic,retain) NSString * selectedImageSource;
@property(nonatomic,retain) NSString * selectedImageLink;
@property(nonatomic,retain) UIPopoverController * imageListPopover;
@property(nonatomic,retain) UIMenuItem *appendSynopsisItem;
@property(nonatomic,retain) UIMenuItem *replaceSynopsisItem;
@property(nonatomic,retain) UIMenuItem *shareSelectedTextItem;
@property (nonatomic, retain) UIPopoverController *navPopoverController;
@property(nonatomic) NSInteger itemIndex;
@property(nonatomic,retain) IBOutlet UIWebView * webView;
@property(nonatomic,retain) IBOutlet UIWebView * prevWebView;
@property(nonatomic,retain) IBOutlet UIWebView * nextWebView;
@property(nonatomic,retain) IBOutlet UIWebView * tmpWebView;
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) ItemFetcher * fetcher;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * backButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * forwardButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * upButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * downButton;
@property(nonatomic,retain) UIActivityIndicatorView * activityView;
@property(nonatomic,retain) UIBarButtonItem * actionButton;
@property(nonatomic,retain) UIBarButtonItem * publishButton;
@property(nonatomic) BOOL showPublishView;
@property(nonatomic,retain) IBOutlet UIButton * favoritesButton;

- (IBAction) organizeTouch:(id)sender;
- (IBAction) actionTouch:(id)sender;
- (IBAction) downButtonTouch:(id)sender;
- (IBAction) upButtonTouch:(id)sender;
- (IBAction) favoritesTouch:(id)sender;
- (IBAction) commentsTouch:(id)sender;
- (void) renderItem;
- (NSString*) getHtml:(FeedItem*)item;

@end
