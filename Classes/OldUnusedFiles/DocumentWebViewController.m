    //
//  DocumentViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/18/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DocumentWebViewController.h"
#import "FeedItem.h"
#import "DocumentImage.h"
#import "DocumentTextViewController.h"
#import "DocumentEditViewController.h"
#import "NewslettersViewController.h"
#import "MetaTag.h"
#import "TextMatch.h"
#import "ImageResizer.h"

@implementation DocumentWebViewController
@synthesize webView,item,backButton,forwardButton,selectImageButton,readabilityButton,selectedImageSource,selectedImageLink;//,stopButton,reloadButton;

-(NSString*) getString:(NSString*)javascript
{
	if(javascript && [javascript length]>0)
	{
		return [self.webView stringByEvaluatingJavaScriptFromString:javascript];
	}
	else
	{
		return nil;
	}
}	
-(NSInteger) getInt:(NSString*)javascript
{
	NSString * s=[self getString:javascript];
	if(s && [s length]>0)
	{
		return [s intValue];
	}
	else {
		return 0;
	}
}
- (IBAction) actionTouch:(id)sender
{
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari",@"Email Link",nil];
	
	actionSheet.tag=kWebViewActionSheet;
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
	
	[actionSheet release];
}




- (void) highlightText:(MetaTag *)tag
{
	// inject javascript function to highlight content
	 				
	if(tag.matches)
	{
		for(TextMatch * textMatch in tag.matches)
		{
			[self getString:[NSString stringWithFormat:@"highlightText('%@','%@','%@');",@"yellow",@"tagclass",textMatch.text]];
		}
	}
}

- (IBAction) readability
{
	// push CSS from local disk...
	//[self getString:@"_readability_css=document.createElement('LINK');_readability_css.rel='stylesheet';_readability_css.href='readability.css';_readability_css.type='text/css';_readability_css.media='all';document.getElementsByTagName('head')[0].appendChild(_readability_css);"];
	
	NSString * path=[[NSBundle mainBundle] pathForResource:@"readability" ofType:@"css"];
	
	/*if (path) 
	{
		NSString *css = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		
		if(css)
		{
			[self getString:@"_readability_css=document.createElement('STYLE');"];
			[self getString:@"_readability_css.type='text/css';"];
			
			[self getString:[NSString stringWithFormat:@"_readability_css.innerHTML='%@'",css]];
			
			[self getString:@"document.getElementsByTagName('head')[0].appendChild(_readability_css);"];
		}
	}*/
	
	// push readability functions from local disk...
	path=[[NSBundle mainBundle] pathForResource:@"readability2" ofType:@"js"];
	
	if (path) 
	{
		NSString *javascript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		
		if(javascript)
		{
			// insert javascript functions into the document
			[self getString:javascript];
			
			// then run the code...
			[self getString:@"readStyle='style-ebook';readSize='size-large';readMargin='margin-narrow';readability.init();"];
		}
	}
	
	// needs to finish syncronously here, not async by pulling from web...
	// run readability bookmarklet to extract article text into readable text view of html...
	//NSString * bookmarklet=@"readStyle='style-ebook';readSize='size-large';readMargin='margin-narrow';_readability_script=document.createElement('SCRIPT');_readability_script.type='text/javascript';_readability_script.src='http://lab.arc90.com/experiments/readability/js/readability.js?x='+(Math.random());document.getElementsByTagName('head')[0].appendChild(_readability_script);_readability_css=document.createElement('LINK');_readability_css.rel='stylesheet';_readability_css.href='http://lab.arc90.com/experiments/readability/css/readability.css';_readability_css.type='text/css';_readability_css.media='all';document.getElementsByTagName('head')[0].appendChild(_readability_css);_readability_print_css=document.createElement('LINK');_readability_print_css.rel='stylesheet';_readability_print_css.href='http://lab.arc90.com/experiments/readability/css/readability-print.css';_readability_print_css.media='print';_readability_print_css.type='text/css';document.getElementsByTagName('head')[0].appendChild(_readability_print_css);";
	
	//[self getString:bookmarklet];
}

- (NSString *)flattenHTML:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
	// relplace <p> with line break
	// replace <br> with line break
	// replace &nbsp; with space
	// replace &amp; with &
	// replace other encodings as they come up...
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@""];
		
    } // while //
    
    return html;
}

