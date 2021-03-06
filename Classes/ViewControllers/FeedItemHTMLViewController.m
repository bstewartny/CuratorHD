#import "FeedItemHTMLViewController.h"
#import "FeedItem.h"
#import "Base64.h"
#import "BlankToolbar.h"
#import "Feed.h"
#import "FeedItemDictionary.h"
#import "UICustomSwitch.h"
#import "CommentsEditViewController.h"
#import "LabelledSwitch.h"
#import <QuartzCore/QuartzCore.h>
#import "Newsletter.h"
#import "PublishAction.h"
#import "FeedGroup.h"
#import "NewsletterPublishAction.h"
#import "FolderPublishAction.h"
#import "NewsletterSection.h"
#import "EmailPublishAction.h"
#import "TumblrPublishAction.h"
#import "InstapaperPublishAction.h"
#import "TwitterPublishAction.h"
#import "FacebookPublishAction.h"
#import "DeliciousPublishAction.h"
#import "ImageResizer.h"
#import "ScrubberView.h"
#import "ItemFetcher.h"
#import "FeedFetcher.h"
#import "Folder.h"
#import "RssFeedItem.h"
#import "ImageListViewController.h"
#import "NewsletterItem.h"
#import "SHKTumblr.h"
#import "SHKTwitter.h"
#import "TwitterClient.h"
#import "SHKFacebook.h"
#import "SHKGoogleReader.h"
#import "WebViewAdditions.h"
#import "NewsletterHTMLPreviewViewController.h"
#import "EmailHTMLRenderer.h"
#import "DocumentHTMLRenderer.h"
#import "SHK.h"
#import "AddItemsViewController.h"

#define SWIPE_DURATION 0.30

@implementation FeedItemHTMLViewController
@synthesize item,fetcher,shareText,imageListPopover,prevWebView,nextWebView,tmpWebView,showPublishView,appendSynopsisItem,shareSelectedTextItem,replaceSynopsisItem,selectedImageSource,selectedImageLink,navPopoverController,publishButton,favoritesButton,itemIndex,webView,backButton,forwardButton,upButton,downButton,actionButton,activityView;

-(NSString*) getString:(NSString*)javascript
{
	if(javascript && [javascript length]>0)
	{
		return [[self currentWebView] stringByEvaluatingJavaScriptFromString:javascript];
	}
	else
	{
		return nil;
	}
}	

- (void) renderItem
{
	[self renderItemAnimated:NO swipeDirection:nil];
}

