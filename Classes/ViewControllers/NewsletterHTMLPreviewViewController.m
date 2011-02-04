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

@implementation NewsletterHTMLPreviewViewController
@synthesize webView;

- (void) renderNewsletter
{
	int maxSynopsisSize=[[[UIApplication sharedApplication] delegate] maxNewsletterSynopsisLength];
	
	NewsletterHTMLRenderer * renderer=[[[NewsletterHTMLRenderer alloc] initWithTemplateName:[[[UIApplication sharedApplication] delegate] newsletterTemplateName] maxSynopsisSize:maxSynopsisSize embedImageData:YES] autorelease];
	
	renderer.pageWidth=640;
	
	NSString   *html= [renderer getHTML:self.newsletter];
	
	self.webView.scalesPageToFit=NO;
	
	[self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	
	[self.webView setNeedsDisplay];	
}

- (void)viewDidLoad
{
	self.view.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
	
	self.webView.frame=CGRectMake(20, 20, self.view.bounds.size.width-40,self.view.bounds.size.height-20);
	
	self.webView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.webView.layer.shadowColor=[UIColor blackColor].CGColor;
	self.webView.layer.shadowRadius=10;
	self.webView.layer.shadowOpacity=0.8;
	
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

- (void) publish:(id)sender
{
	// TODO
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
	[super dealloc];
}

@end
