#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ItemViewController.h"

@class FeedItem;

@interface DocumentEditFormViewController : ItemViewController <UITextViewDelegate>{
	FeedItem * item;
	UITextField * headlineTextField;
	UILabel * linkLabel;
	UITextView * synopsisTextView;
	//UITextView * commentsTextView;
	//UIView * commentsView;
	id delegate;
	UIColor * headlineTextColor;
	UIColor * synopsisTextColor;
	//UIColor * commentsTextColor;
	//BOOL _keyboardVisible;
	//CGFloat _keyboardHeight;
}
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) UITextField * headlineTextField;
@property(nonatomic,retain) UITextView * synopsisTextView;
//@property(nonatomic,retain) UITextView * commentsTextView;
//@property(nonatomic,retain) UIView * commentsView;
@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) UIColor * headlineTextColor;
@property(nonatomic,retain) UIColor * synopsisTextColor;
//@property(nonatomic,retain) UIColor * commentsTextColor;
- (IBAction) done:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) action:(id)sender;
//- (UIView *) createNewCommentsView:(CGRect)frame;
//- (void) doKeyboardWillShow:(CGFloat)keyboardHeight animationDuration:(NSTimeInterval)animationDuration;
//- (void) moveTextBoxesAboveKeyboard:(CGFloat)keyboardHeight;

@end
