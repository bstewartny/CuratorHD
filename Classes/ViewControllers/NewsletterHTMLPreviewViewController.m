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
#import "MarkupStripper.h"
#import "Summarizer.h"
#import "NewsletterItem.h"

@implementation NewsletterHTMLPreviewViewController
@synthesize webView,activityIndicatorView,activityView,activityStatusViewController,activityTitleLabel,activityStatusLabel,activityProgressView;

- (void) renderNewsletter
{
	if(self.view==nil || self.view.window==nil)
	{
		[self renderHtml];
		[self displayHtml];	
	}
	else 
	{
		if(!renderingHtml)
		{
			renderingHtml=YES;
			
			// The hud will dispable all input on the view
			HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
			
			// Add HUD to screen
			[self.view.window addSubview:HUD];
			
			// Regisete for HUD callbacks so we can remove it from the window at the right time
			HUD.delegate = self;
			
			HUD.labelText=@"Generating Preview...";
			
			[HUD showWhileExecuting:@selector(renderHtml) onTarget:self withObject:nil animated:YES];
		}
		else 
		{
			renderingHtml=NO;
			
			[self displayHtml];
		}
	}
}

- (void) displayHtml
{
	self.webView.scalesPageToFit=NO;
	
	if([html length]>0)
	{
		[self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	}
	else 
	{
		[self.webView loadHTMLString:@"<html><body></body></html>" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	}
	
	[self.webView setNeedsDisplay];	
}

- (void) renderHtml
{
	[html release];
	html=nil;
	
	int maxSynopsisSize=0;
	
	NewsletterHTMLRenderer * renderer=[[NewsletterHTMLRenderer alloc] initWithTemplateName:[[[UIApplication sharedApplication] delegate] newsletterTemplateName] maxSynopsisSize:maxSynopsisSize embedImageData:YES];
	
	renderer.pageWidth=-1;//640;
	
	html = [[renderer getHTMLPreview:self.newsletter maxItems:50] retain];
	
	[renderer release];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	
}

- (void)viewDidLoad
{
	self.view.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
	
	self.webView.backgroundColor=[UIColor blackColor];
	
	self.navigationItem.title=newsletter.name;
	
	[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[UIView new] autorelease]] autorelease]];
	
	BlankToolbar * toolbar=[[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
	toolbar.opaque=NO;
	toolbar.backgroundColor=[UIColor clearColor];
	
	NSMutableArray * tools=[[NSMutableArray alloc] init];
	
	UIBarButtonItem * spacer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	 
	[tools addObject:spacer];
	[spacer release];
	
	UIBarButtonItem * composeButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTouch:)];
	
	[tools addObject:composeButton];
	
	[composeButton release];
	
	spacer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
	spacer.width=25;
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
	
	[tools addObject:leftButton];
	 
	[leftButton release];
	
	[toolbar setItems:tools];
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
	
	[toolbar release];
	
	[tools release];
	
	// add formatter to side nav...
	UINavigationController * masterNavController=  [[[UIApplication sharedApplication] delegate] masterNavController];
	
	oldTopViewController=[[masterNavController topViewController] retain];
	
	NewsletterFormattingViewController * formatter=[[NewsletterFormattingViewController alloc] initWithNibName:@"NewsletterFormattingView" bundle:nil];
	formatter.newsletter=self.newsletter;
	formatter.delegate=self;
	
	[masterNavController pushViewController:formatter animated:YES];
	[formatter release];
}

- (void) updateProgress:(NSNumber*) progress
{
	activityProgressView.progress=[progress floatValue];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// did user send email? if so mark last published date of newsletter to now...
	[self dismissModalViewControllerAnimated:YES];
	
	if(result==MFMailComposeResultSent)
	{
		self.newsletter.lastPublished=[NSDate date]; // not sure if we need to convert timezone here...
		
		// if user setting is to clear newsletter after publish, then clear the newsletter of all items...
		if([[[UIApplication sharedApplication] delegate] clearOnPublish])
		{
			[self.newsletter clearAllItems];
		}
		
		[self.newsletter save];
		[self renderNewsletter];
	}
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
	int maxSynopsisSize=0;// [[[UIApplication sharedApplication] delegate] maxNewsletterSynopsisLength];
	
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
	
	if(oldTopViewController)
	{
		[masterNavController popToViewController:oldTopViewController animated:YES];
	}
	else 
	{
		[masterNavController popToRootViewControllerAnimated:YES];
	}
}

/*- (void)viewWillAppear:(BOOL)animated
{
	[self renderNewsletter];
	[super viewWillAppear:animated];
}*/
- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self renderNewsletter];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{	
	NSLog(@"didFailLoadWithError");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"shouldStartLoadWithRequest");
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{	
	NSLog(@"webViewDidFinishLoad");	
}

- (void)dealloc 
{
	[html release];
	html=nil;
	
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
