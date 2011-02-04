    //
//  NoteEditFormViewController.m
//  Untitled
//
//  Created by Robert Stewart on 11/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NoteEditFormViewController.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterItemContentView.h"
#define kNoteHeadlineViewHeight 30
#define kNoteHeadlineViewTop 50

@implementation NoteEditFormViewController
@synthesize item, headlineTextField,synopsisTextView,delegate,headlineTextColor,synopsisTextColor;


- (IBAction) cancel
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction) dismiss
{
	item.headline=headlineTextField.text;
	item.synopsis=synopsisTextView.text;
	
	if(delegate)
	{
		[delegate redraw:item];
	}
	
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.headlineTextColor=[NewsletterItemContentView colorWithHexString:@"333333"];
	self.synopsisTextColor=[NewsletterItemContentView colorWithHexString:@"666666"];
	
	// Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(10,kNoteHeadlineViewTop,self.view.bounds.size.width-20,kNoteHeadlineViewHeight)];
	textField.backgroundColor=[UIColor clearColor];
	textField.text=self.item.headline;
	textField.font=[UIFont boldSystemFontOfSize:18]; 
	textField.textColor=self.headlineTextColor;
	textField.placeholder=@"Note title";
	
	self.headlineTextField=textField;
	
	
	
	[self.view  addSubview:textField];
	
	[textField release];
	
	UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(5,kNoteHeadlineViewTop+kNoteHeadlineViewHeight+5, self.view.bounds.size.width-20, self.view.bounds.size.height-(kNoteHeadlineViewTop+kNoteHeadlineViewHeight+10))];  
	textView.backgroundColor=[UIColor clearColor];
	textView.font=[UIFont systemFontOfSize:18];
	textView.textColor=self.synopsisTextColor;
	textView.text=self.item.synopsis;
	
	self.synopsisTextView=textView;
	
	[self.view  addSubview:textView];
	
	[textView becomeFirstResponder];
	
	[textView release];
	
	 
}
 
- (void) viewDidUnload
{
	[super viewDidUnload];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
	/*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
	 */
	
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
	
	// depending on what orientation we are, we need either height or width of keyboard
	CGFloat keyboardHeight = keyboardRect.size.height;
	
	// assume we are in other orientation
	if(keyboardHeight >= 768.0)
	{
		keyboardHeight=keyboardRect.size.width;
	}
	_keyboardHeight=keyboardHeight;
	
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
	[self doKeyboardWillShow:keyboardHeight animationDuration:animationDuration];
	
	_keyboardVisible=YES;
	
}

- (void) doKeyboardWillShow:(CGFloat)keyboardHeight animationDuration:(NSTimeInterval)animationDuration
{
	// animate in sync with keyboard animation
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
	[self moveTextBoxesAboveKeyboard:keyboardHeight];
	
    [UIView commitAnimations];
}

- (void) moveTextBoxesAboveKeyboard:(CGFloat)keyboardHeight
{
	CGRect newTextViewFrame = self.synopsisTextView.frame;
    newTextViewFrame.size.height = newTextViewFrame.size.height - keyboardHeight;
    
	self.synopsisTextView.frame=newTextViewFrame;
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
	NSDictionary* userInfo = [notification userInfo];
    
	// animate in sync with keyboard animation
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
	[self doKeyboardWillHide:animationDuration];
	
	_keyboardVisible=NO;
	
}

- (void) doKeyboardWillHide:(NSTimeInterval)animationDuration
{
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
	
    [self setTextViewFrames];
	
	[UIView commitAnimations];
}

- (void) setTextViewFrames
{
	self.synopsisTextView.frame = CGRectMake(5,kNoteHeadlineViewTop+kNoteHeadlineViewHeight+5, self.view.bounds.size.width-20, self.view.bounds.size.height-(kNoteHeadlineViewTop+kNoteHeadlineViewHeight+10));
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(_keyboardVisible)
	{
		[self setTextViewFrames];
		
		[UIView beginAnimations:nil context:NULL];
		
		[self moveTextBoxesAboveKeyboard:_keyboardHeight];
		
		[UIView commitAnimations];
	}
	else 
	{
		[self setTextViewFrames];
	}
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

 

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[item release];
	[headlineTextField release];
	[synopsisTextView release];
	[delegate release];
	[headlineTextColor release];
	[synopsisTextColor release];
	[super dealloc];
}


@end
