//
//  ImageListViewController.m
//  Untitled
//
//  Created by Robert Stewart on 8/13/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ImageListViewController.h"
#import "Feeditem.h"
#import "HTMLImageParser.h"
#import "ImageResizer.h"
#import <QuartzCore/QuartzCore.h>

#define kImageButtonWidth 100
#define kImageButtonHeight 100
#define MAX_IMAGES_TO_FETCH 20

@implementation ImageListViewController
@synthesize item,scrollView,images,delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	images=[[NSMutableArray alloc] init];
	
	self.view.backgroundColor=[UIColor blackColor];
	
	self.contentSizeForViewInPopover=CGSizeMake(kImageButtonWidth, 400);
	
	scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kImageButtonWidth, 400)];
	scrollView.backgroundColor=[UIColor blackColor];
	
	contentView=[[UIView alloc] initWithFrame:CGRectMake(0,0,kImageButtonWidth,(MAX_IMAGES_TO_FETCH +1)*kImageButtonHeight)];
	
	[scrollView addSubview:contentView];
	
	[scrollView setContentSize:CGSizeMake(kImageButtonWidth, kImageButtonHeight)];
	
	activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(35, 35, 30, 30)];
	[contentView addSubview:activityView];
	[activityView startAnimating];
	
	
	[self.view addSubview:scrollView];
	
	[self performSelectorInBackground:@selector(loadImagesStart) withObject:nil];
}

- (void) loadImagesStart
{
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary * map=[[NSMutableDictionary alloc] init];
		
	NSMutableArray * imageUrls=[[NSMutableArray alloc] init];
	
	@try {
	
		int numImages=0;
		
		if(!cancelDownloads)
		{
			// get images from synopsis...
			NSArray * synopsisUrls=[HTMLImageParser getImageUrls:item.origSynopsis];
			
			// filter, merge and dedup image urls...
			for(NSString * url in synopsisUrls)
			{
				if([self isValidImageUrl:url])
				{
					if([map objectForKey:url]==nil)
					{
						[imageUrls addObject:url];
					
						[map setObject:url forKey:url];
					}
				}
			}
		}
		
		if(!cancelDownloads)
		{
		
			// get images from url
			NSArray * remoteUrls=[HTMLImageParser getImageUrlsFromUrl:item.url];
			
			for(NSString * url in remoteUrls)
			{
				if([self isValidImageUrl:url])
				{
					if([map objectForKey:url]==nil)
					{
						[imageUrls addObject:url];
					
						[map setObject:url forKey:url];
					}
				}
			}
		}
		
		// now get images... use parallel processing queue...
		
		for(NSString * url in imageUrls)
		{
			if(cancelDownloads) break;
			
			if(numImages>MAX_IMAGES_TO_FETCH) break;
			UIImage * image=[self downloadImage:url];
			if(image)
			{
				if([self isValidImage:image])
				{
					[self performSelectorOnMainThread:@selector(addImageToScrollView:) withObject:image waitUntilDone:YES];
					numImages++;
				}
			}
		}
		
		if(activityView)
		{
			[activityView stopAnimating];
			activityView.hidden=YES;
			[activityView removeFromSuperview];
			[activityView release];
			activityView=nil;
		}
		
		if(numImages==0)
		{
			// tell user we found no images...
			UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(20, 20, kImageButtonWidth-40, kImageButtonHeight-40)];
			label.textAlignment=UITextAlignmentCenter;
			label.numberOfLines=3;
			label.font=[UIFont systemFontOfSize:12];
			label.backgroundColor=[UIColor blackColor];
			label.textColor=[UIColor whiteColor];
			label.text=@"No images found.";
			
			[contentView addSubview:label];
			
			[label release];
			
			[contentView setNeedsDisplay];
		}
	}
	@catch (NSException * e) 
	{
		if(activityView)
		{
			[activityView stopAnimating];
			activityView.hidden=YES;
			[activityView removeFromSuperview];
			[activityView release];
			activityView=nil;
			[contentView setNeedsDisplay];
		}
		
		NSLog(@"Error getting images: %@",[e userInfo]);
	}
	@finally 
	{
		[map release];
	
		[imageUrls release];
	
		[pool drain];
	}
}

