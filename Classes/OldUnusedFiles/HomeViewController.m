    //
//  HomeViewController.m
//  Untitled
//
//  Created by Robert Stewart on 4/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "HomeViewController.h"
#import "Feed.h"
#import "HomeViewItemController.h"
#import "RiverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BlankToolbar.h"
#import "Newsletter.h"
#import "NewsletterHTMLPreviewViewController.h"
#import "NewsletterSection.h"
#import "FeedItem.h"
#import "Favorites.h"

@implementation HomeViewController
@synthesize scrollView,pageControl,feeds,scrollItems,zoomedItem,riverViewController;
 

- (void) zoomIn:(HomeViewItemController*)item
{
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:0.25]; 
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn]; 
	
	// adjust frame
	zoomedOutRect=item.view.frame;
	
	item.view.frame=self.scrollView.bounds;
	
	[self.scrollView bringSubviewToFront:item.view];
	
	self.zoomedItem=item;
	
	[item.resultsTable reloadData];
	
	[UIView commitAnimations];
	
	self.scrollView.scrollEnabled=NO;
	self.pageControl.enabled=NO;
	
}

- (void) zoomOut:(HomeViewItemController*)item
{
	// adjust frame
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:0.25]; 
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn]; 
	
	// adjust if we rotated...
	
	item.view.frame=zoomedOutRect;
	
	zoomedOutRect=CGRectZero;
	
	self.zoomedItem=nil;
	
	[item.resultsTable reloadData];
	
	[UIView commitAnimations];
	
	self.scrollView.scrollEnabled=YES;
	self.pageControl.enabled=YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	//[self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	[self.view setBackgroundColor:[UIColor grayColor]];
	
	[self.scrollView setBackgroundColor:[UIColor clearColor]];
	
	self.title=@"Sources";
	
	self.navigationItem.title=@"My Sources";
	
	self.scrollItems=[[NSMutableArray alloc] init];
	
	if(feeds)
	{
		// create saved search boxes
		for(Feed  * feed in feeds)
		{
			HomeViewItemController * itemController=[[HomeViewItemController alloc] initWithNibName:@"HomeViewItem" bundle:nil];
			
			itemController.parentNavigationController=self.navigationController;
			itemController.parentHomeViewController=self;
			
			itemController.feed=feed;
			
			[self.scrollItems addObject:itemController];
			
			[self.scrollView addSubview:itemController.view];
			
			self.pageControl.numberOfPages=(([self.scrollItems count]-1) / 4)+1;
		}
	}
    
	[scrollView setCanCancelContentTouches:NO];
	
	scrollView.showsVerticalScrollIndicator=NO;
	scrollView.showsHorizontalScrollIndicator=NO;
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;
	scrollView.scrollEnabled = YES;	
	scrollView.pagingEnabled = YES;
	
	// create a toolbar to have two buttons in the right
	BlankToolbar* tools = [[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, 250, 44.01)];
	
	tools.backgroundColor=[UIColor clearColor];
	tools.opaque=NO;
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
	// create a standard "action" button
	UIBarButtonItem* bi;
	
	// create a spacer to push items to the right
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
	[bi release];
	
	// create a standard "refresh" button
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
	bi.style = UIBarButtonItemStylePlain;
	[buttons addObject:bi];
	[bi release];
	
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=30;
	[buttons addObject:bi];
	[bi release];
	
	
	// create a standard "refresh" button
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(update)];
	bi.style = UIBarButtonItemStylePlain;
	[buttons addObject:bi];
	[bi release];
	
	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	
	[buttons release];
	
	// and put the toolbar in the nav bar
	
	UIBarButtonItem * rightView=[[UIBarButtonItem alloc] initWithCustomView:tools];
	
	self.navigationItem.rightBarButtonItem = rightView;
	
	[rightView release];
	
	[tools release];
	
	self.tabBarItem.image=[UIImage imageNamed:@"icon_home.png"];
	
	
	viewMode=kHomeViewModeDashboard;
	
	UISegmentedControl * segmentedControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Dashboard",@"River",nil]];
	
	segmentedControl.segmentedControlStyle=UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex=viewMode;
	[segmentedControl addTarget:self
						 action:@selector(toggleViewMode:)
			   forControlEvents:UIControlEventValueChanged];
	
	UIBarButtonItem * leftView=[[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	
	self.navigationItem.leftBarButtonItem=leftView;
	
	[leftView release];
	//self.navigationItem.titleView=segmentedControl;
	
	[segmentedControl release];
	
	
	
	
	
	[super viewDidLoad];
}

- (void) action:(id)sender
{
	// show options to publish/preview and create new newsletter...
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"New Newsletter",@"Publish Starred Items",@"Show Preview",nil];
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
}