- (IBAction) getText
{
	// get javascript file from bundle...
	
	[self readability];
	
	NSString * text=[self getString:@"document.getElementById('readability-content').textContent;"];
	
	/*if(text && [text length]>0)
	{
		SearchClient * searchClient =[[SearchClient alloc] init];
	
		NSArray * tags;
		if([text length]>25000)
		{
			tags=[searchClient getTags:[text substringToIndex:24999]];
		}
		else 
		{
			tags=[searchClient getTags:text];
		}

		if(tags && [tags count]>0)
		{
			NSString * path=[[NSBundle mainBundle] pathForResource:@"highlightText" ofType:@"js"];
	
			if (path) 
			{
				NSString * javascript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
				
				if(javascript)
				{
					// insert javascript functions into the document
					[self getString:javascript];	
				}
			}
			
			for(MetaTag * tag in tags)
			{
				[self highlightText:tag];
			}
		}
		
		[tags release];
		
		[searchClient release];
	}*/
}

/*
-(IBAction) edit
{
	DocumentEditViewController * editController=[[DocumentEditViewController alloc] initWithNibName:@"DocumentEditView" bundle:nil];
	
	editController.searchResult=self.searchResult;
	
	
	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	
	[navController pushViewController:editController animated:YES];
	[editController release];
}

-(IBAction) getImages
{
	// get # of images on page
	
	NSInteger num_images=[self getInt:@"document.images.length"];
	
	NSMutableArray *images=[[NSMutableArray alloc] init];
	
	for(int i=0;i<num_images;i++)
	{
		NSString * src=[self getString:[NSString stringWithFormat:@"document.images[%d].src",i]];
		// TODO:handle relative URLs here...
		
		NSInteger width=[self getInt:[NSString stringWithFormat:@"document.images[%d].width",i]];
		NSInteger height=[self getInt:[NSString stringWithFormat:@"document.images[%d].height",i]];
		
		// ignore small images
		if(width>16 && height>16)
		{
			DocumentImage * image=[[DocumentImage alloc] init];
			
			image.width=width;
			image.height=height;
			image.area=width * height;
			image.src=src;
			
			[images addObject:image];
			
			[image release];
		}
	}
	
	// TODO: sort by size and present user with largest images to choose from (calculate area)
	NSSortDescriptor *areaSorter = [[NSSortDescriptor alloc] initWithKey:@"area" ascending:NO];
	
	[images sortUsingDescriptors:[NSArray arrayWithObject:areaSorter]];
	
	if([images count]>10)
	{
		[images removeObjectsInRange:NSMakeRange(10, [images count]-10)];
	}
	
	DocumentImage * img;
	
	ImagePickerViewController * imgViewController=[[ImagePickerViewController alloc] initWithNibName:@"ImagePickerView" bundle:nil];
	
	NSMutableArray * array=[[NSMutableArray alloc] init];
	
	for(img in images)
	{
		UIImage * m=[img getImage];
		if(m)
		{
			img.image=m;
			
			[array addObject:img];
			
			[m release];
		}
	}
	
	imgViewController.images=array;
	
	[array release];
	
	[self.view addSubview:imgViewController.view];
	
	//[imgViewController release];
	
	// TODO: filter out images that are not "squarish" in size
	// TODO: filter out images that look like ads...
	
	
	[images release];
	
	
}
*/

- (IBAction) selectImages:(id)sender
{
	if(sender)
	{
		UIBarButtonItem * barButton=(UIBarButtonItem*)sender;
	
		barButton.enabled=NO;
	}
	
	// use javascript to highlight selectable images
	// allow user to tap image to select to add to the newsletter
	// when image is tapped, it sends a special callback to our code here...
	
	// get # of images on page
	
	NSInteger num_images=[self getInt:@"document.images.length"];
	
	for(int i=0;i<num_images;i++)
	{
		NSString * src=[self getString:[NSString stringWithFormat:@"document.images[%d].src",i]];
		
		// TODO:handle relative URLs here...
		
		if([src hasPrefix:@"http:"])
		{
			//if ([src hasSuffix:@".png"] || [src hasSuffix:@".jpg"] || [src hasSuffix:@".gif"]) 
			//{
					 
				NSInteger width=[self getInt:[NSString stringWithFormat:@"document.images[%d].width",i]];
				NSInteger height=[self getInt:[NSString stringWithFormat:@"document.images[%d].height",i]];
			
				// ignore small images (such as navigation icons, buttons, etc.)
				//if(width>32 && height>32)
				//{
					// ignore huge images (such as background images, etc.)
					//if (width<800 && height<800) {
						
						[self getString:[NSString stringWithFormat:@"document.images[%d].onclick=function(){document.location='infongen:'+(this.x-window.pageXOffset)+'$$'+(this.y-window.pageYOffset)+'$$'+this.width+'$$'+this.height+'$$'+this.src+'$$'+this.parentNode.getAttribute('href');  return false;}",i]];
						
						
					//}
				//}
			//}
		}
	}
}

