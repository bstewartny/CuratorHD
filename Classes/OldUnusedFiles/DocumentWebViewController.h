//
//  DocumentViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/18/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@class FeedItem;
@class MetaTag;

#define kWebViewActionSheet 3

@interface DocumentWebViewController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate> {
	IBOutlet UIWebView * webView;
	IBOutlet UIBarButtonItem * backButton;
	IBOutlet UIBarButtonItem * forwardButton;
	IBOutlet UIBarButtonItem * readabilityButton;
	//IBOutlet UIBarButtonItem * stopButton;
	//IBOutlet UIBarButtonItem * reloadButton;
	IBOutlet UIBarButtonItem * selectImageButton;
	
	//IBOutlet UISegmentedControl * viewModeSegmentedControl;
	FeedItem * item;
	
	NSString * selectedImageSource;
	NSString * selectedImageLink;
}

@property(nonatomic,retain) IBOutlet UIWebView * webView;
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * backButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * forwardButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * selectImageButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * readabilityButton;
//@property(nonatomic,retain) IBOutlet UIBarButtonItem * stopButton;
//@property(nonatomic,retain) IBOutlet UIBarButtonItem * reloadButton;
//@property(nonatomic,retain) IBOutlet UISegmentedControl * viewModeSegmentedControl;

@property(nonatomic,retain) NSString * selectedImageSource;
@property(nonatomic,retain) NSString * selectedImageLink;

- (IBAction) actionTouch:(id)sender;

- (void) highlightText:(MetaTag *)tag;
- (IBAction) selectImages:(id)sender;
- (void)appendSynopsis:(id)sender;
- (void)replaceSynopsis:(id)sender;
- (void) toggleViewMode:(id)sender;
/*- (NSString *)flattenHTML:(NSString *)html;*/
- (void)doSomething:(NSTimer *)theTimer;
-(NSString*) getString:(NSString*)javascript;
-(NSInteger) getInt:(NSString*)javascript;
/*-(IBAction) getImages;*/
-(IBAction) getText;
- (void) getFull;

/*-(IBAction) edit;
*/
- (IBAction) readability;
- (NSString *)showSubviews:(UIView *)view tabs:(NSString *)tabs;

@end
