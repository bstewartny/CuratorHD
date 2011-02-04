#import <UIKit/UIKit.h>

#import "NewsletterBaseViewController.h"

@class Newsletter ;

@interface NewsletterHTMLPreviewViewController : NewsletterBaseViewController <UIWebViewDelegate,UIActionSheetDelegate>{
	IBOutlet UIWebView * webView;
	UIViewController * oldTopViewController;
}
@property(nonatomic,retain) IBOutlet UIWebView * webView;

- (void) popNavigationItem;





 
@end
