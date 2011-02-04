//
//  NoteEditFormViewController.h
//  Untitled
//
//  Created by Robert Stewart on 11/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FeedItem;


@interface NoteEditFormViewController : UIViewController <UITextViewDelegate>{
	FeedItem * item;
	UITextField * headlineTextField;
	UITextView * synopsisTextView;
	id delegate;
	UIColor * headlineTextColor;
	UIColor * synopsisTextColor;
	BOOL _keyboardVisible;
	CGFloat _keyboardHeight;
}
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) UITextField * headlineTextField;
@property(nonatomic,retain) UITextView * synopsisTextView;
@property(nonatomic,retain) id delegate;
@property(nonatomic,retain) UIColor * headlineTextColor;
@property(nonatomic,retain) UIColor * synopsisTextColor;

- (IBAction) dismiss;
- (IBAction) cancel;
- (IBAction) action:(id)sender;

- (void) doKeyboardWillShow:(CGFloat)keyboardHeight animationDuration:(NSTimeInterval)animationDuration;
- (void) moveTextBoxesAboveKeyboard:(CGFloat)keyboardHeight;
@end
