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
@synthesize item, headlineTextField,synopsisTextView,delegate,headlineTextColor,synopsisTextColor;

- (IBAction) cancel:(id)sender
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender
{
	item.headline=headlineTextField.text;
	item.synopsis=synopsisTextView.text;
	item.notes=commentTextView.text;
	
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
	//self.commentsTextColor=[UIColor redColor];
	
	// Observe keyboard hide and show notifications to resize the text view appropriately.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	self.contentView.backgroundColor=[UIColor whiteColor];
	
	UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(10,0,self.contentView.bounds.size.width-20,24)];
	textField.backgroundColor=[UIColor whiteColor];
	textField.text=self.item.headline;
	textField.placeholder=@"Item headline";
	textField.font=[UIFont boldSystemFontOfSize:17]; 
	textField.textColor=self.headlineTextColor;
	textField.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	
	//textField.borderStyle=UITextBorderStyleRoundedRect;
	
	//textField.layer.cornerRadius=4;
	
	self.headlineTextField=textField;
	
	[self.contentView  addSubview:textField];
	
	[textField release];
	
	UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(10,24+5, self.contentView.bounds.size.width-20, self.contentView.bounds.size.height-(24+10))];  
	textView.backgroundColor=[UIColor whiteColor];
	textView.font=[UIFont systemFontOfSize:14];
	textView.textColor=self.synopsisTextColor;
	textView.text=self.item.synopsis;
	//textView.layer.cornerRadius=4;
	self.synopsisTextView=textView;
	textView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.contentView  addSubview:textView];
	
	[textView release];
	
	//self.commentsView=[self createNewCommentsView:CGRectMake(10,(self.view.bounds.size.height-(kCommentsViewHeight+10)) / 2, self.view.bounds.size.width-20, kCommentsViewHeight)];
	
	//[self.view addSubview:commentsView];
	
	
	// create a toolbar to have two buttons in the right
	//BlankToolbar* tools = [[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,44)];
	//tools.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	
	toolbar.backgroundColor=[UIColor clearColor];
	toolbar.opaque=NO;
	
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
	[toolbar setItems:buttons animated:NO];
	
	[buttons release];
	
	// and put the toolbar in the nav bar
	self.commentTextView.text=self.item.notes;
	
	[self.commentTextView becomeFirstResponder];
}


/*
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self setTextViewFrames];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.commentsTextView setNeedsDisplay];
}*/

- (void)dealloc 
{
	[item release];
	[headlineTextField release];
	[synopsisTextView release];
	//[commentsTextView release];
	[headlineTextColor release];
	//[commentsView release];
	[synopsisTextColor release];
	//[commentsTextColor release];
    [super dealloc];
}

@end
