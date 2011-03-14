#import "NewsletterItemContentView.h"
#import "FeedItem.h"
#import "DocumentEditFormViewController.h"
//#import "DocumentWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageResizer.h"
#import "ItemFetcher.h"
#import "ImageListViewController.h"

@implementation NewsletterItemContentView
@synthesize item ,parentController,parentTableView,imagePickerPopover,dateFormatter,headlineTextColor,synopsisTextColor,commentsTextColor;//,holdTimer;

static UIFont * defaultFont;
static UIFont * headlineFont;
static CGFloat fontHeight;

+ (UIFont*) getDefaultFont
{
	if(defaultFont==nil)
	{
		defaultFont=[UIFont systemFontOfSize:kFontSize];
	
		NSString * fonttmp=@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

		CGSize fontsize=[fonttmp sizeWithFont:defaultFont constrainedToSize:CGSizeMake(20000.0, 20000.0) lineBreakMode:UILineBreakModeWordWrap];

		fontHeight=fontsize.height;
	}
	return defaultFont;
}
+ (UIFont*) getHeadlineFont
{
	if(headlineFont==nil)
	{
		headlineFont=[UIFont boldSystemFontOfSize:kHeadlineFontSize];
	}
	return headlineFont;
}

- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
	
		//self.headlineTextColor=[NewsletterItemContentView colorWithHexString:@"336699"];
		//self.synopsisTextColor=[NewsletterItemContentView colorWithHexString:@"666666"];
		//self.commentsTextColor=[NewsletterItemContentView colorWithHexString:@"b00027"];
		self.headlineTextColor=[UIColor blackColor];
		self.synopsisTextColor=[UIColor grayColor];
		self.commentsTextColor=[UIColor redColor];
		
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"MMM d, yyyy h:mm a"];
		//[format setTimeZone:[NSTimeZone localTimeZone]];
		self.dateFormatter=format;
		[format release];
		
		//self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
		
		imageButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		imageButton.frame=CGRectZero;
		imageButton.hidden=YES;
		imageButton.backgroundColor=[UIColor clearColor];
		imageButton.opaque=NO;
		[imageButton addTarget:self action:@selector(touchImage) forControlEvents:UIControlEventTouchUpInside];
		
		addImageButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		[addImageButton setTitle:@"Add Image" forState:UIControlStateNormal];
		addImageButton.frame=CGRectZero;
		addImageButton.hidden=YES;
		[addImageButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
		
		//headlineButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		//synopsisButton1=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		//synopsisButton2=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		//commentsButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		
		//[headlineButton addTarget:self action:@selector(touchHeadline) forControlEvents:UIControlEventTouchUpInside];
		//[synopsisButton1 addTarget:self action:@selector(touchSynopsis) forControlEvents:UIControlEventTouchUpInside];
		//[synopsisButton2 addTarget:self action:@selector(touchSynopsis) forControlEvents:UIControlEventTouchUpInside];
		//[commentsButton addTarget:self action:@selector(touchComments) forControlEvents:UIControlEventTouchUpInside];
		
		//synopsisButton1.hidden=YES;
		//synopsisButton2.hidden=YES;
		//commentsButton.hidden=YES;
		//synopsisButton1.frame=CGRectZero;
		//synopsisButton2.frame=CGRectZero;
		//commentsButton.frame=CGRectZero;
		
		[self addSubview:imageButton];
		[self addSubview:addImageButton];
		//[self addSubview:headlineButton];
		//[self addSubview:synopsisButton1];
		//[self addSubview:synopsisButton2];
		//[self addSubview:commentsButton];
	}
	return self;
}

- (void) touchImage
{
	if([[self.parentController newsletterTableView] isEditing])
	{
		return;
	}
	   
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Modify Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Remove Image"	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
	actionSheet.tag=2;
	
	[actionSheet showFromRect:_itemSize.image_rect inView:self animated:YES];
	
	[actionSheet release];
}

