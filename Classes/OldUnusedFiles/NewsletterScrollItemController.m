    //
//  NewsletterScrollItemController.m
//  Untitled
//
//  Created by Robert Stewart on 3/30/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterScrollItemController.h"
#import "NewslettersScrollViewController.h"

#import "Newsletter.h"
//#import "AppDelegate.h"
#import "NewsletterHTMLPreviewViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation NewsletterScrollItemController
@synthesize webView,newsletterButton,scrollViewController;

-(IBAction) newletterTouch:(id)sender
{
	NSLog(@"newletterTouch");
	[scrollViewController editNewsletter:self.newsletter];
	
}	
	/* //[UIView beginAnimations:nil context:nil]; 
	 //[UIView setAnimationDuration:0.5]; 
	 //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn]; 
	 
	 //CGAffineTransform transform=CGAffineTransformScale(CGAffineTransformIdentity, 3.0, 3.0);
		
	 //[webView setTransform:transform];
	 
	// [UIView commitAnimations];
	AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	  [delegate editNewsletter:self.newsletter];
	
	  //
	
	
	
	
	
	
	//UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Select newsletter" message:@"Selected newsletter" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	//[alertView show];
	//[alertView release];
}*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.view.opaque=NO;
	
	self.view.backgroundColor=[UIColor clearColor];
	
	[self renderNewsletter];
	
	//[self.view bringSubviewToFront:self.newsletterButton];
	
	
	[super viewDidLoad];
}

- (void) renderNewsletter
{
	NSString * html=[NewsletterHTMLPreviewViewController getHtml:newsletter useImageUrls:NO];
	
	webView.scalesPageToFit=YES;
	
	[webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)layoutSubviews
{
    CGFloat width=self.view.bounds.size.width;
	CGFloat height=self.view.bounds.size.height;
	
	CGFloat footer=10;
	CGFloat header=10;
	
	// layout webview - give it 4x3 aspect ratio
	CGFloat webHeight=height-footer-header;
	CGFloat webWidth=webHeight * 0.75;
	CGFloat webX=(width-webWidth)/2;
	CGFloat webY=header;
	
	self.webView.frame=CGRectMake(webX, webY, webWidth, webHeight);
	
	self.webView.layer.shadowColor=[UIColor blackColor].CGColor;
	self.webView.layer.shadowOpacity=0.8;
	self.webView.layer.shadowRadius=4;
	self.webView.layer.shadowOffset = CGSizeMake(4.0f, 4.0f);
	
	self.newsletterButton.frame=CGRectMake(webX, webY, webWidth, webHeight);
	
	//[self.view bringSubviewToFront:self.newsletterButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
	[webView release];
	[newsletterButton release];
	[scrollViewController release];
    [super dealloc];
}

@end
