#import <UIKit/UIKit.h>

@protocol FormViewControllerDelegate

- (void) formViewDidCancel:(NSInteger)tag;

- (void) formViewDidFinish:(NSInteger)tag withValues:(NSArray*)values;

@end


@interface FormViewController : UINavigationController {
	
}

- (id) initWithTitle:(NSString*)title tag:(NSInteger)tag delegate:(id)delegate names:(NSArray*)names andValues:(NSArray*)values;

@end
