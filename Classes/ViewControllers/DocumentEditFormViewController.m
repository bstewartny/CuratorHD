#import "DocumentEditFormViewController.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterItemContentView.h"
#import "Summarizer.h"
#import "BlankToolbar.h"

#define kCommentsViewHeight 120
#define kHeadlineViewHeight 30
#define kHeadlineViewTop 50

@implementation DocumentEditFormViewController
@synthesize item, headlineTextField,commentsView,synopsisTextView,commentsTextView,delegate,headlineTextColor,synopsisTextColor,commentsTextColor;

- (IBAction) cancel:(id)sender
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender
{
	item.headline=headlineTextField.text;
	item.synopsis=synopsisTextView.text;
	item.notes=commentsTextView.text;
	
	[item save];
	
	if(delegate)
	{
		[delegate redraw:item];
	}
	
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//self.headlineTextColor=[NewsletterItemContentView colorWithHexString:@"336699"];
	//self.synopsisTextColor=[NewsletterItemContentView colorWithHexString:@"666666"];
	//self.commentsTextColor=[NewsletterItemContentView colorWithHexString:@"b00027"];
	self.headlineTextColor=[UIColor blackColor];
	self.synopsisTextColor=[UIColor grayColor];
	self.commentsTextColor=[UIColor redColor];
	
	// Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(10,kHeadlineViewTop,self.view.bounds.size.width-20,kHeadlineViewHeight)];
	textField.backgroundColor=[UIColor whiteColor];
	textField.text=self.item.headline;
	textField.placeholder=@"Item headline";
	textField.font=[UIFont boldSystemFontOfSize:17]; 
	textField.textColor=self.headlineTextColor;
	//textField.borderStyle=UITextBorderStyleRoundedRect;
	
	textField.layer.cornerRadius=4;
	
	self.headlineTextField=textField;
	
	[self.view  addSubview:textField];
	
	[textField release];
	
	UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(10,kHeadlineViewTop+kHeadlineViewHeight+5, self.view.bounds.size.width-20, self.view.bounds.size.height-(kHeadlineViewTop+kHeadlineViewHeight+kCommentsViewHeight+10+10))];  
	textView.backgroundColor=[UIColor whiteColor];
	textView.font=[UIFont systemFontOfSize:14];
	textView.textColor=self.synopsisTextColor;
	textView.text=self.item.synopsis;
	textView.layer.cornerRadius=4;
	self.synopsisTextView=textView;
	
	[self.view  addSubview:textView];
	
	[textView release];
	
	self.commentsView=[self createNewCommentsView:CGRectMake(10,(self.view.bounds.size.height-(kCommentsViewHeight+10)) / 2, self.view.bounds.size.width-20, kCommentsViewHeight)];
	
	[self.view addSubview:commentsView];
	
	
	// create a toolbar to have two buttons in the right
	BlankToolbar* tools = [[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,44)];
	tools.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	
	tools.backgroundColor=[UIColor clearColor];
	tools.opaque=NO;
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
	// create a standard "action" button
	UIBarButtonItem* bi;
	
	bi=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	[buttons addObject:bi];
	[bi release];
	
	// create a spacer to push items to the right
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	[buttons addObject:bi];
	[bi release];
	
	bi=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	[buttons addObject:bi];
	[bi release];
	
	
	
	
	
	/*activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
	activityView.hidden=YES;
	activityView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
	
	bi = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	
	[buttons addObject:bi];
	[bi release];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=10;
	
	[buttons addObject:bi];
	[bi release];
	
	// create a back button
	bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTouch:)];
	[buttons addObject:bi];
	bi.enabled=NO;
	self.backButton=bi;
	[bi release];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=10;
	[buttons addObject:bi];
	[bi release];
	
	// create a forward button
	bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTouch:)];
	[buttons addObject:bi];
	bi.enabled=NO;
	self.forwardButton=bi;
	[bi release];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=10;
	[buttons addObject:bi];
	[bi release];
	
	bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTouch:)];
	[buttons addObject:bi];
	bi.enabled=YES;
	
	[bi release];
	*/
	
	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	
	[buttons release];
	
	// and put the toolbar in the nav bar
	
	[self.view addSubview:tools];
	
	[tools release];
	
	[self.commentsTextView becomeFirstResponder];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (UIView *) createNewCommentsView:(CGRect)frame
{
	UIView * newView=[[[UIView alloc] initWithFrame:frame] autorelease];
	newView.backgroundColor=[UIColor whiteColor];
	newView.layer.cornerRadius=4;
	
	UIImage * quoteImage=[UIImage imageNamed:@"CommentQuoteImage.jpg"];
		
	UIImageView * quoteImageView=[[UIImageView alloc] initWithImage:quoteImage];
		
	quoteImageView.frame=CGRectMake(2, (frame.size.height - quoteImage.size.height) / 2, quoteImage.size.width, quoteImage.size.height);
		
	UIView * seperatorView=[[UIView alloc] initWithFrame:CGRectMake(48, 10, 2, frame.size.height-20)];
	seperatorView.backgroundColor=[UIColor grayColor];
		
	UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(52,5, frame.size.width - 60, frame.size.height-10)];
		
	textView.backgroundColor=[UIColor whiteColor];
	textView.textColor=[UIColor redColor]; //self.commentsTextColor;
	textView.font=[UIFont italicSystemFontOfSize:14];
		
	textView.text=self.item.notes;
	
	self.commentsTextView=textView;
		
	[newView addSubview:quoteImageView];
	[newView addSubview:seperatorView];
	[newView addSubview:textView];
	
	[seperatorView release];
	
	[quoteImageView release];
	
	[textView release];
	
	return newView;
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
    
	CGRect newCommentsFrame=self.commentsView.frame;
	newCommentsFrame.origin.y=newCommentsFrame.origin.y - keyboardHeight;
	
	self.synopsisTextView.frame=newTextViewFrame;
	self.commentsView.frame=newCommentsFrame;
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
	self.synopsisTextView.frame = CGRectMake(10,kHeadlineViewTop+kHeadlineViewHeight+5, self.view.bounds.size.width-20, self.view.bounds.size.height-(kHeadlineViewTop+kHeadlineViewHeight+kCommentsViewHeight+10+10));
    self.commentsView.frame = CGRectMake(10,self.view.bounds.size.height-(kCommentsViewHeight+10), self.view.bounds.size.width-20, kCommentsViewHeight);
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
	if(_keyboardVisible)
	{
	
	}
	else 
	{
		
		
	}
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self setTextViewFrames];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.commentsTextView setNeedsDisplay];
}

- (void)dealloc 
{
	[item release];
	[headlineTextField release];
	[synopsisTextView release];
	[commentsTextView release];
	[headlineTextColor release];
	[commentsView release];
	[synopsisTextColor release];
	[commentsTextColor release];
    [super dealloc];
}

@end