- (void)viewDidLoad {
	
	UIMenuItem *appendSynopsisItem = [[[UIMenuItem alloc] initWithTitle:@"Add to Synopsis" action:@selector(appendSynopsis:)] autorelease];
	UIMenuItem *replaceSynopsisItem = [[[UIMenuItem alloc] initWithTitle:@"Replace Synopsis" action:@selector(replaceSynopsis:)] autorelease];
	
	[[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:appendSynopsisItem,replaceSynopsisItem,nil]];
	
	[self getFull];
		
	[super viewDidLoad];
}

- (void) getFull
{
	if(self.item)
	{
		if(self.item.url && [self.item.url length]>0)
		{
			if(![[[UIApplication sharedApplication] delegate] hasInternetConnection])
			{
				UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"This app requires an internet connection via WiFi or cellular network to view newsletter items." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[myAlert show];
				[myAlert release];
				
				return;
			}
			
			
			NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL
																				   URLWithString:self.item.url] 
																	  cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:90.0];
			
			[self.webView loadRequest: theRequest];
			[self.webView setNeedsDisplay];
		}
	}
}

//Sent if a web view failed to load content.
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"didFailLoadWithError");
	NSLog([error description]);
	//self.stopButton.enabled=NO;
	//self.reloadButton.enabled=YES;
	//self.selectImageButton.enabled=NO;
	//self.readabilityButton.enabled=NO;
	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	if(navController)
	{
		navController.navigationBar.topItem.title=nil;
		navController.navigationBar.topItem.rightBarButtonItem=nil;
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet:willDismissWithButtonIndex %d",buttonIndex);
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// Notifies users about errors associated with the interface
	/*switch (result)
	 {
	 case MFMailComposeResultCancelled:
	 break;
	 case MFMailComposeResultSaved:
	 break;
	 case MFMailComposeResultSent:
	 break;
	 case MFMailComposeResultFailed:
	 break;
	 
	 default:
	 {
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Publish Newsletter" message:@"Error Sending Email"
	 delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	 [alert show];
	 [alert release];
	 }
	 
	 break;
	 }*/
	[self dismissModalViewControllerAnimated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	if(actionSheet.tag==kWebViewActionSheet)
	{
		if(buttonIndex==0)
		{
			// open current URL in safari
			if(item.url && [item.url length]>0)
			{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.item.url]];
			}
		}
		if(buttonIndex==1)
		{
			// email link
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			
			picker.mailComposeDelegate = self; // <- very important step if you want feedbacks on what the user did with your email sheet
			
			[picker setSubject:item.headline];
			
			// Fill out the email body text
			NSString *emailBody = item.url;
			
			[picker setMessageBody:emailBody isHTML:NO]; // depends. Mostly YES, unless you want to send it as plain text (boring)
			
			picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
			
			[self presentModalViewController:picker animated:YES];
			
			[picker release];
			
		}
		return;
	}
	
	
	
	if(buttonIndex==0)
	{
		if (actionSheet.tag==1) 
		{
			// open link...
			if(self.selectedImageLink && [self.selectedImageLink length]>0)
			{
				// TODO: handle relative URLs here...
				if([self.selectedImageLink hasPrefix:@"http"])
				{
					NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL
																				   URLWithString:self.selectedImageLink] 
																	  cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:90.0];
			
				
					[self.webView loadRequest: theRequest];
					[self.webView setNeedsDisplay];
				}
			}
			return;
		}
	}
	
	if(self.selectedImageSource)
	{
		// set image as headline image
		NSURL *url = [NSURL URLWithString:self.selectedImageSource];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [[UIImage alloc] initWithData:data];
		
		if(img)
		{
			
			img=[ImageResizer resizeImageIfTooBig:img maxWidth:300.0 maxHeight:300.0];
			
			self.item.image=img;
		}
	}
		
}