- (UIImage*) downloadImage:(NSString*)url
{
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	if(data)
	{
		return [[[UIImage alloc] initWithData:data] autorelease];
	}
	else 
	{
		return nil;
	}
}

- (BOOL) isValidImage:(UIImage*) image
{
	// only accept images above minimum size
	if(image.size.width<50 || image.size.height<50)
	{
		//NSLog(@"Image is too small: %@",NSStringFromCGSize(image.size));
		return NO;
	}
	
	// only accept images where shape is mostly square
	if(image.size.width > image.size.height * 5)
	{
		//NSLog(@"Image is not square enough: %@",NSStringFromCGSize(image.size));
		return NO;
	}
	
	if(image.size.height > image.size.width * 5)
	{
		//NSLog(@"Image is not square enough: %@",NSStringFromCGSize(image.size));
		
		return NO;
	}
	
	// only accept images where size is not too huge
	if(image.size.height>2000 || image.size.width>2000)
	{
		//NSLog(@"Image is too big: %@",NSStringFromCGSize(image.size));
		
		return NO;
	}
	
	return YES;
}

- (BOOL) isValidImageUrl:(NSString *)url
{
	// only accept non-relative paths...
	if(!([url hasPrefix:@"http:"] || [url hasPrefix:@"https:"]))
	{
		//NSLog(@"Image has invalid url (relative): %@",url);
		return NO;
	}
	
	// only accept images with real image extensions...
	//if(!([url hasSuffix:@".png"] || [url hasSuffix:@".jpg"] || [url hasSuffix:@".jpeg"]))
	//{
	//	NSLog(@"Image has invalid extension: %@",url);
	//	
	//	return NO;
	//}	
	
	return YES;
}

- (void) addImageToScrollView:(UIImage*)image
{
	if(cancelDownloads) return;
	
	int numImages=[images count];
	
	if(numImages==0)
	{
		if(activityView)
		{
			[activityView stopAnimating];
			activityView.hidden=YES;
			[activityView removeFromSuperview];
			[activityView release];
			activityView=nil;
		}
	}
	
	[images addObject:image];
	
	// TODO: use fade in animation...
	
	UIImage * resizedImage=[ImageResizer resizeImageIfTooBig:image maxWidth:kImageButtonWidth maxHeight:kImageButtonHeight];
	
	//NSLog(@"numImages=%d",numImages);
	
	CGRect frame=CGRectMake(0, numImages * kImageButtonHeight, kImageButtonWidth, kImageButtonHeight);
	
	frame=CGRectInset(frame, 4, 4);
	
	//NSLog(@"adding button with frame: %@",NSStringFromCGRect(frame));
	
	//UIButton * button = [[UIButton buttonWithType:UIButtonTypeCustom] initWithFrame:frame];
	
	UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:frame];
	[button addTarget:self action:@selector(touchImage:) forControlEvents:UIControlEventTouchUpInside];
	button.imageView.contentMode=UIViewContentModeScaleAspectFit;
	button.imageView.clipsToBounds=YES;
	button.clipsToBounds=YES;
	[button setImage:resizedImage forState:UIControlStateNormal];
	button.layer.cornerRadius=9.5;
	button.backgroundColor=[UIColor whiteColor];
	//[button setBackgroundImage:resizedImage forState:UIControlStateNormal];
	button.tag=numImages;
	
	[contentView addSubview:button];
	
	[scrollView setContentSize:CGSizeMake(kImageButtonWidth, (numImages+1) * kImageButtonHeight)];
	
	
	
	[contentView setNeedsDisplay];
	
	[scrollView	setNeedsDisplay];

}

- (void) touchImage:(id)sender
{
	cancelDownloads=YES;
	//user selected an image
	int imageNum=[sender tag];
	
	UIImage * image=[images objectAtIndex:imageNum];
	
	[delegate imageListViewController:self didFinishPickingImage:image];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    cancelDownloads=YES;
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	cancelDownloads=YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	cancelDownloads=YES;
}

- (void)dealloc {
	cancelDownloads=YES;
	[item release];
	[scrollView release];
	[images release];
	[contentView release];
	[activityView release];
    [super dealloc];
}


@end
