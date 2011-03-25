#import "DocumentEditFormViewController.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterItemContentView.h"
#import "Summarizer.h"
#import "BlankToolbar.h"
#import "FeedFetcher.h"
#import "AddItemsViewController.h"
#import "Folder.h"
#import "NewsletterSection.h"
#import "SHK.h"
#import "MarkupStripper.h"



#define kCommentsViewHeight 120
#define kHeadlineViewHeight 30
#define kHeadlineViewTop 50

@implementation DocumentEditFormViewController
@synthesize item, headlineTextField,synopsisTextView,delegate,headlineTextColor,synopsisTextColor;

- (IBAction) cancel:(id)sender
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}


- (void) organizeTouch:(id)sender
{
	if(item==nil) return;
	
	FolderFetcher * foldersFetcher=[[FolderFetcher alloc] init];
	
	NewsletterFetcher * newslettersFetcher=[[NewsletterFetcher alloc] init];
	
	AddItemsViewController * feedsView=[[AddItemsViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
	feedsView.navigationItem.title=@"Add Item to...";
	
	[feedsView setFoldersFetcher:foldersFetcher];
	[feedsView setNewslettersFetcher:newslettersFetcher];
	
	feedsView.delegate=self;
	
	UINavigationController * navController=[[UINavigationController alloc] initWithRootViewController:feedsView];
	
	organizePopover=[[UIPopoverController alloc] initWithContentViewController:navController];
	
	[organizePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	[navController release];
	[feedsView release];
	
	[foldersFetcher release];
	[newslettersFetcher release];
}

- (void) addToFolder:(Folder*)folder
{
	[folder addFeedItem:item];
	[folder save];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void) addToSection:(NewsletterSection*)section
{
	[section addFeedItem:item];
	[section save];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void) cancelOrganize
{
	[organizePopover dismissPopoverAnimated:YES];
}

- (IBAction) composeTouch:(id)sender
{
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Adjust Synopsis Length" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Synopsis" otherButtonTitles:@"Use original text", @"Shorten to 50 words",@"Shorten to 100 words",@"Shorten to 200 words",nil];
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
	
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	int max_words=-1;
	
	switch(buttonIndex)
	{
		case 0: // delete
			self.synopsisTextView.text=nil;
			return;
		
		case 1:
			// original
			if([item.origSynopsis length]>0)
			{
				MarkupStripper * stripper=[[MarkupStripper alloc] init];
			
				self.synopsisTextView.text=[stripper stripMarkup:item.origSynopsis];
				
				[stripper release];
			}
			else 
			{
				self.synopsisTextView.text=nil;
			}

			return;
			
		case 2:  
			max_words=50;
			break;
			
		case 3:  
			max_words=100;
			break;
			
		case 4:  
			max_words=200;
			break;
	}
	
	if(max_words>0)
	{
		NSString * synopsis=self.synopsisTextView.text;
	
		if([synopsis length]>0)
		{
			synopsis=[Summarizer shortenToMaxWords:max_words text:synopsis];
		
			self.synopsisTextView.text=synopsis;
		}
	}
}

- (IBAction) actionTouch:(id)sender
{
	if(item==nil) return;
	
	// Create the item to share (in this example, a url)
	
	SHKItem *share_item = [SHKItem URL:[NSURL URLWithString:item.url] title:item.headline];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:share_item];
	
	// Display the action sheet
	[actionSheet showFromBarButtonItem:sender animated:YES];
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
	
	self.headlineTextColor=[UIColor blackColor];
	self.synopsisTextColor=[UIColor blackColor];
	
	self.contentView.backgroundColor=[UIColor whiteColor];
	
	UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(18,4,self.contentView.bounds.size.width-36,24)];
	textField.backgroundColor=[UIColor whiteColor];
	textField.text=self.item.headline;
	textField.placeholder=@"Item headline";
	textField.font=[UIFont boldSystemFontOfSize:20]; 
	textField.textColor=self.headlineTextColor;
	textField.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	
	self.headlineTextField=textField;
	
	[self.contentView  addSubview:textField];
	
	[textField release];
	
	UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(10,28+5, self.contentView.bounds.size.width-20, self.contentView.bounds.size.height-(28+10))];  
	textView.backgroundColor=[UIColor whiteColor];
	textView.font=[UIFont systemFontOfSize:16];
	textView.textColor=self.synopsisTextColor;
	textView.text=self.item.synopsis;
	self.synopsisTextView=textView;
	textView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.contentView  addSubview:textView];
	
	[textView release];
	
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
	
	
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTouch:)];
	
	[buttons addObject:bi];
	[bi release];
	
	
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	
	bi.width=25;
	
	[buttons addObject:bi];
	[bi release];
	
	
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(organizeTouch:)];
	
	[buttons addObject:bi];
	[bi release];
	
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	
	bi.width=25;
	
	[buttons addObject:bi];
	[bi release];
	
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTouch:)];
	
	[buttons addObject:bi];
	[bi release];
	
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	
	bi.width=25;
	
	[buttons addObject:bi];
	[bi release];
	
	bi=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	[buttons addObject:bi];
	[bi release];
	
	// stick the buttons in the toolbar
	[toolbar setItems:buttons animated:NO];
	
	[buttons release];
	
	// and put the toolbar in the nav bar
	self.commentTextView.text=self.item.notes;
	
	[self.commentTextView becomeFirstResponder];
}


- (void)dealloc 
{
	[item release];
	[headlineTextField release];
	[organizePopover release];
	organizePopover=nil;
	[synopsisTextView release];
	[headlineTextColor release];
	[synopsisTextColor release];
    [super dealloc];
}

@end