- (void) renderItemAnimated:(BOOL)animated swipeDirection:(NSString*)transitionDirection;
{
	int count=[fetcher count];
	
	sharingText=NO;
	 
	self.shareText=nil;
	
	if(count>0)
	{
		if(itemIndex >=count) return;
	}
	else 
	{
		itemIndex=0;
	}

	// if we modified comments on previous item, save comments...
	if(item)
	{
		if(allowComments)
		{
			if([item.notes length]>0)
			{
				if(![item.notes isEqualToString:self.commentTextView.text])
				{
					item.notes=self.commentTextView.text;
					[item save];
				}
			}
			else 
			{
				if([self.commentTextView.text length]>0)
				{
					item.notes=self.commentTextView.text;
					[item save];
				}
			}

		}
	}
	
	
	if(count>0)
	{
		FeedItem * tmp_item=[fetcher itemAtIndex:itemIndex];
	
		[tmp_item markAsRead];
		
		self.item=tmp_item;
	}
	else 
	{
		self.item =nil;
	}

	if(item)
	{
		[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"SelectItem"
		object:self.item];
		
		if(allowComments)
		{
			self.commentTextView.text=self.item.notes;
		}
	}
	else 
	{
		if(allowComments)
		{
			self.commentTextView.text=nil;
		}
	}

	// remember last item so we can save and revisit on app restart...
	if(fetcher)
	{
		[[[UIApplication sharedApplication] delegate] setFetcher:fetcher];
		[[[UIApplication sharedApplication] delegate] setItemIndex:itemIndex];
	}
	
	self.downButton.enabled=(itemIndex < count-1);
	self.upButton.enabled=(itemIndex > 0);
	
	if(tmpWebView)
	{
		NSLog(@"tmpWebView!=null, remove and stop...");
		if(tmpWebView.superview)
		{
			NSLog(@"stop tmpWebView and remove from superview");
			[self removeSwipeGesturesFromWebView:tmpWebView];
			[tmpWebView stopLoading];
			[tmpWebView removeFromSuperview];
			// TODO: release and set to nil here???
		}
	}
	
	[self.webView stopLoading];
	
	// we dont want feed HTML to scale to fit because font will be too small in some cases...
	self.webView.scalesPageToFit=NO;
	
	prevWebView.scalesPageToFit=NO;
	nextWebView.scalesPageToFit=NO;
	
	if(animated)
	{
		NSString * html=[self getHtml:item];
		NSURL * baseUrl=[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
		
		UIWebView * webViewToClear;
		
		[CATransaction begin];
		
		CATransition *animation;
		
		animation = [CATransition animation];
		animation.type = kCATransitionPush;
		animation.subtype=transitionDirection;
		animation.duration = SWIPE_DURATION;
	
		if([transitionDirection isEqualToString:kCATransitionFromRight])
		{
			// go next
			
			[contentView bringSubviewToFront:nextWebView];
			
			[[contentView layer] addAnimation:animation forKey:@"myanimationkey"];
			
			id tmp=prevWebView;
			
			prevWebView=webView;
			webView=nextWebView;
			
			[webView loadHTMLString:html baseURL:baseUrl];
			
			nextWebView=tmp;
			
			webViewToClear=nextWebView;
			
			[webView setNeedsDisplay];
		}
		else 
		{
			// go prev
			
			[contentView bringSubviewToFront:prevWebView];
			
			[[contentView layer] addAnimation:animation forKey:@"myanimationkey"];
		
			id tmp=nextWebView;
			
			nextWebView=webView;
			webView=prevWebView;
			
			[webView loadHTMLString:html baseURL:baseUrl];
			
			prevWebView=tmp;
			
			webViewToClear=prevWebView;
			
			[webView setNeedsDisplay];
		}

		[CATransaction commit];
		
		[webViewToClear loadHTMLString:@"<html><body></body></html>" baseURL:baseUrl];
		[webViewToClear setNeedsDisplay];
	}
	else 
	{
		[self.webView loadHTMLString:[self getHtml:item] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
		[self.webView setNeedsDisplay];	
	}
}

- (IBAction) commentsTouch:(id)sender
{
	// add or edit comments of item...
	if(item==nil) return;
	
	CommentsEditViewController *controller = [[CommentsEditViewController alloc] initWithNibName:@"CommentsEditView" bundle:nil];
	
	controller.item=item;
	
	controller.delegate=self;
	
	[controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[controller setModalPresentationStyle:UIModalPresentationFormSheet];
	
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void) redraw
{
	if(item==nil) return;
	
	NSString   *html = [self getHtml:item]; 
	
	self.webView.scalesPageToFit=YES;
	
	[self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	
	[self.webView setNeedsDisplay];	
}

- (IBAction) favoritesTouch:(id)sender
{
	if(fetcher==nil) return;
	if(item==nil) return;
	
	UIButton * button=(UIButton*)sender;
	
	FeedItemDictionary * favorites=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	if([favorites containsItem:item])
	{
		[favorites removeItem:item];
		[button setImage:[UIImage imageNamed:@"Unchecked-Transparent.png"] forState:UIControlStateNormal];
	}
	else 
	{
		[button setImage:[UIImage imageNamed:@"accept.png"] forState:UIControlStateNormal];
		[favorites addItem:item];
	}
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void) publishAction
{
	self.shareText=nil;
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

-(void)handleNotification:(NSNotification *)pNotification
{
	if([pNotification.name isEqualToString:@"ReloadActionData"])
	{
		self.shareText=nil;
	}
}

- (NSString*) getSelectedText
{
	NSString * selectedText=[self getString:@"''+window.getSelection()"];
	
	self.shareText=selectedText;
	
	if([selectedText length]>0)
	{
		UIWebView * wv=[self currentWebView];

		if(wv)
		{
			// close edit menu
			wv.userInteractionEnabled = NO;
			wv.userInteractionEnabled = YES;
			[wv resignFirstResponder];
		}
	}
	
	return selectedText;
}

- (void) shareSelectedText:(id)sender
{
	NSString * selectedText=[self getSelectedText];
	
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Share Selected Text" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Email",@"Facebook",@"Google Reader",@"Twitter",@"Tumblr",nil];
								  
	actionSheet.tag=kShareSelectedTextActionSheet;
	
	[actionSheet showInView:[self currentWebView]];
	
	[actionSheet release];
	
}

- (void)appendSynopsis:(id)sender
{
	NSString * selectedText=[self getString:@"''+window.getSelection()"];
	
	if(selectedText && [selectedText length]>0)
	{
		if(self.item)
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
}

- (void)replaceSynopsis:(id)sender
{
	NSString * selectedText=[self getString:@"''+window.getSelection()"];
	
	if(self.item)
	{
		self.item.synopsis=selectedText;
	}
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	
	if(sharingText) return NO;
	 
	if(action==@selector(appendSynopsis:))
	{
		return [self.item isKindOfClass:[NewsletterItem class]];
	}

	if(action==@selector(replaceSynopsis:))
	{
		return [self.item isKindOfClass:[NewsletterItem class]];
	}

	if(action==@selector(shareSelectedText:))
	{
		return YES;
	}
	 
	if(action==@selector(copy:))
	{
		return YES;
	}
	
	return NO;
}

- (void)copy:(id)sender 
{
	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	renderer=[[FeedItemHTMLRenderer alloc ]init];
	
	renderer.embedImageData=YES; // embed twitter image inline instead of loading via http
	
	webView=[[UIWebView alloc] init];
	webView.delegate=self;
	webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	webView.frame=self.contentView.bounds;
	[self.contentView addSubview:webView];
	
	prevWebView=[[UIWebView alloc] init];
	prevWebView.delegate=self;
	prevWebView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	prevWebView.frame=self.contentView.bounds;
	[self.contentView addSubview:prevWebView];
	
	nextWebView=[[UIWebView alloc] init];
	nextWebView.delegate=self;
	nextWebView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	nextWebView.frame=self.contentView.bounds;
	[self.contentView addSubview:nextWebView];
	
	contentView.contentMode=UIViewContentModeRedraw;
	
	[contentView setNeedsLayout];
	
	downButton.enabled=NO;
	upButton.enabled=NO;
	
	[self setupToolbar];
	
	[contentView bringSubviewToFront:webView];

	// use swipes left and right to navigate up/down through feed items...
	
	[self attacheSwipeGesturesToWebView:webView];
	[self attacheLongPressGestureToWebView:webView];
	
	[self attacheSwipeGesturesToWebView:prevWebView];
	[self attacheLongPressGestureToWebView:prevWebView];
	
	[self attacheSwipeGesturesToWebView:nextWebView];
	[self attacheLongPressGestureToWebView:nextWebView];
}

- (void) setupToolbar
{
	toolbar.backgroundColor=[UIColor clearColor];
	toolbar.opaque=NO;
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
	// create a standard "action" button
	UIBarButtonItem* bi;
	
	bi=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	[buttons addObject:bi];
	[bi release];
	
	// create a spacer to push items to the right
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	[buttons addObject:bi];
	[bi release];
	
	activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
	activityView.hidden=YES;
	activityView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
	
	bi=[[UIBarButtonItem alloc] initWithCustomView:activityView];
	
	[buttons addObject:bi];
	
	[bi release];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=10;
	
	[buttons addObject:bi];
	[bi release];
	
	// create a back button
	bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTouch:)];
	[buttons addObject:bi];
	bi.enabled=NO;
	self.backButton=bi;
	[bi release];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=5;
	[buttons addObject:bi];
	[bi release];
	
	// create a forward button
	bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTouch:)];
	[buttons addObject:bi];
	bi.enabled=NO;
	self.forwardButton=bi;
	[bi release];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=10;
	[buttons addObject:bi];
	[bi release];
	
	bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(organizeTouch:)];
	[buttons addObject:bi];
	bi.enabled=YES;
	
	[bi release];
	
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=20;
	[buttons addObject:bi];
	[bi release];
	
	bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTouch:)];
	[buttons addObject:bi];
	bi.enabled=YES;
	
	[bi release];
	
	// stick the buttons in the toolbar
	[toolbar setItems:buttons animated:NO];
	
	[buttons release];
}

