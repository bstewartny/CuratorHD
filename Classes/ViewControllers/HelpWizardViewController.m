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
//#import "YouTubeView.h"

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

- (void) addHtmlToScrollView:(NSString*)title html:(NSString*)html description:(NSString*)description position:(int)position 
{
	CGRect frame=self.scrollView.frame;
	
	int width=frame.size.width;
	//int height=frame.size.height;
	int left=position * width;
	
	int html_width=500;
	int html_height=400;
	
	CGRect htmlFrame=CGRectMake(left+(width-html_width)/2, 60, html_width, html_height);
	
	UIWebView * htmlView = [[UIWebView alloc] initWithFrame:htmlFrame];
	
	[htmlView loadHTMLString:html baseURL:nil];

	[scrollView addSubview:htmlView];
	[htmlView release];
	
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
	CGSize max_size=CGSizeMake(html_width-16, 160);
	
	CGSize description_size = [description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:max_size lineBreakMode:UILineBreakModeWordWrap];
	
	UILabel * descriptionLabel=[[UILabel alloc] initWithFrame:CGRectMake((left+(width-html_width)/2)+12, htmlFrame.origin.y+html_height+10, description_size.width,description_size.height)];
	descriptionLabel.font=[UIFont systemFontOfSize:14];
	descriptionLabel.numberOfLines=7;
	descriptionLabel.backgroundColor=[UIColor clearColor];
	descriptionLabel.textColor=[UIColor darkGrayColor];
	descriptionLabel.text=description;
	
	[scrollView addSubview:descriptionLabel];
	
	[descriptionLabel release];
	
}

- (void) addVideoToScrollView:(NSString*)title url:(NSString*)url description:(NSString*)description position:(int)position
{
	//@"http://www.youtube.com/watch?v=gczw0WRmHQU" 

	
	CGRect frame=self.scrollView.frame;
	
	int width=frame.size.width;
	//int height=frame.size.height;
	int left=position * width;
	
	int video_width=475;
	int video_height=292;
	
	CGRect youTubeFrame=CGRectMake(left+(width-video_width)/2, 70, video_width, video_height);
	
	UIWebView * youTubeView = [[UIWebView alloc] initWithFrame:youTubeFrame];
	
	// HTML to embed YouTube video
	
	NSString *youTubeVideoHTML = @"<html><head>\
	<body style=\"margin:0\">\
	<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
	width=\"%0.0f\" height=\"%0.0f\"></embed>\
	</body></html>";
	//allowscriptaccess="always" allowfullscreen="true"
	// Populate HTML with the URL and requested frame size
	NSString *html = [NSString stringWithFormat:youTubeVideoHTML, url, youTubeFrame.size.width, youTubeFrame.size.height];
	
	// Load the html into the webview
	[youTubeView loadHTMLString:html baseURL:nil];
	
	[scrollView addSubview:youTubeView];
	[youTubeView release];
	
	
	
	
	
	
	
	
	
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
	/*CGSize max_size=CGSizeMake(video_width-16, 160);
	
	CGSize description_size = [description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:max_size lineBreakMode:UILineBreakModeWordWrap];
	
	UILabel * descriptionLabel=[[UILabel alloc] initWithFrame:CGRectMake((left+(width-video_width)/2)+12, youTubeFrame.origin.y+video_height+10, description_size.width,description_size.height)];
	descriptionLabel.font=[UIFont systemFontOfSize:14];
	descriptionLabel.numberOfLines=7;
	descriptionLabel.backgroundColor=[UIColor clearColor];
	descriptionLabel.textColor=[UIColor darkGrayColor];
	descriptionLabel.text=description;
	
	[scrollView addSubview:descriptionLabel];
	
	[descriptionLabel release];
	**/
	// add feedback and web site link...
	
	CGFloat button_width=260;
	CGFloat button_height=30;
	CGFloat button_left=left+(width-button_width)/2;
	
	
	UIButton * websiteButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	websiteButton.frame=CGRectMake(button_left, youTubeView.frame.origin.y+youTubeView.frame.size.height+15, button_width, button_height);
	[websiteButton setTitle:@"http://www.infongenmobile.com" forState:UIControlStateNormal];
	[scrollView addSubview:websiteButton];
	[websiteButton addTarget:self action:@selector(websiteButtonTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton * feedbackButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	feedbackButton.frame=CGRectMake(button_left, websiteButton.frame.origin.y+websiteButton.frame.size.height+15, button_width, button_height);
	[feedbackButton setTitle:@"mobile@infongen.com" forState:UIControlStateNormal];
	[scrollView addSubview:feedbackButton];
	[feedbackButton addTarget:self action:@selector(feedbackButtonTap:) forControlEvents:UIControlEventTouchUpInside];
	
	
	
	//[websiteButton release];
	
	
	
}

- (void) websiteButtonTap:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.infongenmobile.com"]];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// did user send email? if so mark last published date of newsletter to now...
	
	/*if(result==MFMailComposeResultSent)
	 {
	 
	 }*/
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) feedbackButtonTap:(id)sender
{
	if ([MFMailComposeViewController canSendMail]) {
		// create mail composer object
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		
		// make this view the delegate
		mailer.mailComposeDelegate = self;
		
		// set recipient
		[mailer setToRecipients:[NSArray arrayWithObject:@"mobile@infongen.com"]];
		
		 			
		[mailer setSubject:@"Curator HD Feedback"];
			
			// generate message body
			//NSString *body = @"whatever you want";
			
			// add to users signature
		[mailer setMessageBody:@"Thank you for using Curator HD!\n\nTell us what you think.\n\nWe'd love to hear your feedback.\n\n" isHTML:NO];
		
		
		// present user with composer screen
		[self presentModalViewController:mailer animated:YES];
		
		// release composer object
		[mailer release];
	} else {
		// alert to user there is no email support
		UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Curator HD cannot send mail at this time.  Please verify mail settings on your iPad." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}
- (void) addToScrollView:(NSString*)title screenshot:(UIImage*)screenshot description:(NSString*)description position:(int)position
{
	CGRect frame=self.scrollView.frame;
	
	int width=frame.size.width;
	//int height=frame.size.height;
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
	
	/*CGSize size=[self.scrollView contentSize];	
	size.width=width * (position+1);
	
	[self.scrollView setContentSize:size];*/
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
	size.width=scrollView.frame.size.width * [items count];
	
	[scrollView setContentSize:size];
	
	for(int i=0;i<[items  count];i++)
	{
		TempFeedItem * item=[items objectAtIndex:i];
		if(item.image==nil && item.url)
		{
			[self addVideoToScrollView:item.headline url:item.url description:item.origSynopsis position:i];
		}
		else 
		{
			[self addToScrollView:item.headline screenshot:item.image description:item.origSynopsis position:i];
		}
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
	// redraw...
	[self drawHelp];
}

- (void) viewDidAppear:(BOOL)animated
{
	[self drawHelp];
	[super viewDidAppear:animated];
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

- (void) stopVideosFromPlaying
{
	for(UIView * subView in [scrollView subviews])
	{
		if([subView isKindOfClass:[UIWebView class]])
		{
			[subView loadHTMLString:@"about:blank" baseURL:nil];
		}
	}
}

- (void)dealloc {
	NSLog(@"HelpWizardViewController release");
	[items release];
	[self stopVideosFromPlaying];
	[scrollView release];
	[pageControl release];
	[prevButton release];
	[nextButton release];
	[closeButton release];
    [super dealloc];
}

@end
