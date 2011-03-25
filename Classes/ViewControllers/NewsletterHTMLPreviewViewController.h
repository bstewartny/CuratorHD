#import <UIKit/UIKit.h>

#import "NewsletterBaseViewController.h"

@class Newsletter ;
@class ActivityStatusViewController;
@interface NewsletterHTMLPreviewViewController : NewsletterBaseViewController <MBProgressHUDDelegate,UIWebViewDelegate,UIActionSheetDelegate>{
	IBOutlet UIWebView * webView;
	UIViewController * oldTopViewController;
	UIActivityIndicatorView * activityIndicatorView;
	UIView * activityView;
	
	ActivityStatusViewController * activityStatusViewController;
	 BOOL updating;
	UILabel * activityTitleLabel;
	UILabel * activityStatusLabel;
	UIProgressView * activityProgressView;
	BOOL renderingHtml;
	NSString * html;
}
@property(nonatomic,retain) IBOutlet UIWebView * webView;
@property(nonatomic,retain) UIActivityIndicatorView * activityIndicatorView;
@property(nonatomic,retain) UIView * activityView;
@property(nonatomic,retain) ActivityStatusViewController * activityStatusViewController;
@property(nonatomic,retain) UILabel * activityTitleLabel;
@property(nonatomic,retain) UILabel * activityStatusLabel;
@property(nonatomic,retain) UIProgressView * activityProgressView;




- (void) popNavigationItem;





 
@end
