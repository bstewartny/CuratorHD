    //
//  NewslettersScrollViewController.m
//  Untitled
//
//  Created by Robert Stewart on 3/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewslettersScrollViewController.h"
#import "Newsletter.h"
#import "NewsletterHTMLPreviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterScrollItemController.h"
#import "AppDelegate.h"
#import "NewsletterViewController.h"
#import "LabelledSwitch.h"

@implementation NewslettersScrollViewController
@synthesize scrollView,newsletters,scrollItems,modeControl,publishedDateLabel,titleDateLabel,titlePublishedDateLabel,deleteButton,sendButton,dateLabel,titleLabel,pageControl,toolBar ;

-(IBAction) deleteTouch:(id)sender
{
	UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Newsletter" otherButtonTitles:nil	];
	
	actionSheet.tag=kDeleteNewsletterActionSheet;
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
}

-(IBAction) sendTouch:(id)sender
{
	NSLog(@"sendTouch");
	[self editNewsletter:(Newsletter*)[self.newsletters objectAtIndex:self.pageControl.currentPage]];
	
}

- (void) editNewsletter:(Newsletter*)newsletter;
{
	//AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	//delegate.newsletter=newsletter;
	
	NewsletterViewController * newsletterView=[[NewsletterViewController alloc] initWithNibName:@"NewsletterView" bundle:nil];
	
	//[newsletterView setViewMode:YES];
	[newsletterView setViewMode:kViewModeHeadlines];
	
	newsletterView.newsletter=newsletter;
	newsletterView.title=newsletter.name;
	
	CATransition *transition = [CATransition animation];
	transition.duration = 0.5;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.subtype = kCATransitionReveal;
	
	[self.navigationController.view.layer addAnimation:transition forKey:nil];
	
	[self.navigationController pushViewController:newsletterView animated:NO];
	
	[newsletterView release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void) removeCurrentPage
{
	NewsletterScrollItemController * controller = [self.scrollItems objectAtIndex:self.pageControl.currentPage];
	
	// remove newsletter from newsletters
	[self.newsletters removeObjectAtIndex:self.pageControl.currentPage];
	
	// remove view from scroll view
	[controller.view removeFromSuperview];
	
	// remove scroll item from array
	[self.scrollItems removeObjectAtIndex:self.pageControl.currentPage];
	
	// if we are on the last page, then scroll left to previous page
	//if (self.pageControl.currentPage>0 && self.pageControl.currentPage==self.pageControl.numberOfPages-1)
	//{
	//	sel f.pageControl.currentPage=self.pageControl.currentPage-1;
	//	[self scrollToPage:self.pageControl.currentPage];
	//}
	
	self.pageControl.numberOfPages=self.pageControl.numberOfPages-1;
	
	[self displayCurrentPageInfo];
	 
	// re-adjust view
	[self layoutSubviews];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet.tag==kDeleteNewsletterActionSheet)
	{
		[self removeCurrentPage];
		
		//[self.newsletters removeObject:self.currentNewsletter];
		
		//self.currentNewsletter=nil;
		
		// remove item with animation?
		// redraw...
		
		//[UIView beginAnimations:nil context:nil];
		//[UIView setAnimationDuration:0.75];
		//[UIView setAnimationDelegate:self];
		
		//actionSheet.
		
		//[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:myview cache:YES];
		//[myview removeFromSuperview];
		//[UIView commitAnimations];
	}
	if(actionSheet.tag==kPublishNewsletterActionSheet)
	{
		if(buttonIndex==0)
		{
			// email
			// popup email form and populate with HTML
		}
		if(buttonIndex==1)
		{
			// preview HTML
		}
	}
}


