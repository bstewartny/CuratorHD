#import <UIKit/UIKit.h>

@interface ItemViewController : UIViewController  {
	IBOutlet UIView * contentView;
	IBOutlet UIView * commentView;
	IBOutlet UIToolbar * toolbar;
	BOOL allowComments;
	UITextView * commentTextView;
	BOOL _keyboardVisible;
	CGFloat _keyboardHeight;
	
}
@property(nonatomic,retain) IBOutlet UIView * contentView;
@property(nonatomic,retain) IBOutlet UIView * commentView;
@property(nonatomic,retain) IBOutlet UIToolbar * toolbar;
@property(nonatomic,retain) UITextView * commentTextView;
@property(nonatomic) BOOL allowComments;
- (id) initAllowComments:(BOOL)allowComments;
- (void) doKeyboardWillShow:(CGFloat)keyboardHeight animationDuration:(NSTimeInterval)animationDuration;
- (void) moveViewsAboveKeyboard:(CGFloat)keyboardHeight;
@end