- (Newsletter*) newNewsletter
{
	Newsletter * n=[Newsletter new];
	
	Favorites * favorites=[[[UIApplication sharedApplication] delegate] favorites];
	
	// get starred items...
	if(zoomedItem!=nil)
	{
		Feed * feed=zoomedItem.feed;
		
		NewsletterSection * section=[NewsletterSection new];
		
		section.name=feed.name;
		
		NSMutableArray * items=[[NSMutableArray alloc] init];
		for(FeedItem * item in feed.items)
		{
			if([favorites containsItem:item])
			{
				[items addObject:item];
			}
		}
		
		section.items=items;
		
		[items release];
		
		if ([section.items count]>0) {
			[n.sections addObject:section];
		}
		
		[section release];
	}
	else 
	{
		// enumerate all feeds...
		for(Feed * feed in feeds)
		{
			NewsletterSection * section=[NewsletterSection new];
			
			section.name=feed.name;
			
			NSMutableArray * items=[[NSMutableArray alloc] init];
			for(FeedItem * item in feed.items)
			{
				if([favorites containsItem:item])
				{
					[items addObject:item];
				}
			}
			
			section.items=items;
			
			[items release];
			if ([section.items count]>0) {
				[n.sections addObject:section];
			}
			[section release];
		}
	}

	return n;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
	{
		// new newsletter
		Newsletter * newNewsletter=[self newNewsletter];
		
		// use default logo...
		/*UIImage * logo=[UIImage imageNamed:@"logo-infongen2.png"];
		
		if(logo)
		{
			newNewsletter.logoImage=logo;
		}
		
		[nil addNewNewsletter:newNewsletter];
		*/
		// edit this newsletter...
		[newNewsletter release];
	}
	
	if(buttonIndex==1)
	{
		Newsletter * newNewsletter=[self newNewsletter];
		
		
		[newNewsletter release];
	
	}
	
	if(buttonIndex==2)
	{
		Newsletter * newNewsletter=[self newNewsletter];
		
		// preview
		NewsletterHTMLPreviewViewController * previewController=[[NewsletterHTMLPreviewViewController alloc] initWithNibName:@"NewsletterHTMLPreviewView" bundle:nil];
		
		// clear html cache to make sure we only show latest changes to newsletter
		//newsletter.htmlCache=nil;
		
		previewController.newsletter=newNewsletter;
		
		[newNewsletter release];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 1.0];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
		[self.navigationController pushViewController:previewController animated:NO];
		[UIView commitAnimations];
		[previewController release];
	}
}



-(void) toggleViewMode:(id)sender
{
	//viewMode=[sender selectedSegmentIndex];
	
	if(viewMode==kHomeViewModeRiver)
	{
		// hide river...
		[self.riverViewController.view removeFromSuperview];
		self.riverViewController=nil;
		viewMode=kHomeViewModeDashboard;
		[self layoutSubviews];
		return;
	}

	if(viewMode==kHomeViewModeDashboard)
	{
		// show river
		//if(riverViewController==nil)
		//{
			self.riverViewController=[[RiverViewController alloc] initWithNibName:@"RiverView" bundle:nil];
			self.riverViewController.feeds=self.feeds;
			self.riverViewController.parentNavigationController=self.navigationController;
			self.riverViewController.view.frame=self.view.bounds;
			[self.view addSubview:self.riverViewController.view];
			[riverViewController release];
		//}
		
		viewMode=kHomeViewModeRiver;
	}
}