- (void)viewDidLoad 
{
	scrollView.delegate = self;
	
	UIBarButtonItem * leftButton=[[UIBarButtonItem alloc] init];
	
	leftButton.style=UIBarButtonItemStyleBordered;
	
	leftButton.title=@"My Newsletters";
	
	self.navigationItem.backBarButtonItem=leftButton;
	
	self.toolBar.backgroundColor=[UIColor clearColor];
	self.toolBar.tintColor=[UIColor whiteColor];
	//self.toolBar.opaque=NO;
	
	//[self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
	[self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	
	
	//[self.view setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"corkboard.jpg"]]];
	
	//self.deleteButton.customView.backgroundColor=[UIColor whiteColor];
	//self.deleteButton.customView.opaque=YES;
	
	//self.deleteButton.customView.layer.tintColor=[UIColor whiteColor];
	//self.deleteButton.customView.backgroundColor=[UIColor whiteColor];
	//self.deleteButton.customView.layer.backgroundColor=[UIColor whiteColor];
	//self.deleteButton.customView.color=[UIColor whiteColor];
	//self.deleteButton.backgroundColor=[UIColor whiteColor];
	//self.deleteButton.opaque=YES;
	
	[self.scrollView setBackgroundColor:[UIColor clearColor]];
	
	
	
	
	
	self.title=@"Newsletters";
	self.navigationItem.title=@"My Newsletters";
	
	//self.navigationController.navigationBar.topItem.title=@"My Newsletters";

	[scrollView setCanCancelContentTouches:NO];
	
	scrollView.showsVerticalScrollIndicator=NO;
	scrollView.showsHorizontalScrollIndicator=NO;
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;
	scrollView.scrollEnabled = YES;	
	scrollView.pagingEnabled = YES;
	
	self.scrollItems=[[NSMutableArray alloc] init];
	
	self.pageControl.numberOfPages=0;
	
	for(Newsletter * n in newsletters)
	{
		[self addNewsletterPage:n];
	}
	
	if(self.pageControl.numberOfPages>1)
	{
		// bug? if i dont set 1 then 0, it wont show first page as highlighted...
		[self.pageControl setCurrentPage:1];
		[self.pageControl setCurrentPage:0];
		
		//self.pageControl.currentPage=0;
		//self.pageControl.highlighted=YES;
		[self.pageControl setNeedsLayout];
	}
	
	UIBarButtonItem *button=[[UIBarButtonItem alloc] init];
	
	button.title=@"New Newsletter";
	button.target=self;
	button.action=@selector(newNewsletter);
	
	self.navigationItem.leftBarButtonItem=button;
	
	[button release];
	
	self.tabBarItem.image=[UIImage imageNamed:@"icon_document.png"];
	
	
	
	/*LabelledSwitch * switchView=[[LabelledSwitch alloc] initWithFrame:CGRectMake(0,0,250,30) leftLabelText:@"Curate" rightLabelText:@"Publish"];
	
	[switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView=switchView;
	
	[switchView release];	
	*/
	
	
	UISegmentedControl * modeControlTmp=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Curate",@"Publish",nil]];
	modeControlTmp.segmentedControlStyle=UISegmentedControlStyleBar;
	
	modeControlTmp.selectedSegmentIndex=1;
	
	//LabelledSwitch * switchView=[[LabelledSwitch alloc] initWithFrame:CGRectMake(0,0,250,30) leftLabelText:@"Curate" rightLabelText:@"Publish"];
	
	[modeControlTmp addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView=modeControlTmp;
	
	self.modeControl=modeControlTmp;
	
	[modeControlTmp release];
	
	
	[super viewDidLoad];
}
- (void) switchChanged:(id)sender
{
	UISegmentedControl * modeControl=(UISegmentedControl *)sender;
	
	// send notification
	if (modeControl.selectedSegmentIndex==0) 
	{
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"CurateState"
		 object:nil];
	}
	else 
	{
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"PublishState"
		 object:nil];
	}
}
- (void) newNewsletter
{
	Newsletter * newNewsletter=[[Newsletter alloc] init];
	
	newNewsletter.name=@"Untitled";
	
	// use default logo...
	UIImage * logo=[UIImage imageNamed:@"logo-infongen2.png"];
	
	if(logo)
	{
		newNewsletter.logoImage=logo;
	}
	
	[self addNewNewsletter:newNewsletter];
	
	[newNewsletter release];
}

- (void)addNewNewsletter:(Newsletter*)_newsletter
{
	[self.newsletters addObject:_newsletter];
	
	[self addNewsletterPage:_newsletter];
	
	[self layoutSubviews];
	
	[self scrollToPage:self.pageControl.numberOfPages-1];
	
	[self displayCurrentPageInfo];
	
	[self editNewsletter:_newsletter];
	
	//[newNewsletter release];
}


- (void) addNewsletterPage:(Newsletter*)_newsletter
{
	NewsletterScrollItemController * item=[[NewsletterScrollItemController alloc] initWithNibName:@"NewsletterScrollItemView" bundle:nil];
	
	item.newsletter=_newsletter;
	item.scrollViewController=self;
	
	[self.scrollItems addObject:item];
	
	[self.scrollView addSubview:item.view];
	
	self.pageControl.numberOfPages=[self.scrollItems count];
	
	[item release];
}