- (void) done:(id)sender
{
	[self cancelOrganize];
	
	if(allowComments)
	{
		if(self.item)
		{
			if([self.item.notes length]>0)
			{
				if(![self.item.notes isEqualToString:self.commentTextView.text])
				{
					self.item.notes=self.commentTextView.text;
					[self.item save];
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"UpdateFeedView"
					 object:nil];
					
				}
			}
			else 
			{
				if([self.commentTextView.text length]>0)
				{
					self.item.notes=self.commentTextView.text;
					[self.item save];
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"UpdateFeedView"
					 object:nil];
				}
			}
		}
	}
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	
}

- (void) attacheSwipeGesturesToWebView:(UIWebView*)wv
{
	UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction:)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRight.delegate = self;
	[wv addGestureRecognizer:swipeRight];
	[swipeRight release];
	
	UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeLeft.delegate = self;
	[wv addGestureRecognizer:swipeLeft];
	[swipeLeft release];
}

- (void) attacheLongPressGestureToWebView:(UIWebView*)wv
{
	UILongPressGestureRecognizer *tap=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	tap.delegate=self;
	[wv addGestureRecognizer:tap];
	[tap release];
}

- (void) tapAction:(UILongPressGestureRecognizer*)recognizer
{
	if(recognizer.state==UIGestureRecognizerStateBegan)
	{	   
		@try 
		{
			UIWebView * wv=recognizer.view;
			
			CGPoint windowPoint=[recognizer locationInView:nil];
			
			CGPoint webViewPoint=[recognizer locationInView:wv];
			
			CGPoint convertedPoint = [wv convertPoint:windowPoint fromView:nil];
			
			// convert point from view to HTML coordinate system
			CGPoint offset  = [wv scrollOffset];
			
			CGSize viewSize = [wv frame].size;
			
			CGSize windowSize = [wv windowSize];
			
			CGFloat f = windowSize.width / viewSize.width;
			
			convertedPoint.x = convertedPoint.x * f + offset.x;
			convertedPoint.y = convertedPoint.y * f + offset.y;
			
			NSString *path = [[NSBundle mainBundle] pathForResource:@"tools" ofType:@"js"];
			NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
			
			[wv stringByEvaluatingJavaScriptFromString: jsCode];
			
			// get the Tags at the touch location
			NSString *tags = [wv stringByEvaluatingJavaScriptFromString:
							  [NSString stringWithFormat:@"curatorHDGetHTMLElementsAtPoint(%i,%i);",(NSInteger)convertedPoint.x,(NSInteger)convertedPoint.y]];
			
			NSString * href=[wv stringByEvaluatingJavaScriptFromString:
							 [NSString stringWithFormat:@"curatorHrefAtPoint(%i,%i);",(NSInteger)convertedPoint.x,(NSInteger)convertedPoint.y]];
			
			NSString * t=[wv stringByEvaluatingJavaScriptFromString:
							 [NSString stringWithFormat:@"curatorTitleAtPoint(%i,%i);",(NSInteger)convertedPoint.x,(NSInteger)convertedPoint.y]];
			
			NSString * src=[wv stringByEvaluatingJavaScriptFromString:
							 [NSString stringWithFormat:@"curatorImgSrcAtPoint(%i,%i);",(NSInteger)convertedPoint.x,(NSInteger)convertedPoint.y]];
			
			if([src length]>0)
			{
				self.selectedImageSource=src;
				
				self.selectedImageLink=href;
				
				if([self.item isKindOfClass:[NewsletterItem class]])
				{
					UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Share or Select Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Set Item Image",@"Email",@"Facebook",@"Twitter",@"Tumblr",nil];
					
					actionSheet.tag=kSetItemImageActionSheet;
					
					[actionSheet showFromRect:CGRectMake(webViewPoint.x, webViewPoint.y, 10, 10) inView:wv animated:YES];
					 
					[actionSheet release];
				}
				else 
				{
					UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Share Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Email",@"Facebook",@"Twitter",@"Tumblr",nil];
					
					actionSheet.tag=kShareImageActionSheet;
					
					[actionSheet showFromRect:CGRectMake(webViewPoint.x, webViewPoint.y, 10, 10) inView:wv animated:YES];
					
					[actionSheet release];
				}
			}
			else 
			{
				NSLog(@"No image source found.");
			}

		}
		@catch (NSException * e) 
		{
			NSLog(@"error in tapAction: %@",[e userInfo]);
		}
		@finally 
		{
		}
	}
}

