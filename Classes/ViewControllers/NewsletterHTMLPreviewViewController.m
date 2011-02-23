#import "NewsletterHTMLPreviewViewController.h"
#import "Feed.h"
#import "Newsletter.h"
#import "NewsletterSection.h"
#import "FeedItem.h"
#import "Base64.h"
#import "NewsletterHTMLRenderer.h"
#import "NewsletterFormattingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BlankToolbar.h"
#import <MessageUI/MessageUI.h>

@implementation NewsletterHTMLPreviewViewController
@synthesize webView,activityIndicatorView,activityView,activityStatusViewController,activityTitleLabel,activityStatusLabel,activityProgressView;

- (void) renderNewsletter
{
	int maxSynopsisSize=[[[UIApplication sharedApplication] delegate] maxNewsletterSynopsisLength];
	
	NewsletterHTMLRenderer * renderer=[[[NewsletterHTMLRenderer alloc] initWithTemplateName:[[[UIApplication sharedApplication] delegate] newsletterTemplateName] maxSynopsisSize:maxSynopsisSize embedImageData:YES] autorelease];
	
	renderer.pageWidth=640;
	
	NSString   *html= [renderer getHTML:self.newsletter];
	//self.webView.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.webView.layer.bounds].CGPath;
	
	self.webView.scalesPageToFit=NO;
	
	[self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	
	[self.webView setNeedsDisplay];	
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//self.webView.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.webView.layer.bounds].CGPath;
	
}

- (void) viewDidAppear:(BOOL)animated
{
	//self.webView.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.webView.layer.bounds].CGPath;
	
	[super viewDidAppear:animated];
}
- (void)viewDidLoad
{
	self.view.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
	
	/*self.webView.frame=CGRectMake(20, 20, self.view.bounds.size.width-40,self.view.bounds.size.height-20);
	
	self.webView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.webView.layer.shadowColor=[UIColor blackColor].CGColor;
	self.webView.layer.shadowRadius=8;
	self.webView.layer.shadowOpacity=0.8;
	self.webView.layer.shadowOffset=CGSizeZero;
	self.webView.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.webView.layer.bounds].CGPath;
	*/
	self.webView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	
	//self.webView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
	
	self.navigationItem.title=newsletter.name; //@"Newsletter Preview";
	
	[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[UIView new] autorelease]] autorelease]];
	
	
	BlankToolbar * toolbar=[[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
	toolbar.opaque=NO;
	toolbar.backgroundColor=[UIColor clearColor];
	
	NSMutableArray * tools=[[NSMutableArray alloc] init];
	
	
	UIBarButtonItem * spacer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	 
	[tools addObject:spacer];
	[spacer release];
	
	UIBarButtonItem * publishButton=[[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleDone target:self action:@selector(publish:)];
	
	[tools addObject:publishButton];
	
	[publishButton release];
	
	spacer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
	spacer.width=5;
	[tools addObject:spacer];
	[spacer release];
	
	
	UIBarButtonItem * leftButton=[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(popNavigationItem)];
	
	//self.navigationItem.rightBarButtonItem=leftButton;
	[tools addObject:leftButton];
	 
	[leftButton release];
	
	[toolbar setItems:tools];
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
	
	[toolbar release];
	
	[tools release];
	
	/*UIBarButtonItem * rightButton=[[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleDone target:self action:@selector(publish)];
	
	self.navigationItem.rightBarButtonItem=rightButton;
	
	[rightButton release];
	*/
	
	 
	// add formatter to side nav...
	UINavigationController * masterNavController=  [[[UIApplication sharedApplication] delegate] masterNavController];
	
	oldTopViewController=[[masterNavController topViewController] retain];
	
	//if(![masterNavController isKindOfClass:[NewsletterFormattingViewController class]])
	//{
		NewsletterFormattingViewController * formatter=[[NewsletterFormattingViewController alloc] initWithNibName:@"NewsletterFormattingView" bundle:nil];
		formatter.newsletter=self.newsletter;
		formatter.delegate=self;
		
		[masterNavController pushViewController:formatter animated:NO];
		[formatter release];
	//}
}

- (void) updateProgress:(NSNumber*) progress
{
	activityProgressView.progress=[progress floatValue];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// did user send email? if so mark last published date of newsletter to now...
	
	if(result==MFMailComposeResultSent)
	{
		self.newsletter.lastPublished=[NSDate date]; // not sure if we need to convert timezone here...
		
		// if user setting is to clear newsletter after publish, then clear the newsletter of all items...
		/*if([[[UIApplication sharedApplication] delegate] clearOnPublish])
		{
			[self.newsletter clearAllItems];
			
			[self.newsletterTableView reloadData];
		}*/
		[self.newsletter save];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) publish:(id)sender
{
	// start publishing
	
	if(!updating)
	{
		updating=YES;
		
		if([newsletter needsUploadImages])
		{
			// do asyn upload
			[self startActivityView];
			
			// update all the saved searches associated with this page...
			[self performSelectorInBackground:@selector(publishStart) withObject:nil];
		}
		else 
		{
			[self publishEnd];
		}
	}
}

- (void)startActivityView
{
	activityView = [[UIView alloc] initWithFrame:[[self view] bounds]];
	[activityView setBackgroundColor:[UIColor blackColor]];
	[activityView setAlpha:0.5];
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[[self view] addSubview:activityView];
	
	UIView * subView=[[UIView alloc] initWithFrame:CGRectMake(activityView.center.x-300/2, activityView.center.y-150/2, 300, 150)];
	
	[subView setBackgroundColor:[UIColor blackColor]];
	[subView setAlpha:2.10];
	
	[[subView layer] setCornerRadius:24.0f];
	[[subView layer] setMasksToBounds:YES];
	
	[activityView addSubview:subView];
	
	activityTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(110, 40, 180, 20)];
	activityStatusLabel=[[UILabel alloc] initWithFrame:CGRectMake(110, 65, 180, 20)];
	
	activityStatusLabel.textColor=[UIColor whiteColor];
	activityTitleLabel.textColor=[UIColor whiteColor];
	activityStatusLabel.backgroundColor=[UIColor clearColor];
	activityTitleLabel.backgroundColor=[UIColor clearColor];
	
	activityProgressView=[[UIProgressView alloc] initWithFrame:CGRectMake(110,95,180,20)];
	
	activityProgressView.backgroundColor=[UIColor clearColor];
	
	activityStatusLabel.text=@"";
	activityTitleLabel.text=@"";
	
	[subView addSubview:activityIndicatorView];
	[subView addSubview:activityTitleLabel];
	[subView addSubview:activityStatusLabel];
	[subView addSubview:activityProgressView];
	[activityIndicatorView setFrame:CGRectMake (20,40, 80, 80)];
	[activityIndicatorView startAnimating];
	
	[subView release];
}

-(void)endActivityView
{
	[activityIndicatorView stopAnimating];
	[activityView removeFromSuperview];
}


- (void) publishStart
{
	// upload images if required
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[activityTitleLabel performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:NO];
	[activityStatusLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Uploading images..." waitUntilDone:NO];
	
	[self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:0.5] waitUntilDone:NO];
	
	[newsletter uploadImages];
	
	[self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
	
	[pool drain];
	app.networkActivityIndicatorVisible = NO;
	[self performSelectorOnMainThread:@selector(publishEnd) withObject:nil waitUntilDone:NO];
}

- (void) publishEnd
{
	[self endActivityView];
	
	updating=NO;
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	// show email client
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
	picker.mailComposeDelegate = self; // <- very important step if you want feedbacks on what the user did with your email sheet
	
	[picker setSubject:newsletter.name];
	
	// Fill out the email body text
	int maxSynopsisSize=[[[UIApplication sharedApplication] delegate] maxNewsletterSynopsisLength];
	
	NewsletterHTMLRenderer * renderer=[[[NewsletterHTMLRenderer alloc] initWithTemplateName:[[[UIApplication sharedApplication] delegate] newsletterTemplateName] maxSynopsisSize:maxSynopsisSize embedImageData:NO] autorelease];
	
	NSString   *emailBody= [renderer getHTML:self.newsletter];
	
	
	[picker setMessageBody:emailBody isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
	
	picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
	
	[self presentModalViewController:picker animated:YES];
	
	[picker release];
}








- (void) popNavigationItem
{
	[self.navigationController popViewControllerAnimated:NO];
	
	// pop away formatting control as well...
	
	UINavigationController * masterNavController=  [[[UIApplication sharedApplication] delegate] masterNavController];
	
	//UIViewController * topMasterNav=[masterNavController topViewController];
	
	if(oldTopViewController)
	{
		[masterNavController popToViewController:oldTopViewController animated:YES];
	}
	else 
	{
		[masterNavController popToRootViewControllerAnimated:YES];
	}

	/*if([topMasterNav isKindOfClass:[NewsletterFormattingViewController class]])
	{
		[masterNavController popViewControllerAnimated:NO];
	}*/
}

- (void)viewWillAppear:(BOOL)animated
{
	[self renderNewsletter];
	[super viewWillAppear:animated];
}

+ (NSString*) newsletterTemplateName
{
	NSString * newsletterFormat=[[[UIApplication sharedApplication] delegate] newsletterFormat];
	
	if(newsletterFormat==nil)
	{
		newsletterFormat=@"wide";
	}
	
	if([newsletterFormat isEqualToString:@"narrow"])
	{
		return @"NewsletterDocumentTwoColumn";
	}
	else 
	{
		return @"NewsletterDocumentOneColumn";
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{	
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//return NO;
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{	
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

- (void)dealloc 
{
	[oldTopViewController release];
	oldTopViewController=nil;
	
	if(webView)
	{
		webView.delegate=nil;
		
		[webView stopLoading];
	}
	
	[webView release];
	webView=nil;
	
	[activityStatusViewController release];
	activityStatusViewController=nil;
	
	[activityIndicatorView release];
	activityIndicatorView=nil;
	
	[activityView release];
	activityView=nil;
	
	[activityTitleLabel release];
	activityTitleLabel=nil;
	
	[activityStatusLabel release];
	activityStatusLabel=nil;
	
	[activityProgressView release];
	activityProgressView=nil;
	
	
	[super dealloc];
}

@end
