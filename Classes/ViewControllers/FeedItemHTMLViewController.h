//
//  FeedItemHTMLViewController.h
//  Untitled
//
//  Created by Robert Stewart on 6/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@class FeedItem;
//@class EmailPublishAction;
@class ScrubberView;
@class ItemFetcher;

#define kShareSelectedTextActionSheet 1003
#define kShareImageActionSheet 1004
#define kSetItemImageActionSheet 1005

@interface FeedItemHTMLViewController : UIViewController <UIActionSheetDelegate, UIPopoverControllerDelegate, UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate> {
	NSInteger itemIndex;
	//NSArray	* items;
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
	
	//IBOutlet UITextField * commentTextField;
	UIPopoverController * organizePopover;
	
	UIWebView * tmpWebView;
	
	UIBarButtonItem * actionButton;
	IBOutlet UIButton * favoritesButton;
	FeedItem * item;
	UIBarButtonItem * publishButton;
	BOOL showPublishView;
	//IBOutlet UIScrollView * actionView;
	UIPopoverController *navPopoverController;
	UIPopoverController * imageListPopover;
	//UIPopoverController * settingsPopover;
	//EmailPublishAction * emailPublishAction;
	NSString * selectedImageSource;
	NSString * selectedImageLink;
	ScrubberView * scrubberView;
	UIMenuItem *appendSynopsisItem;
	UIMenuItem *replaceSynopsisItem;
	UIMenuItem *shareSelectedTextItem;
	
	//UIMenuItem *tweetItem;
	IBOutlet UIView * webViewContainer;
	
	NSString * shareText;
	//UIImage * shareImage;
	
	BOOL sharingText;
	BOOL _keyboardVisible;
	CGFloat _keyboardHeight;
}

//@property(nonatomic,retain) IBOutlet UITextField * commentTextField;

@property(nonatomic,retain) NSString * shareText;
//@property(nonatomic,retain) UIImage * shareImage;

@property(nonatomic,retain) NSString * selectedImageSource;
@property(nonatomic,retain) NSString * selectedImageLink;
@property(nonatomic,retain) UIPopoverController * imageListPopover;
//@property(nonatomic,retain) UIPopoverController * settingsPopover;
@property(nonatomic,retain) UIMenuItem *appendSynopsisItem;
@property(nonatomic,retain) UIMenuItem *replaceSynopsisItem;
@property(nonatomic,retain) UIMenuItem *shareSelectedTextItem;

//@property(nonatomic,retain) UIMenuItem *tweetItem;

@property(nonatomic,retain) IBOutlet UIView * webViewContainer;
@property (nonatomic, retain) UIPopoverController *navPopoverController;
@property(nonatomic) NSInteger itemIndex;
@property(nonatomic,retain) IBOutlet UIWebView * webView;
@property(nonatomic,retain) IBOutlet UIWebView * prevWebView;
@property(nonatomic,retain) IBOutlet UIWebView * nextWebView;
@property(nonatomic,retain) IBOutlet UIWebView * tmpWebView;


@property(nonatomic,retain) FeedItem * item;
//@property(nonatomic,retain) NSArray * items;
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
//@property(nonatomic,retain) IBOutlet UIScrollView * actionView;

- (IBAction) organizeTouch:(id)sender;
- (IBAction) actionTouch:(id)sender;

-(IBAction) downButtonTouch:(id)sender;
-(IBAction) upButtonTouch:(id)sender;
- (IBAction) favoritesTouch:(id)sender;
- (IBAction) commentsTouch:(id)sender;
 
- (void) renderItem;
- (NSString*) getHtml:(FeedItem*)item;
- (void) doKeyboardWillShow:(CGFloat)keyboardHeight animationDuration:(NSTimeInterval)animationDuration;
- (void) moveTextBoxesAboveKeyboard:(CGFloat)keyboardHeight;
@end