//Sent before a web view begins loading content.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"shouldStartLoadWithRequest");
	
	// see if request is our own custom callback protocol...
	NSString * url=[[request URL] absoluteString];
	
	if([url hasPrefix:@"infongen:"])
	{
		//NSLog(url);
		
		NSArray * parts=[[url substringFromIndex:9] componentsSeparatedByString:@"$$"];
		
		//NSInteger touchX=[[parts objectAtIndex:0] intValue];
		//NSInteger touchY=[[parts objectAtIndex:1] intValue];
		//NSInteger width=[[parts objectAtIndex:2] intValue];
		//NSInteger height=[[parts objectAtIndex:3] intValue];
		
		self.selectedImageSource=[parts objectAtIndex:4];
		
		self.selectedImageLink=nil;
		
		if([parts count]>5)
		{
			self.selectedImageLink=[parts objectAtIndex:5];
		}
			
		//NSString * actionSheetTitle=@"";
		
		UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Capture Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
				 
		[actionSheet addButtonWithTitle:@"Set Headline Image"];
		
		[actionSheet showInView:self.webView];
		
		[actionSheet release];
		
		return NO;
	}
	
	return YES;
}

- (void)appendSynopsis:(id)sender
{
	NSLog(@"appendSynopsis");
	
	NSString * selectedText=[self getString:@"''+window.getSelection()"];
	
	if(selectedText && [selectedText length]>0)
	{
		if(self.item.synopsis && [self.item.synopsis length]>0)
		{
			self.item.synopsis=[NSString stringWithFormat:@"%@\n%@",self.item.synopsis,selectedText];
		}
		else
		{
			self.item.synopsis=selectedText;
		}
	}
}

- (void)replaceSynopsis:(id)sender
{
	NSLog(@"replaceSynopsis");
	
	NSString * selectedText=[self getString:@"''+window.getSelection()"];
	
	self.item.synopsis=selectedText;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	
	if(action==@selector(appendSynopsis:))
	{
		return YES;
	}
	
	if(action==@selector(replaceSynopsis:))
	{
		return YES;
	}
	
	if(action==@selector(copy:))
	{
		return YES;
	}
	
	return NO;
}

- (void)copy:(id)sender {
	NSLog(@"copy");
	
}

//Sent after a web view finishes loading content.
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"webViewDidFinishLoad");
	//self.stopButton.enabled=NO;
	//self.reloadButton.enabled=YES;
	// turn on image selection
	[self selectImages:nil];
	
	self.selectImageButton.enabled=YES;
	self.readabilityButton.enabled=YES;
	self.backButton.enabled=self.webView.canGoBack;
	self.forwardButton.enabled=self.webView.canGoForward;
	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	if(navController)
	{
		navController.navigationBar.topItem.title=nil;
		navController.navigationBar.topItem.rightBarButtonItem=nil;
	}
	
	//NSLog([self showSubviews:self.webView tabs:@""]);
	
}
/*
- (NSString *)showSubviews:(UIView *)view tabs:(NSString *)tabs {
	if (!tabs) tabs = @"";
	NSString *currStr = tabs;
	currStr = [NSString stringWithFormat:@"%@%@\n", tabs, [view class], nil];
	
	if (view.subviews && [view.subviews count] > 0) {
		tabs = [tabs stringByAppendingString:@"\t"];
		for (UIView *subview in view.subviews) {
			currStr = [currStr stringByAppendingString:[self showSubviews:subview tabs:tabs]];
		}
	}
	
	return currStr;
}*/


//Sent after a web view starts loading content.
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"webViewDidStartLoad");
	//self.stopButton.enabled=YES;
	//self.reloadButton.enabled=YES;
	self.selectImageButton.enabled=NO;
	self.readabilityButton.enabled=NO;

	UINavigationController * navController=(UINavigationController*)[self parentViewController];
	if(navController)
	{
		navController.navigationBar.topItem.title=@"Loading...";
		
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
		activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
		[activityIndicator startAnimating];
		UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
		[activityIndicator release];
		navController.navigationBar.topItem.rightBarButtonItem = activityItem;
		[activityItem release];
	
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
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

- (void) toggleViewMode:(id)sender
{
	if([sender selectedSegmentIndex]==1)
	{
		// show text view
		[self getText];
	}
	else 
	{
		// show full view
		[self getFull];
	}
}

- (void)dealloc {
	webView.delegate=nil;
	[webView release];
	[item release];
	[backButton release];
	[forwardButton release];
	[selectImageButton release];
	[readabilityButton release];
	//[_holdTimer release];
	[selectedImageSource release];
	[selectedImageLink release];
	//[stopButton release];
	//[reloadButton release];
	 
    [super dealloc];
}


@end