- (void) update
{
	 
	/*if(![self verifyAccount])
	{
		return;
	}*/
	
	if(![[[UIApplication sharedApplication] delegate] hasInternetConnection])
	{
		UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"This app requires an internet connection via WiFi or cellular network to update sources." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		updating=NO;
		
		return;
	}
		
	if(viewMode==kHomeViewModeRiver)
	{
		// update river
		[self.riverViewController update];
	}
	else 
	{
		for(HomeViewItemController * itemController in self.scrollItems)
		{
			[itemController update];
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if(viewMode==kHomeViewModeRiver)
	{
		if([self.riverViewController isUpdating])
		{
			return NO;
		}
		else 
		{
			return YES;
		}
	}
	
	
	for(HomeViewItemController * itemController in self.scrollItems)
	{
		if([itemController isUpdating])
		{
			return NO;
		}
	}
	
	return YES;
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
	
    pageControlIsChangingPage = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) 
	{
        return;
    }
	
	// switch page at 50% across
	
    CGFloat pageWidth = self.view.bounds.size.width; 
    
	int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	pageControl.currentPage = page;
}

- (void)layoutSubviews
{
	NSLog(@"layoutSubviews");
	
	if(viewMode==kHomeViewModeRiver)
	{
		self.riverViewController.view.frame=self.view.bounds;
		return;
	}
	
	if(self.zoomedItem)
	{
		self.zoomedItem.view.frame=self.scrollView.bounds;
		[self.scrollView bringSubviewToFront:self.zoomedItem.view];
	}
	
    CGRect bounds=self.scrollView.bounds;
	
	NSLog(@"bounds=%@",NSStringFromCGRect(bounds));
	
	CGFloat cx=0;
	
	// virtual border around boxes (show background from view instead of border/layer)
	CGFloat border_size=2;
	
	CGFloat boxWidth=bounds.size.width /2 - (border_size*2);
	CGFloat boxHeight=bounds.size.height/2 - (border_size*2);
	
	int boxes_per_page=4;
	
	int current_page=0;
	
	for(int box=0;box<[self.scrollItems count];box++)
	{	
		current_page = box / boxes_per_page;
		
		CGFloat x;
		CGFloat y;
		
		switch(box % 4)
		{
			case 0:
				x=border_size + (current_page * bounds.size.width);
				y=border_size;
				break;
			case 1:
				x=boxWidth + (border_size*3)+(current_page * bounds.size.width);
				y=border_size;
				break;
			case 2:
				x=border_size + (current_page * bounds.size.width);
				y=boxHeight+(border_size*3);
				break;
				
			case 3:
				x=boxWidth + (border_size*3)+(current_page * bounds.size.width);
				y=boxHeight+(border_size*3);
				break;
		}
		
		HomeViewItemController * controller = [self.scrollItems objectAtIndex:box];
		
		if(zoomedItem && [controller isEqual:zoomedItem])
		{
			NSLog(@"setting zoomedOutRect...");
			// ajdust saved rect so when we zoom back out it is correct if we rotated device after zooming
			zoomedOutRect=CGRectMake(x,y,boxWidth,boxHeight);
		}
		else
		{
			controller.view.frame=CGRectMake(x, y, boxWidth, boxHeight);
		}
		
		cx=(current_page+1) * bounds.size.width;
	}
	
	[scrollView setContentSize:CGSizeMake(cx, bounds.size.height)];
	
}

- (void) viewWillAppear:(BOOL)animated
{
	[self layoutSubviews];
}

- (void) viewDidAppear:(BOOL)animated
{
	//[self update];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	[self layoutSubviews];
	scrollView.hidden=NO;
	//[self scrollToPage:pageControl.currentPage];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// hide the scroll view during rotation
	scrollView.hidden=YES;
}

- (void)dealloc {
	[scrollView release];
	[pageControl release];
	[feeds release];
	[scrollItems release];
	[zoomedItem release];
	[riverViewController release];
    [super dealloc];
}


@end