- (void) removeSwipeGesturesFromWebView:(UIWebView*)wv
{
	NSArray * gr=[NSArray arrayWithArray:[wv gestureRecognizers]];
	for(UIGestureRecognizer * r in gr)
	{
		[r reset];
		[r setEnabled:NO];
		[r removeTarget:nil action:NULL];
		[wv removeGestureRecognizer:r];
		[r setEnabled:NO];
	}
}

- (void) photoTouch:(id)sender
{
	if(self.item)
	{
		if(![[[UIApplication sharedApplication] delegate] hasInternetConnection])
		{
			UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"No internet connection" message:@"Cannot browse images without an internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			return;
		}
		
		ImageListViewController * imageList=[[ImageListViewController alloc] init];
	
		imageList.item=self.item;
		imageList.delegate=self;
		
		[imageListPopover dismissPopoverAnimated:NO];
		
		[imageListPopover release];
		
		imageListPopover=[[UIPopoverController alloc] initWithContentViewController:imageList];
		
		[imageListPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
		
		[imageList release];
	}
}

- (void) imageListViewController:(ImageListViewController*)controller didFinishPickingImage:(UIImage*)image
{
	// Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imageListPopover dismissPopoverAnimated:YES];
	
	image=[ImageResizer resizeImageIfTooBig:image maxWidth:300.0 maxHeight:300.0];
	
	item.image=image;
	item.imageUrl=nil;
	[item save];	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)swipeRightAction:(UIGestureRecognizer*)recognizer
{
	if(recognizer.state==UIGestureRecognizerStateRecognized)
	{
		[self upButtonTouch:nil];
	}
}

- (void)swipeLeftAction:(UIGestureRecognizer*)recognizer
{
	if(recognizer.state==UIGestureRecognizerStateRecognized)
	{
		[self downButtonTouch:nil];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[popoverController release];
	popoverController=nil;
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
	FeedItem * tmp=[self currentItem];
	tmp.synopsis=[item.origSynopsis flattenHTML];
	
	[folder addFeedItem:tmp];
	[folder save];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void) addToSection:(NewsletterSection*)section
{
	FeedItem * tmp=[self currentItem];
	tmp.synopsis=[item.origSynopsis flattenHTML];

	[section addFeedItem:tmp];
	[section save];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void) cancelOrganize
{
	[organizePopover dismissPopoverAnimated:YES];
}

- (IBAction) actionTouch:(id)sender
{
	if(item==nil) return;
	
	// Create the item to share (in this example, a url)
	SHKItem *item = [SHKItem URL:[self currentURL] title:[self currentTitle]];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromBarButtonItem:sender animated:YES];
}

- (UIWebView*) currentWebView
{
	if(tmpWebView && tmpWebView.superview)
	{
		return tmpWebView;
	}
	else 
	{
		return webView;
	}
}

- (NSString * )currentTitle
{
	return [self webViewTitle:[self currentWebView]];
}

- (NSString*)webViewTitle:(UIWebView*)wv
{
	NSString * newTitle=[wv stringByEvaluatingJavaScriptFromString:@"document.title"];
	
	if(newTitle)
	{
		newTitle=[newTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		newTitle=[newTitle stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	}
	
	return newTitle;
}

- (FeedItem*) currentItem
{
	BOOL hasSelectedText=NO;
	
	// see if user has selected some text from the synopsis...
	NSString * selectedText;
	
	// did we navigate from original item?
	NSURL * url=[self currentURL];
	
	if(url)
	{
		if(item)
		{			// is it the same as the original item?
			if([[url description] isEqualToString:item.url])
			{
				if(!hasSelectedText)
				{
					return self.item;
				}
				else 
				{
					TempFeedItem * copyItem=[TempFeedItem copyItem:self.item];
					
					copyItem.synopsis=selectedText;
					copyItem.origSynopsis=selectedText;
					
					return copyItem;
				}
			}
		}
		
		// its another item, return a new item
		
		TempFeedItem * newItem=[[TempFeedItem alloc] init];
		
		newItem.url=[url description];
		
		// get title
		NSString * newTitle=[self currentTitle];
		
		if(newTitle==nil || [newTitle length]==0)
		{
			newTitle=[item headline];
		}
		
		newItem.headline=newTitle;
		newItem.synopsis=@"";
		newItem.origSynopsis=@"";
		
		if(hasSelectedText)
		{
			newItem.synopsis=selectedText;
			newItem.origSynopsis=selectedText;
		}
		
		// use domain of url as the origin...
		newItem.origin=[url host];
		newItem.date=[NSDate date];
		
		// TODO: if user selected text from the document (is there text in the clipboard?), use as synopsis?
		
		return [newItem autorelease];
	}
	else 
	{
		if(hasSelectedText)
		{
			TempFeedItem * copyItem=[TempFeedItem copyItem:self.item];
			
			copyItem.synopsis=selectedText;
			copyItem.origSynopsis=selectedText;
			
			return copyItem;
		}
		else 
		{
			return self.item;
		}
	}
}

- (BOOL) isCurrentViewAnItem
{
	NSURLRequest * request=webView.request;
	
	if(request)
	{
		NSURL * url=[request mainDocumentURL];
		
		if(url==nil)
		{
			url=[request URL];
		}
		
		// when webview is filled from html instead of http url, it has file url...
		if([[url description] hasPrefix:@"file:"])
		{
			return YES;
		}
	}
	return NO;
}

- (NSURL*) currentURL
{
	NSURL * url=nil;
		 
	NSURLRequest * request=[[self currentWebView] request];

	if(request)
	{
		url=[request mainDocumentURL];
		
		if(url==nil)
		{
			url=[request URL];
		}
	}
	
	if([[url description] hasPrefix:@"file"])
	{
		// cant use local...
		url=nil;
	}
	
	if(url==nil)
	{
		@try 
		{
			NSString *currentURL = [[self currentWebView] stringByEvaluatingJavaScriptFromString:@"window.location"];
			
			if(currentURL && [currentURL length]>0)
			{
				if([currentURL hasPrefix:@"http"])
				{
					url=[NSURL URLWithString:currentURL];
				}
			}
		}
		@catch (NSException * e) 
		{
		}
		@finally 
		{
		}
		
		if(url==nil)
		{
			if(item && item.url && [item.url length]>0)
			{
				url=[NSURL URLWithString:item.url];
			}
		}
	}
	
	return url;
}

- (SHKItem*) currentImageShareItem:(UIImage*)image
{
	FeedItem * currentItem=[self currentItem];
	
	SHKItem * shareItem=[[[SHKItem alloc] init] autorelease];
	shareItem.shareType=SHKShareTypeImage;
	shareItem.image=image;
	shareItem.title=currentItem.headline;
	
	if(currentItem.url)
	{
		shareItem.URL=[NSURL URLWithString:currentItem.url];
	}
	
	return shareItem;
}

- (SHKItem*) currentTextShareItem:(NSString*)text
{
	FeedItem * currentItem=[self currentItem];
	
	SHKItem * shareItem=[[[SHKItem alloc] init] autorelease];
	
	shareItem.text=text;
	shareItem.title=currentItem.headline;
	
	if(currentItem.url)
	{
		shareItem.URL=[NSURL URLWithString:currentItem.url];
		shareItem.shareType=SHKShareTypeURL;
	}
	else 
	{
		shareItem.shareType=SHKShareTypeText;
	}
	
	return shareItem;
}

- (void)shareTextActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex<0) return;
	
	sharingText=YES;
	
	@try {
		
		SHKItem * shareItem=[self currentTextShareItem:self.shareText];
		
		switch(buttonIndex)
		{
			case 0: // email
				// generate new email with text as body
				if ([MFMailComposeViewController canSendMail]) 
				{
					// create mail composer object
					MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
					
					// make this view the delegate
					mailer.mailComposeDelegate = self;
					
					TempFeedItem * copy=[[[TempFeedItem alloc] init] autorelease];
					FeedItem * curItem=[self currentItem];
					
					copy.headline=curItem.headline;
					copy.origSynopsis=self.shareText;
					copy.url=curItem.url;
					copy.origin=curItem.origin;
					copy.date=curItem.date;
				
					EmailHTMLRenderer * renderer=[[EmailHTMLRenderer alloc  ]initWithMaxSynopsisSize:0 includeSynopsis:YES useOriginalSynopsis:YES embedImageData:NO];

					NSString * body=[renderer getHTML:[NSArray arrayWithObject:copy]];
					
					[renderer release];
					
					body=[@"<BR>" stringByAppendingString:body];
					
					[mailer setSubject:curItem.headline];
					
					[mailer setMessageBody:body isHTML:YES];
					
					// present user with composer screen
					[self presentModalViewController:mailer animated:YES];
					
					// release composer object
					[mailer release];
				} 
				else 
				{
					// alert to user there is no email support
					UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Cannot send mail at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
				
				break;
				
			case 1: // facebook
				[SHKFacebook shareItem:shareItem];
				break;
			
			case 2: // google reader
				[SHKGoogleReader shareItem:shareItem];
				break;
				
			case 3: // twitter
				[TwitterClient shareItem:shareItem];
				break;
				
			case 4: // tumblr
				shareItem.shareType=SHKShareTypeText;
				[SHKTumblr shareItem:shareItem];
				break;
				
			default:
				break;
		}
	}
	@catch (NSException * e) {
		
	}
	@finally 
	{
		sharingText=NO;
	}
}

- (void)shareImageActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(self.selectedImageSource)
	{
		// set image as headline image
		NSURL *url = [NSURL URLWithString:self.selectedImageSource];
		// TODO: do we need to do this async? We should be able to get image from local cache so maybe sync is OK here...
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [[UIImage alloc] initWithData:data];
		
		if(img)
		{
			SHKItem * shareItem=[self currentImageShareItem:img];
			
			switch(buttonIndex)
			{
				case 0: // email
					// generate new email with attachment
					if ([MFMailComposeViewController canSendMail]) 
					{
						// create mail composer object
						MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
						
						// make this view the delegate
						mailer.mailComposeDelegate = self;
						
						NSData *myData = UIImageJPEGRepresentation(img, 1.0);
						
						[mailer addAttachmentData:myData mimeType:@"image/png" fileName:@"image.png"];
					 
						[mailer setSubject:[self currentTitle]];
						
						[mailer setMessageBody:@"" isHTML:YES];
						
						// present user with composer screen
						[self presentModalViewController:mailer animated:YES];
						
						// release composer object
						[mailer release];
					} 
					else 
					{
						// alert to user there is no email support
						UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Cannot send mail at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
						[alertView show];
						[alertView release];
					}
					
					break;
					
				case 1: // facebook
					[SHKFacebook shareItem:shareItem];
					
					break;
					
				case 2: // twitter
					[TwitterClient shareItem:shareItem];
					
					break;
					
				case 3: // tumblr
					[SHKTumblr shareItem:shareItem];
					break;
				
				default:
					break;
			}
		}
		
		[img release];
	}
}

- (void)setItemImageActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// image touch - set newsletter item image
	if(self.selectedImageSource)
	{
		// set image as headline image
		NSURL *url = [NSURL URLWithString:self.selectedImageSource];
		// TODO: do we need to do this async? We should be able to get image from local cache so maybe sync is OK here...
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [[UIImage alloc] initWithData:data];
		
		if(img)
		{
			SHKItem * shareItem=[self currentImageShareItem:img];
			
			switch(buttonIndex)
			{
				case 0: // set item image
					if(self.item)
					{
						self.item.image=[ImageResizer resizeImageIfTooBig:img maxWidth:300.0 maxHeight:300.0];
					}
					break;
					
				case 1: // email
					// generate new email with attachment
					if ([MFMailComposeViewController canSendMail]) 
					{
						// create mail composer object
						MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
						
						// make this view the delegate
						mailer.mailComposeDelegate = self;
						
						NSData *myData = UIImageJPEGRepresentation(img, 1.0);
						
						[mailer addAttachmentData:myData mimeType:@"image/png" fileName:@"image.png"];
						
						[mailer setSubject:[self currentTitle]];
						
						[mailer setMessageBody:@"" isHTML:YES];
						
						// present user with composer screen
						[self presentModalViewController:mailer animated:YES];
						
						// release composer object
						[mailer release];
					} 
					else 
					{
						// alert to user there is no email support
						UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Cannot send mail at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
						[alertView show];
						[alertView release];
					}
					
					break;
					
				case 2: // facebook
					[SHKFacebook shareItem:shareItem];
					break;
					
				case 3: // twitter
					[TwitterClient shareItem:shareItem];
					break;
					
				case 4: // tumblr
					[SHKTumblr shareItem:shareItem];
					break;
					
				default:
					break;
			}
		}
		[img release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex<0)
	{
		return;
	}
	if(actionSheet.tag==kShareSelectedTextActionSheet)
	{
		[self shareTextActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
		return;
	}
	if(actionSheet.tag==kShareImageActionSheet)
	{
		[self shareImageActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
		return;
	}
	if(actionSheet.tag==kSetItemImageActionSheet)
	{
		[self setItemImageActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
		return;
	}
	
	NSURL * url=[self currentURL];
			
	if(url!=nil)
	{
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (IBAction) downButtonTouch:(id)sender
{
	if(tmpWebView)
	{
		if(tmpWebView.superview)
		{
			if (tmpWebView.canGoForward) 
			{
				[tmpWebView goForward];
			}
			return;
		}
	}
	
	if(itemIndex < [fetcher count]-1)
	{
		self.itemIndex = itemIndex +1;
	
		[self renderItemAnimated:YES swipeDirection:kCATransitionFromRight];
	}
	else 
	{
		downButton.enabled=NO;
	}
}

- (IBAction) upButtonTouch:(id)sender
{
	if(tmpWebView)
	{
		if(tmpWebView.superview)
		{
			if (tmpWebView.canGoBack) 
			{
				[tmpWebView goBack];
			}
			else 
			{
				[CATransaction begin];
				
				CATransition *animation;
				
				animation = [CATransition animation];
				animation.type = kCATransitionPush;
				animation.subtype=kCATransitionFromLeft;
				animation.duration = SWIPE_DURATION;
				
				[[contentView layer] addAnimation:animation forKey:@"myanimationkey"];
				
				[self renderItem];
				
				[CATransaction commit];
				
			}
			return;
		}
	}
	
	// go to previous item
	if(itemIndex > 0)
	{
		self.itemIndex = itemIndex - 1;

		if(itemIndex < [fetcher count]-1)
		{
			[self renderItemAnimated:YES swipeDirection:kCATransitionFromLeft];
		}
		else 
		{
			upButton.enabled=NO;
		}
	}
	else 
	{
		upButton.enabled=NO;
	}
}

- (void) backButtonTouch:(id)sender
{
	if(tmpWebView)
	{
		if(tmpWebView.superview)
		{
			if(tmpWebView.canGoBack)
			{
				[tmpWebView goBack];
				return;
			}
		}
	}
	
	[CATransaction begin];
	
	CATransition *animation;
	
	animation = [CATransition animation];
	animation.type = kCATransitionPush;
	animation.subtype=kCATransitionFromLeft;
	animation.duration = SWIPE_DURATION;
	
	[[contentView layer] addAnimation:animation forKey:@"myanimationkey"];
	
	[self renderItem];
	
	[CATransaction commit];
}

- (void) forwardButtonTouch:(id)sender
{
	// if touched from original item - navigate to the item original URL - otherwise go forward in web history
	if(tmpWebView)
	{
		if(tmpWebView.superview)
		{
			if(tmpWebView.canGoForward)
			{
				[tmpWebView goForward];
			}
		}
	}
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self renderItem];
}

- (NSString*) getHtml:(FeedItem*)item 
{
	if(item==nil) return @"";
	
	return [renderer getItemHTML:item];
}
 
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// did user send email? if so mark last published date of newsletter to now..

	[self dismissModalViewControllerAnimated:YES];
}

//Sent before a web view begins loading content.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if ([request.URL.scheme isEqualToString:@"mailto"]) 
	{
		// make sure this device is setup to send email
		if ([MFMailComposeViewController canSendMail]) 
		{
			// create mail composer object
			MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
			
			// make this view the delegate
			mailer.mailComposeDelegate = self;
			
			// set recipient
			[mailer setToRecipients:[NSArray arrayWithObject:request.URL.resourceSpecifier]];
			
			if([request.URL.resourceSpecifier isEqualToString:@"mobile@infongen.com"])
			{
				[mailer setSubject:@"Curator HD Feedback"];
			
				[mailer setMessageBody:@"Thank you for using Curator HD!\n\nTell us what you think.\n\nWe'd love to hear your feedback.\n\n" isHTML:NO];
			}
			
			// present user with composer screen
			[self presentModalViewController:mailer animated:YES];
			
			// release composer object
			[mailer release];
		} 
		else 
		{
			// alert to user there is no email support
			UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Cannot send mail at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
		
		// don't load url in this webview
		return NO;
	}
	
	if(![webView isEqual:tmpWebView])
	{
		if(navigationType==UIWebViewNavigationTypeLinkClicked)
		{
			// open links into a temp web view...
			if(tmpWebView)
			{
				[tmpWebView stopLoading];
				[self removeSwipeGesturesFromWebView:tmpWebView];
				[tmpWebView removeFromSuperview];
				[tmpWebView release];
				tmpWebView=nil;
			}
			
			[CATransaction begin];
			
			CATransition *animation;
			
			animation = [CATransition animation];
			animation.type = kCATransitionPush;
			animation.subtype=kCATransitionFromRight;
			animation.duration = SWIPE_DURATION;
			
			tmpWebView=[[UIWebView alloc] init];
			tmpWebView.frame=webView.frame;
			tmpWebView.scalesPageToFit=YES;
			
			[self attacheLongPressGestureToWebView:tmpWebView];
			
			[contentView addSubview:tmpWebView];
			[contentView bringSubviewToFront:tmpWebView];
			
			[[contentView layer] addAnimation:animation forKey:@"myanimationkey"];
			
			tmpWebView.delegate=self;
			
			[tmpWebView loadRequest:request];
			
			[CATransaction commit];
			
			return NO;
		}
	}

	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"didFailLoadWithError: %@",[error userInfo]);
	
}

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
	UIApplication* app = [UIApplication sharedApplication]; 
    app.networkActivityIndicatorVisible = YES;
	[activityView startAnimating];
	activityView.hidden=NO;
}

- (void) removeHrefTargets:(UIWebView*)webView
{
	// remove target attributes from hrefs, so that we can open links that target another window (otherwise UIWebView will not open them)

	NSString *js = @"\
	var d = document.getElementsByTagName('a');\
	for (var i = 0; i < d.length; i++) {\
	d[i].removeAttribute('target');\
	}\
	";

	[webView stringByEvaluatingJavaScriptFromString:js];	
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{	
	UIApplication* app = [UIApplication sharedApplication]; 
    app.networkActivityIndicatorVisible = NO;
	[activityView stopAnimating];
	activityView.hidden=YES;
	
	if([webView isEqual:tmpWebView])
	{
		self.backButton.enabled=YES; // can always go back to original item
		self.forwardButton.enabled=webView.canGoForward;
	}
	else 
	{
		self.backButton.enabled=NO;
		self.forwardButton.enabled=NO;
	}
	
	[self removeHrefTargets:webView];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.navPopoverController=nil;
	self.webView.delegate=nil;
	self.tmpWebView.delegate=nil;
	self.nextWebView.delegate=nil;
	self.prevWebView.delegate=nil;
	[self.webView stopLoading];
	[self.tmpWebView stopLoading];
	[self.nextWebView stopLoading];
	[self.prevWebView stopLoading];
}
 
- (void)dealloc 
{
	self.webView.delegate=nil;
	self.tmpWebView.delegate=nil;
	self.nextWebView.delegate=nil;
	self.prevWebView.delegate=nil;
	[self.webView stopLoading];
	[self.tmpWebView stopLoading];
	[self.nextWebView stopLoading];
	[self.prevWebView stopLoading];
	[organizePopover release];
	organizePopover=nil;
	[fetcher release];
	[item release];
	[backButton release];
	[forwardButton release];
	[webView release];
	[upButton release];
	[downButton release];
	[actionButton release];
	[activityView release];
	[favoritesButton release];
	[publishButton release];
	[publishActions release];
	[navPopoverController release];
	[selectedImageSource release];
	[selectedImageLink release];
	[appendSynopsisItem release];
	[shareSelectedTextItem release];
	[replaceSynopsisItem release];
	[prevWebView release];
	[nextWebView release];
	[imageListPopover release];
	[tmpWebView release];
	[shareText release];
	[renderer release];
    [super dealloc];
}

@end
