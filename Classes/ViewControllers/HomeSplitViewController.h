#import <Foundation/Foundation.h>
#import "MGSplitViewController.h"

@interface HomeSplitViewController : MGSplitViewController {
	UIViewController * homeViewController;
}

@property(nonatomic,retain) UIViewController * homeViewController;

- (void) showHomeView;
- (void) hideHomeView;
- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation;

@end