- (void) redraw
{
	[self setNeedsDisplay];
	[self setNeedsLayout];
	[parentTableView reloadData];
}

- (void) redraw:(FeedItem*)item
{
	[self redraw];
}

- (void) touchSynopsis
{
	if([[self.parentController newsletterTableView] isEditing])
	{
		return;
	}
	   
	DocumentEditFormViewController *controller = [[DocumentEditFormViewController alloc] initAllowComments:YES];
	
	controller.item=item;
	
	controller.delegate=self;
	
	[controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[controller setModalPresentationStyle:UIModalPresentationPageSheet];
	
	[self.parentController presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void) touchHeadline
{
	if([[self.parentController newsletterTableView] isEditing])
	{
		return;
	}
	
	ArrayFetcher * arrayFetcher=[[ArrayFetcher alloc] init];
	
	arrayFetcher.array=[NSArray arrayWithObject:item];
	
	[[[UIApplication sharedApplication] delegate] showItemHtml:0 itemFetcher:arrayFetcher allowComments:NO];
	
	[arrayFetcher release];
}

- (void) touchComments
{
	[self touchSynopsis];
}

- (void) setViewMode:(BOOL)expanded
{
	viewModeExpanded=expanded;
}

- (void) addImage
{
	if([[self.parentController newsletterTableView] isEditing])
	{
		return;
	}
	
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
	actionSheet.tag=1;
		
	[actionSheet showFromRect:_itemSize.image_rect inView:self animated:YES];
	
	[actionSheet release];
}

- (void) addImageFromWebPage
{
	if([[self.parentController newsletterTableView] isEditing])
	{
		return;
	}
	
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
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imageList];
	
	self.imagePickerPopover=popover;
	
	[popover presentPopoverFromRect:_itemSize.image_rect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	[imageList release];
	
	[popover release];
}

- (void) addImageFromPhotoAlbums
{
	if([[self.parentController newsletterTableView] isEditing])
	{
		return;
	}
	
	UIImagePickerController * picker=[[UIImagePickerController alloc] init];
	
	picker.allowsEditing = YES;
	
	picker.delegate=self;
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	else
	{
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
		{
			picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
			
		}
		else
		{
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			}
			else 
			{
				[picker release];
				return;
			}
		}
	}
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
	
	self.imagePickerPopover=popover;
	
	[popover presentPopoverFromRect:_itemSize.image_rect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	[picker release];
	
	[popover release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet.tag==1)
	{
		// add image
		if(buttonIndex==0)
		{
			// photo library
			[self addImageFromPhotoAlbums];
			return;
		}
		if(buttonIndex==1)
		{
			// web page
			[self addImageFromWebPage];
			return;
		}
	}
	
	if(actionSheet.tag==2)
	{
		if(buttonIndex==0)
		{
			// remove
			self.item.image=nil;
			self.item.imageUrl=nil;
			[self.item save];
			[self redraw];
		}
		// modify image
		if(buttonIndex==1)
		{
			// photo library
			[self addImageFromPhotoAlbums];
			return;
		}
		if(buttonIndex==2)
		{
			// web page
			[self addImageFromWebPage];
			return;
		}
	}
}

+ (int) findBestFit:(NSString*)text constraint:(CGSize)constraint
{
	int i=[text length] -1;
	
	if(defaultFont==nil)
	{
		defaultFont=[NewsletterItemContentView getDefaultFont];
	}
	
	CGSize tmp_size=CGSizeMake(constraint.width, 20000.0f);
	
	// use binary search to find first place where size is less than constraint height,
	// then go back to previous value and do it for each word break to find exact fit...
	
	BOOL found_middle=NO;
	
	while(i>0)
	{
		if(!found_middle)
		{
			int middle = i / 2;
			
			NSString * tmp=[text substringToIndex:middle];
			
			CGSize size = [tmp sizeWithFont:defaultFont constrainedToSize:tmp_size lineBreakMode:UILineBreakModeWordWrap];
			
			if(size.height <=constraint.height)
			{
				found_middle=YES;
			}
			else 
			{
				i=middle+1;
				continue;
			}
		}
		
		unichar c=[text characterAtIndex:i--];
		
		if(c==' ' || c=='\n')
		{
			NSString * tmp=[text substringToIndex:i+1];
			
			CGSize size = [tmp sizeWithFont:defaultFont constrainedToSize:tmp_size lineBreakMode:UILineBreakModeWordWrap];
			
			if(size.height <= constraint.height)
			{
				break;
			}
		}
	}
	
	return i;
}

+(ItemSize) sizeForCell:(FeedItem *)item  viewMode:(BOOL)expanded rect:(CGRect)rect
{
	ItemSize itemSize;
	
	itemSize.size=CGSizeZero;
	itemSize.headline_rect=CGRectZero;
	itemSize.date_rect=CGRectZero;
	itemSize.synopsis_break=0;
	itemSize.synopsis_rect1=CGRectZero;
	itemSize.synopsis_rect2=CGRectZero;
	itemSize.comments_rect=CGRectZero;
	itemSize.rect=rect;
	
	int cellWidth;
	
	if(rect.size.width>0)
	{
		cellWidth=rect.size.width;
	}
	else 
	{
		cellWidth=kCellWidth;
	}

	if(defaultFont==nil)
	{
		defaultFont=[NewsletterItemContentView getDefaultFont];
	}
	if(headlineFont==nil)
	{
		headlineFont=[NewsletterItemContentView getHeadlineFont];
	}
	
	itemSize.size.width=cellWidth;
	
	CGSize headline_size=[item.headline sizeWithFont:headlineFont];
	
	if((headline_size.width+(kCellPadding*2)) < cellWidth-(kCellPadding*2))
	{
		itemSize.headline_rect=CGRectMake(kCellPadding, kLineSpacing, headline_size.width+(kCellPadding*2), kHeadlineFontSize+kLineSpacing);
	}
	else 
	{
		itemSize.headline_rect=CGRectMake(kCellPadding, kLineSpacing, cellWidth-(kCellPadding*2), kHeadlineFontSize+kLineSpacing);
	}

	itemSize.date_rect=CGRectMake(kCellPadding, itemSize.headline_rect.origin.y+itemSize.headline_rect.size.height+kLineSpacing,cellWidth-(kCellPadding*2),kDateFontSize+kLineSpacing);
	
	itemSize.size.height=itemSize.date_rect.origin.y+itemSize.date_rect.size.height+kLineSpacing;
	
	itemSize.synopsis_break=0;
	
	if(expanded)
	{
		UIImage * image=item.image;
		NSString * synopsis=item.synopsis;
		NSString * comments=item.notes;
		
		if(image)
		{
			itemSize.image_rect=CGRectMake(kCellPadding, itemSize.date_rect.origin.y+itemSize.date_rect.size.height+kCellPadding, image.size.width, image.size.height);
		}
		else 
		{
			itemSize.image_rect=CGRectMake(kCellPadding, itemSize.date_rect.origin.y+itemSize.date_rect.size.height+kCellPadding, 88, 88);
		}

		itemSize.size.height=itemSize.image_rect.origin.y+itemSize.image_rect.size.height+kCellPadding;
		
		if(synopsis && [synopsis length]>0)
		{
			if(itemSize.image_rect.size.width < cellWidth * .67)
			{
				CGSize constraint = CGSizeMake(cellWidth - itemSize.image_rect.size.width  -  (kCellPadding * 3), 20000.0f);
				
				itemSize.synopsis_rect1=CGRectMake(itemSize.image_rect.origin.x+itemSize.image_rect.size.width+kCellPadding, itemSize.image_rect.origin.y, constraint.width, itemSize.image_rect.size.height+fontHeight);
				
				CGSize size = [synopsis sizeWithFont:defaultFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
				
				if(size.height > itemSize.image_rect.size.height+fontHeight)
				{
					itemSize.synopsis_break=[NewsletterItemContentView findBestFit:synopsis constraint:CGSizeMake(cellWidth-itemSize.image_rect.size.width - (kCellPadding*3), itemSize.image_rect.size.height+fontHeight)];
					
					if(itemSize.synopsis_break>0)
					{
						NSString * first_part=[synopsis substringToIndex:itemSize.synopsis_break+1];
						
						CGSize newSize=[first_part sizeWithFont:defaultFont constrainedToSize:itemSize.synopsis_rect1.size lineBreakMode:UILineBreakModeWordWrap];
						
						// compensate for incorrect height when there are consecutive line breaks (not sure why yet...)
						if(newSize.height <= itemSize.image_rect.size.height)
						{
							newSize.height=itemSize.image_rect.size.height+1;
						}
						
						itemSize.synopsis_rect1.size.height=newSize.height;
						
						NSString * second_part=[synopsis substringFromIndex:itemSize.synopsis_break+2];
						
						size=[second_part sizeWithFont:defaultFont constrainedToSize:CGSizeMake(cellWidth - (kCellPadding*2), 20000.0f) lineBreakMode:UILineBreakModeWordWrap];
						
						itemSize.synopsis_rect2=CGRectMake(kCellPadding,  itemSize.synopsis_rect1.origin.y+itemSize.synopsis_rect1.size.height, cellWidth-(kCellPadding*2), size.height);

						itemSize.size.height=itemSize.synopsis_rect2.origin.y+itemSize.synopsis_rect2.size.height+kCellPadding;
					}
				}
			}
			else 
			{
				CGSize constraint = CGSizeMake(cellWidth-(kCellPadding*2), 20000.0f);
				
				CGSize size = [synopsis sizeWithFont:defaultFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
				
				itemSize.synopsis_rect1=CGRectMake(kCellPadding,itemSize.image_rect.origin.y+itemSize.image_rect.size.height+fontHeight,cellWidth-(kCellPadding*2),size.height);
			
				itemSize.size.height=itemSize.synopsis_rect1.origin.y+itemSize.synopsis_rect1.size.height+kCellPadding;
			}
		}
		else 
		{
			// setup synopsis button rect even though we dont hvae synopsis otherwise we cant have anything to touch to edit the item...
			if(itemSize.image_rect.size.width < cellWidth * .67)
			{
				CGFloat synopsis_rect_width=cellWidth - (itemSize.image_rect.size.width +kCellPadding*2);
				
				itemSize.synopsis_rect1=CGRectMake(itemSize.image_rect.origin.x+itemSize.image_rect.size.width+kCellPadding, itemSize.image_rect.origin.y, synopsis_rect_width, itemSize.image_rect.size.height+fontHeight);
				
			}
			else 
			{
				itemSize.synopsis_rect1=CGRectMake(kCellPadding,itemSize.image_rect.origin.y+itemSize.image_rect.size.height+fontHeight,cellWidth-(kCellPadding*2),50);
				
				itemSize.size.height=itemSize.synopsis_rect1.origin.y+itemSize.synopsis_rect1.size.height+kCellPadding;
			}

		}

		
		if(comments && [comments length]>0)
		{
			CGFloat comments_left = kCellPadding + 45 + 2+2+10;
			
			CGFloat comments_width=cellWidth - (comments_left + (kCellPadding*4));
			
			CGSize constraint = CGSizeMake(comments_width, 20000.0f);
			
			CGSize size = [comments sizeWithFont:defaultFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
			
			itemSize.comments_rect=CGRectMake(comments_left  , itemSize.size.height+kCellPadding, comments_width,size.height);
		
			itemSize.size.height=itemSize.comments_rect.origin.y+itemSize.comments_rect.size.height+(kCellPadding*2);
		}
	}
	
	itemSize.size.height=itemSize.size.height+8; // we added inset to the content view sub-view (this view) to avoid overlapping rounded corners in grouped table view...
	
	return itemSize;
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert  
{  
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];  
	
    // String should be 6 or 8 characters  
    if ([cString length] < 6) return [UIColor grayColor];  
	
    // strip 0X if it appears  
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];  
	
    if ([cString length] != 6) return  [UIColor grayColor];  
	
    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2;  
    NSString *rString = [cString substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [cString substringWithRange:range];  
	
    range.location = 4;  
    NSString *bString = [cString substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
	
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
} 

- (void) layoutButtons:(ItemSize) itemSize
{
	UIImage * image=item.image;
	//NSString * synopsis=item.synopsis;
	//NSString * comments=item.notes;
	
	//headlineButton.frame=itemSize.headline_rect;
	//headlineButton.backgroundColor=[UIColor clearColor];
	//headlineButton.opaque=NO;
	
	if(viewModeExpanded)
	{
		if (image) 
		{
			addImageButton.frame=CGRectZero;
			addImageButton.hidden=YES;
			imageButton.frame=itemSize.image_rect;
			imageButton.hidden=NO;
		}
		else 
		{
			imageButton.hidden=YES;
			imageButton.frame=CGRectZero;
			addImageButton.hidden=NO;
			addImageButton.frame=itemSize.image_rect;
		}
		
		// draw synopsis
		/*if(synopsis && [synopsis length]>0)
		{
			if(itemSize.synopsis_break>0)
			{
				synopsisButton1.hidden=NO;
				synopsisButton1.frame=itemSize.synopsis_rect1;
				synopsisButton1.backgroundColor=[UIColor clearColor];
				synopsisButton1.opaque=NO;
				synopsisButton2.hidden=NO;
				synopsisButton2.frame=itemSize.synopsis_rect2;
				synopsisButton2.backgroundColor=[UIColor clearColor];
				synopsisButton2.opaque=NO;
			}
			else
			{
				synopsisButton1.hidden=NO;
				synopsisButton1.frame=itemSize.synopsis_rect1;
				synopsisButton1.backgroundColor=[UIColor clearColor];
				synopsisButton1.opaque=NO;
				synopsisButton2.hidden=YES;
				synopsisButton2.frame=CGRectZero;
			}
		}
		else {
			// we still need to have a hidden synopsis button so user can add synopsis or comments if there are none - otherwise there is no button to touch...
			synopsisButton1.hidden=NO;
			synopsisButton1.frame=itemSize.synopsis_rect1;
			synopsisButton1.backgroundColor=[UIColor clearColor];
			synopsisButton1.opaque=NO;
			synopsisButton2.hidden=YES;
			synopsisButton2.frame=CGRectZero;
		}

		
		if(comments && [comments length]>0)
		{ 
			commentsButton.hidden=NO;
			commentsButton.frame=itemSize.comments_rect;
		}
		else 
		{
			commentsButton.hidden=YES;
			commentsButton.frame=CGRectZero;
		}*/
	}
	else 
	{
		// hide buttons on headline view
		addImageButton.hidden=YES;
		addImageButton.frame=CGRectZero;
		imageButton.hidden=YES;
		imageButton.frame=CGRectZero;
		//synopsisButton1.hidden=YES;
		//synopsisButton1.frame=CGRectZero;
		//synopsisButton2.hidden=YES;
		//synopsisButton2.frame=CGRectZero;
		//commentsButton.hidden=YES;
		//commentsButton.frame=CGRectZero;
	} 
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	CGRect rect=self.bounds;
	
	_itemSize=[NewsletterItemContentView sizeForCell:item viewMode:viewModeExpanded rect:rect];
	
	[self layoutButtons:_itemSize];
}

- (void)drawRect:(CGRect)rect
{
	[self drawText:_itemSize];
}

- (void) drawText:(ItemSize) itemSize
{
	UIImage * image=item.image;
	NSString * synopsis=item.synopsis;
	NSString * comments=item.notes;
	
	CGContextRef context=UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, self.headlineTextColor.CGColor);//336699
	
	// draw headline
	
	NSString * normalized_headline=item.headline; //[FeedItem normalizeHeadline:item.headline];
	
	if(headlineFont==nil)
	{
		headlineFont=[NewsletterItemContentView getHeadlineFont];
	}
	
	[normalized_headline drawInRect:itemSize.headline_rect withFont:headlineFont lineBreakMode:UILineBreakModeTailTruncation];
	
	CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);//666666
	
	// draw date
	
	NSString *dateString = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:item.date],[item relativeDateOffset]];
	
	if (item.origin && [item.origin length]>0) {
		dateString=[dateString stringByAppendingFormat:@" - %@",item.origin];
	}
	
	[dateString drawInRect:itemSize.date_rect withFont:[UIFont systemFontOfSize:kDateFontSize] lineBreakMode:UILineBreakModeTailTruncation];
	
	if(viewModeExpanded)
	{
		UIFont * font=[NewsletterItemContentView getDefaultFont];//   [UIFont systemFontOfSize:kFontSize];
	
		CGContextSetFillColorWithColor(context, self.synopsisTextColor.CGColor);//666666
		
		if (image) 
		{
			[image drawInRect:itemSize.image_rect];
		}
		
		// draw synopsis
		if(synopsis && [synopsis length]>0)
		{
			if(itemSize.synopsis_break>0)
			{
				NSString * first_part=[synopsis substringToIndex:itemSize.synopsis_break+1];
				
				[first_part drawInRect:itemSize.synopsis_rect1 withFont:font lineBreakMode:UILineBreakModeWordWrap];
				
				NSString * second_part=[synopsis substringFromIndex:itemSize.synopsis_break+2];
				
				[second_part drawInRect:itemSize.synopsis_rect2 withFont:font lineBreakMode:UILineBreakModeWordWrap];
			}
			else
			{
				[synopsis drawInRect:itemSize.synopsis_rect1 withFont:font];
			}
		}
		
		if(comments && [comments length]>0)
		{ 
			UIImage * quoteImage=[UIImage imageNamed:@"CommentQuoteImage.jpg"];
			
			CGRect rect=CGRectMake(kCellPadding, itemSize.comments_rect.origin.y+itemSize.comments_rect.size.height/2 - 12, quoteImage.size.width,quoteImage.size.height);
			
			[quoteImage drawInRect:rect];
			
			CGContextSetLineWidth(context,2);
			
			CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
			
			CGContextMoveToPoint(context,itemSize.comments_rect.origin.x - (10+2),itemSize.comments_rect.origin.y);
			
			CGContextAddLineToPoint(context,itemSize.comments_rect.origin.x - (10+2),itemSize.comments_rect.origin.y+itemSize.comments_rect.size.height);
			
			CGContextStrokePath(context);
			
			CGContextSetFillColorWithColor(context, self.commentsTextColor.CGColor);//666666
			
			[comments drawInRect:itemSize.comments_rect withFont:font];
		}
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	
    // Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imagePickerPopover dismissPopoverAnimated:YES];

	image=[ImageResizer resizeImageIfTooBig:image maxWidth:300.0 maxHeight:300.0];

	item.image=image;
	item.imageUrl=nil;
	[item save];
	
	[self redraw];
}

- (void) imageListViewController:(ImageListViewController*)controller didFinishPickingImage:(UIImage*)image
{
	// Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imagePickerPopover dismissPopoverAnimated:YES];
	
	image=[ImageResizer resizeImageIfTooBig:image maxWidth:300.0 maxHeight:300.0];
	
	item.image=image;
	item.imageUrl=nil;
	[item save];	
	
	[self redraw];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [imagePickerPopover dismissPopoverAnimated:YES];
}

- (void)dealloc {
	[item release];
	[parentController release];
	[parentTableView release];
	[imagePickerPopover release];
	[headlineButton release];
	[synopsisButton1 release];
	[synopsisButton2 release];
	[commentsButton release];
	[imageButton release];
	[addImageButton release];
	[dateFormatter release];
	[headlineTextColor release];
	[synopsisTextColor release];
	[commentsTextColor release];
    [super dealloc];
}

@end
