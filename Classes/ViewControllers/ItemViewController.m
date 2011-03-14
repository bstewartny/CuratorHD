#import "ItemViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ItemViewController
@synthesize contentView;
@synthesize commentView;
@synthesize toolbar;
@synthesize allowComments;
@synthesize commentTextView;

#define COMMENT_VIEW_HEIGHT 100

- (id) initAllowComments:(BOOL)allowComments
{
	if(self=[super initWithNibName:@"ItemView" bundle:nil])
	{
		self.allowComments=allowComments;
	}

	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void) setupCommentView
{
	commentView.backgroundColor=[UIColor whiteColor];
	
	CGRect frame=commentView.frame;
	
	UIImage * quoteImage=[UIImage imageNamed:@"CommentQuoteImage.jpg"];
	
	UIImageView * quoteImageView=[[UIImageView alloc] initWithImage:quoteImage];
	
	quoteImageView.frame=CGRectMake(2, (frame.size.height - quoteImage.size.height) / 2, quoteImage.size.width, quoteImage.size.height);
	
	UIView * seperatorView=[[UIView alloc] initWithFrame:CGRectMake(48, 5, 2, frame.size.height-10)];
	seperatorView.backgroundColor=[UIColor grayColor];
	
	UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(52,0, frame.size.width - 60, frame.size.height)];
	
	textView.backgroundColor=[UIColor whiteColor];
	textView.textColor=[UIColor redColor];
	textView.font=[UIFont italicSystemFontOfSize:16];
	
	self.commentTextView=textView;
	
	[commentView addSubview:quoteImageView];
	[commentView addSubview:seperatorView];
	[commentView addSubview:textView];
	
	[seperatorView release];
	
	[quoteImageView release];
	
	[textView release];
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	if(allowComments)
	{
		[self setupCommentView];
	}
    else
	{
		CGRect f=self.contentView.frame;
		f.size.height+=COMMENT_VIEW_HEIGHT+5;
		self.contentView.frame=f;
		self.commentView.frame=CGRectZero;
	}
	self.commentView.layer.cornerRadius=4;
	self.contentView.layer.cornerRadius=4;
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
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
    
	[self moveViewsAboveKeyboard:keyboardHeight];
	
    [UIView commitAnimations];
}

- (void) moveViewsAboveKeyboard:(CGFloat)keyboardHeight
{
	CGRect newContentViewFrame = self.contentView.frame;
    newContentViewFrame.size.height -= keyboardHeight;
    
	CGRect newCommentsFrame=self.commentView.frame;
	newCommentsFrame.origin.y-= keyboardHeight;
	
	self.contentView.frame=newContentViewFrame;
	self.commentView.frame=newCommentsFrame;
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
	
    [self moveViewsBackDown];
	
	[UIView commitAnimations];
}

- (void) moveViewsBackDown
{
	CGFloat total_height=self.view.bounds.size.height;
	CGFloat comments_height=self.commentView.frame.size.height;
	CGFloat padding=5;
	CGFloat toolbar_height=self.toolbar.frame.size.height;
	//CGFloat status_height=20;
	
	CGRect newContentViewFrame = self.contentView.frame;
    newContentViewFrame.size.height = total_height-(toolbar_height+padding+padding+comments_height+padding);
    
	CGRect newCommentsFrame=self.commentView.frame;
	newCommentsFrame.origin.y=total_height - (comments_height+padding);
	
	self.contentView.frame=newContentViewFrame;
	self.commentView.frame=newCommentsFrame;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(_keyboardVisible)
	{
		[self moveViewsBackDown];
		
		[UIView beginAnimations:nil context:NULL];
		
		[self moveViewsAboveKeyboard:_keyboardHeight];
		
		[UIView commitAnimations];
	}
	else 
	{
		[self moveViewsBackDown];
	}
}

- (void)dealloc 
{
	[contentView release];
	[commentView release];
	[toolbar release];
	[commentTextView release];
    [super dealloc];
}

@end
