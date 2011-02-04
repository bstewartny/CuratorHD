    //
//  HelpWizardViewController.m
//  Untitled
//
//  Created by Robert Stewart on 10/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "HelpWizardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FeedItem.h"

@implementation HelpWizardViewController
@synthesize items,scrollView,pageControl,prevButton,nextButton,closeButton;

- (IBAction) prevButtonTouch:(id)sender
{
	// go to prev page
	if(self.pageControl.currentPage>0)
	{
		int prevPage=self.pageControl.currentPage-1;
		[self changeToPage:prevPage]; 
		self.pageControl.currentPage=prevPage;
		if(self.pageControl.currentPage==0)
		{
			prevButton.enabled=NO;
		}
		nextButton.enabled=YES;
	}
}

- (IBAction) nextButtonTouch:(id)sender
{
	// go to next page
	if(self.pageControl.currentPage<self.pageControl.numberOfPages-1)
	{
		int nextPage=self.pageControl.currentPage+1;
		[self changeToPage:nextPage]; 
		self.pageControl.currentPage=nextPage;
		if(pageControl.currentPage>=self.pageControl.numberOfPages-1)
		{
			nextButton.enabled=NO;
		}
		prevButton.enabled=YES;
	}
}

- (void) addToScrollView:(NSString*)title screenshot:(UIImage*)screenshot description:(NSString*)description position:(int)position
{
<<<<<<< .mine
	CGRect frame=self.scrollView.frame;
	
	int width=frame.size.width;
	int height=frame.size.height;
=======
	
	CGRect frame=self.scrollView.frame;
	NSLog(@"addToScrollView: %@",NSStringFromCGRect(frame));
	
	int width=frame.size.width;
	int height=frame.size.height;
>>>>>>> .r21310
	int left=position * width;
	
	UIImageView * imageView=[[UIImageView alloc] initWithImage:screenshot];
	imageView.frame=CGRectMake(left+(width-screenshot.size.width)/2, 28, screenshot.size.width, screenshot.size.height);
	
	// add to scrollview...
	[scrollView addSubview:imageView];
	 
	[imageView release];
	
	UILabel * titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(left+10,2,width-20,24)];
	titleLabel.font=[UIFont boldSystemFontOfSize:20];
	titleLabel.textAlignment=UITextAlignmentCenter;
	titleLabel.backgroundColor=[UIColor clearColor];
	titleLabel.textColor=[[[UIApplication sharedApplication] delegate] headlineColor];
	titleLabel.text=title;
	
	// add to scrollview...
	[scrollView addSubview:titleLabel];
	
	[titleLabel release];
	
	// calculate size of description label we need, otherwise text does not align to the top and it looks messy...
	CGSize max_size=CGSizeMake(screenshot.size.width-16, 160);
	
	CGSize description_size = [description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:max_size lineBreakMode:UILineBreakModeWordWrap];
	
	UILabel * descriptionLabel=[[UILabel alloc] initWithFrame:CGRectMake((left+(width-screenshot.size.width)/2)+12, imageView.frame.origin.y+screenshot.size.height, description_size.width,description_size.height)];
	descriptionLabel.font=[UIFont systemFontOfSize:14];
	descriptionLabel.numberOfLines=7;
	descriptionLabel.backgroundColor=[UIColor clearColor];
	descriptionLabel.textColor=[UIColor darkGrayColor];
	descriptionLabel.text=description;
	
	[scrollView addSubview:descriptionLabel];
	
	[descriptionLabel release];
	
	CGSize size=[self.scrollView contentSize];	
	size.width=width * (position+1);
	
	[self.scrollView setContentSize:size];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.navigationItem.title=@"Help";
	
	self.pageControl.imageNormal=[UIImage imageNamed:@"GreyDot.jpg"];
	self.pageControl.imageCurrent=[UIImage imageNamed:@"OrangeDot.jpg"];
	
	UIBarButtonItem * rightButton=[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(popNavigationItem)];
	
	self.navigationItem.rightBarButtonItem=rightButton;
	
	[rightButton release];
	
	[scrollView setCanCancelContentTouches:NO];
	
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = YES;
	scrollView.delegate=self;
	
	pageControl.numberOfPages=[items  count];
	pageControl.currentPage=0;
	prevButton.enabled=NO;
	
<<<<<<< .mine
=======
	//[self drawHelp];
	
>>>>>>> .r21310
	[super viewDidLoad];
}

- (void) popNavigationItem
{
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
	if(page>0)
	{
		prevButton.enabled=YES;
	}
	else 
	{
		prevButton.enabled=NO;
	}

	if(page>=pageControl.numberOfPages-1)
	{
		nextButton.enabled=NO;
	}
	else 
	{
		nextButton.enabled=YES;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
	//pageControlIsChangingPage = NO;
	CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
	if(page!=pageControl.currentPage)
	{
		pageControl.currentPage = page;
	}
}
 
- (IBAction)changePage:(id)sender 
{
	[self changeToPage:pageControl.currentPage];
}

- (void)changeToPage:(int)pageNumber 
{
	CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageNumber;
    frame.origin.y = 0;
	
	[scrollView scrollRectToVisible:frame animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void) drawHelp
{
	for(UIView * sv in [scrollView subviews])
	{
		[sv removeFromSuperview];	
	}
	
	int origPage=pageControl.currentPage;
	
	CGSize size=scrollView.contentSize;
	size.height=scrollView.frame.size.height;
	size.width=scrollView.frame.size.width;
	
	[scrollView setContentSize:size];
	
	for(int i=0;i<[items  count];i++)
	{
		TempFeedItem * item=[items objectAtIndex:i];
		[self addToScrollView:item.headline screenshot:item.image description:item.origSynopsis position:i];
	}
	
	if(origPage>0)
	{
		pageControl.currentPage=origPage;
	}
	
	if(pageControl.currentPage>0)
	{
		CGRect frame = scrollView.frame;
		frame.origin.x = frame.size.width * pageControl.currentPage;
		frame.origin.y = 0;
	
		[scrollView scrollRectToVisible:frame animated:NO];
	}
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"didRotateFromInterfaceOrientation");
	// redraw...
	[self drawHelp];
}

<<<<<<< .mine
- (void) viewDidAppear:(BOOL)animated
{
	[self drawHelp];
	[super viewDidAppear:animated];
}

=======
- (void) viewDidAppear:(BOOL)animated
{
	NSLog(@"viewDidAppear");
	[self drawHelp];
	[super viewDidAppear:animated];
}

>>>>>>> .r21310
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

- (void)dealloc {
	[items release];
	[scrollView release];
	[pageControl release];
	[prevButton release];
	[nextButton release];
	[closeButton release];
    [super dealloc];
}

@end