- (void) viewWillAppear:(BOOL)animated
{
	NSLog(@"viewWillAppear");
	
	self.modeControl.selectedSegmentIndex=1;
	
	[self layoutSubviews];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{    
	return YES;
}

- (void)dealloc {
	[scrollView release];
	[newsletters release];
	[scrollItems release];
	[deleteButton release];
	[sendButton release];
	[dateLabel release];
	[titleLabel release];
	[pageControl release];
	[publishedDateLabel release];
	[toolBar release];
	[titleDateLabel release];
	[titlePublishedDateLabel release];
	[modeControl release];
	[super dealloc];
}
/*
- (UIImage*)captureView:(UIView *)view {
	//CGRect rect = [[UIScreen mainScreen] bounds];	 
	UIGraphicsBeginImageContext(view.bounds.size);	 
	CGContextRef context = UIGraphicsGetCurrentContext();	 
	[view.layer renderInContext:context];	 
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();	 
	UIGraphicsEndImageContext();	 
	return img;
}
*/
- (void)layoutSubviews
{
    CGRect bounds=self.scrollView.bounds;
	
	CGFloat cx=0;
	
	CGFloat footer=100;
	CGFloat height=bounds.size.height - footer;
	CGFloat width=bounds.size.width - 100;
	CGFloat top=50;
	
	for(int page=0;page<[self.scrollItems count];page++)
	{	
		NewsletterScrollItemController * controller = [self.scrollItems objectAtIndex:page];
		
		controller.view.frame=CGRectMake(((bounds.size.width - width) / 2)+ cx,top,width,height);
		
		[controller layoutSubviews];
		
		if(page==self.pageControl.currentPage)
		{
			[controller renderNewsletter];
		}
		
		cx+=bounds.size.width;
	}

	[scrollView setContentSize:CGSizeMake(cx, bounds.size.height)];
	
	[self displayCurrentPageInfo];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	[self layoutSubviews];
	if(self.pageControl.numberOfPages>1)
	{
		[self scrollToPage:self.pageControl.currentPage];
	}
	scrollView.hidden=NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// hide the scroll view during rotation
	scrollView.hidden=YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) 
	{
        return;
    }
	
	// switch page at 50% across
	
    CGFloat pageWidth = self.view.bounds.size.width;//-100;
    
	int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	pageControl.currentPage = page;
	
	[self displayCurrentPageInfo];
}

- (void) displayCurrentPageInfo
{
	if([self.scrollItems count]==0)
	{
		self.titleLabel.text=nil;
		self.dateLabel.text=nil;
		self.publishedDateLabel.text=nil;
		self.titleDateLabel.text=nil;
		self.titlePublishedDateLabel.text=nil;
		self.navigationItem.title=@"My Newsletters";
		//self.navigationController.navigationBar.topItem.title=@"My Newsletters";
		self.toolBar.hidden=YES;
	}
	else 
	{
		self.titleDateLabel.text=@"Last Updated:";
		self.titlePublishedDateLabel.text=@"Last Published:";
		
		Newsletter * newsletter=[self.newsletters objectAtIndex:self.pageControl.currentPage];
		
		self.toolBar.hidden=NO;
		
		self.titleLabel.text=newsletter.name;
		
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		
		//[format setDateFormat:@"MMM d, yyyy"];
		[format setDateFormat:@"MMM d, yyyy h:mm a"];
		
		if(newsletter.lastUpdated)
		{
			self.dateLabel.text=[format stringFromDate:newsletter.lastUpdated]; 
		}
		else 
		{
			self.dateLabel.text=@"Never";
		}

		if(newsletter.lastPublished)
		{
			self.publishedDateLabel.text=[format stringFromDate:newsletter.lastPublished];
		}
		else 
		{
			
			self.publishedDateLabel.text=@"Never";
		}

		[format release];
		 
		self.navigationItem.title=[NSString stringWithFormat:@"My Newsletters (%d of %d)",(self.pageControl.currentPage+1),self.pageControl.numberOfPages];
		//self.navigationController.navigationBar.topItem.title=[NSString stringWithFormat:@"My Newsletters (%d of %d)",(self.pageControl.currentPage+1),self.pageControl.numberOfPages];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

- (void) scrollToPage:(int) pageNumber
{
	CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageNumber;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)changePage:(id)sender 
{
	// 	Change the scroll view
	[self scrollToPage:pageControl.currentPage];
	
	//When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 
	[self displayCurrentPageInfo];
	//self.newsletter=[self.newsletters objectAtIndex:pageControl.currentPage];
	
    pageControlIsChangingPage = YES;
}

@end
