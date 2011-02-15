#import "FastFolderTableViewCell.h"
#import "FeedItem.h"
#import "ImageListViewController.h"
#import "ImageResizer.h"

@implementation FastFolderTableViewCell
@synthesize origin,date,item,headline,synopsis,comments,itemImage,imagePickerPopover;

static UIFont * sourceFont;
static UIFont * headlineFont;
static UIFont * synopsisFont;
static UIFont * commentsFont;

+ (void) initialize
{
	if(self==[FastFolderTableViewCell class])
	{
		sourceFont=[[UIFont systemFontOfSize:12] retain];
		headlineFont=[[UIFont boldSystemFontOfSize:17] retain];
		synopsisFont=[[UIFont systemFontOfSize:12] retain];
		commentsFont=[[UIFont italicSystemFontOfSize:14] retain];
	}
}

- (void) setHeadline:(NSString *)h
{
	[headline release];
	headline=[h copy];
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(self.editing)
	{
		touchDownOnImage=NO;
		[super touchesBegan:touches withEvent:event];
		return;
	}
	touchDownOnImage=NO;
	if([self didTouchImage:touches])
	{
		touchDownOnImage=YES;
	}
	if(!touchDownOnImage)
	{
		[super touchesBegan:touches withEvent:event];
	}
}

- (BOOL) didTouchImage:(NSSet*)touches
{
	if([touches count]==1)
	{
		UITouch * touch=[touches anyObject];
		if([touch tapCount]>0 && [touch tapCount]<3)
		{
			CGPoint location=[touch locationInView:contentView2];
			
			if(location.x>=4 && location.x<=4+62 &&
			   location.y>=4 && location.y<=4+62)
			{
				
				NSLog(@"user touched image");
				return YES;
			}
		}
	}
	return NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(self.editing)
	{
		touchDownOnImage=NO;
		[super touchesMoved:touches withEvent:event];
		return;
	}
	
	if(touchDownOnImage)
	{
		touchDownOnImage=NO;
	}
	else 
	{
		[super touchesMoved:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(self.editing)
	{
		touchDownOnImage=NO;
		[super touchesEnded:touches withEvent:event];
		return;
	}
	
	if(touchDownOnImage)
	{
		touchDownOnImage=NO;
		if([self didTouchImage:touches])
		{
			[self imageButtonTouch:nil];
			 // show action sheet...
			//UIActionSheet * sheet=[[UIActionSheet alloc] initWithTitle:@"Test" delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:@"test" otherButtonTitles:nil];
			
			//[sheet showFromRect:CGRectMake(4, 4, 62, 62) inView:contentView2 animated:YES];
			
			//[sheet release];
		}
	}
	else 
	{
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchDownOnImage=NO;
	[super touchesCancelled:touches withEvent:event];
}

- (void) setItem:(FeedItem*)theItem
{
	if(![item isEqual:theItem])
	{
		[item release];
		item=[theItem retain];
	}
	
	[self setImage:item.image];
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
			[self setImage:nil];
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

- (void) addImageFromPhotoAlbums
{
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
	
	[popover presentPopoverFromRect:CGRectMake(8, 8, 62,62) inView:contentView2 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	[picker release];
	
	[popover release];
}

- (void) addImageFromWebPage
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
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imageList];
	
	self.imagePickerPopover=popover;
	
	[popover presentPopoverFromRect:CGRectMake(8, 8, 62,62) inView:contentView2 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	[imageList release];
	
	[popover release];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
    // Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imagePickerPopover dismissPopoverAnimated:YES];
	
	image=[ImageResizer resizeImageIfTooBig:image maxWidth:300.0 maxHeight:300.0];
	
	[self setImage:image];
}

- (void) imageListViewController:(ImageListViewController*)controller didFinishPickingImage:(UIImage*)image
{
	// Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imagePickerPopover dismissPopoverAnimated:YES];
	
	image=[ImageResizer resizeImageIfTooBig:image maxWidth:300.0 maxHeight:300.0];
	
	[self setImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [imagePickerPopover dismissPopoverAnimated:YES];
}

- (void) imageButtonTouch:(id)sender
{
	UIActionSheet * actionSheet;
	
	if(itemImage)
	{
		actionSheet=[[UIActionSheet alloc] initWithTitle:@"Modify Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Remove Image"	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
		actionSheet.tag=2;
	}
	else 
	{
		actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
		actionSheet.tag=1;
	}
	
	[actionSheet showFromRect:CGRectMake(8, 8, 62,62) inView:contentView2 animated:YES];
	
	[actionSheet release];
}

- (void) setImage:(UIImage*)image
{
	if(![image isEqual:item.image])
	{
		if(item.image!=nil ||
		   image!=nil)
		{
			item.image=image;
			item.imageUrl=nil;
			[item save];
		}
	}
	/*if(image)
	{
		if(image.size.width>0 && image.size.height>0)
		{
			if((image.size.width<imageButton.frame.size.width &&
				image.size.height<imageButton.frame.size.height) ||
			   MAX(image.size.width,image.size.height)/MIN(image.size.width,image.size.height) <= 2.0 )
			{
				itemImageView.contentMode=UIViewContentModeScaleAspectFill;
			}
			else 
			{
				itemImageView.contentMode=UIViewContentModeScaleAspectFit;
			}
		}
		else 
		{
			itemImageView.contentMode=UIViewContentModeScaleAspectFit;
		}
		
		itemImageView.backgroundColor=[UIColor clearColor];
	}
	else 
	{
		itemImageView.backgroundColor=[UIColor lightGrayColor];
	}
	*/
	if(![itemImage isEqual:image])
	{
		[itemImage release];
		itemImage=[image retain];
		[self setNeedsDisplay];
	}
	//[itemImageView setImage:image];
	//[itemImageView setNeedsDisplay];
	//[self setNeedsLayout];
}

- (void)drawContentView:(CGRect)r
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *bbackgroundColor;
	UIColor *headlineColor;
	UIColor *sourceColor;
	UIColor *synopsisColor;
	UIColor *commentsColor;
	
	if(self.selected)
	{
		if(!self.editing)
		{
			bbackgroundColor = [UIColor clearColor];
			headlineColor = [UIColor whiteColor];
			sourceColor = [UIColor whiteColor];
			synopsisColor = [UIColor whiteColor];
			commentsColor=[UIColor whiteColor];
		}
		else 
		{
			bbackgroundColor = [UIColor clearColor];
			headlineColor =[UIColor blackColor];
			sourceColor = [UIColor grayColor];
			synopsisColor = [UIColor grayColor];
			commentsColor=[UIColor redColor];
		}
	}
	else 
	{
		bbackgroundColor = [UIColor whiteColor];
		headlineColor =[UIColor blackColor];
		sourceColor = [UIColor grayColor];
		synopsisColor = [UIColor grayColor];
		commentsColor=[UIColor redColor];
	}
	
	[bbackgroundColor set];
	CGContextFillRect(context, self.contentView.bounds);
	
	if(itemImage)
	{
		[itemImage drawInRect:CGRectMake(8, 8, 62, 62)];
	}
	else 
	{
		// draw add image button
		[sourceColor set];
		
		CGRect r=CGRectMake(8,8,62,62);
		CGFloat radius=8;
		CGFloat left=CGRectGetMinX(r);
		CGFloat right=CGRectGetMaxX(r);
		CGFloat top=CGRectGetMinY(r);
		CGFloat bottom=CGRectGetMaxY(r);
		//CGFloat	line_length=r.size.width-(radius*2);
		
		CGContextSetLineWidth(context, 1);
		CGContextMoveToPoint(context, left+radius, top);
		CGContextAddLineToPoint(context, right-radius, top);
		CGContextAddArcToPoint(context, right, top, right, top+radius,radius);
		CGContextAddLineToPoint(context,right, bottom-radius);
		CGContextAddArcToPoint(context, right, bottom, right-radius, bottom, radius);
		CGContextAddLineToPoint(context, left+radius, bottom);
		CGContextAddArcToPoint(context, left, bottom, left, bottom-radius, radius);
		CGContextAddLineToPoint(context, left, top+radius);
		CGContextAddArcToPoint(context, left, top, left+radius, top, radius);
		
		CGContextStrokePath(context);
		
		[@"Add" drawInRect:CGRectMake(left, (bottom-top)/2 - 13, right-left, 14) withFont:sourceFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		[@"Image" drawInRect:CGRectMake(left, (bottom-top)/2 + 1, right-left, 14) withFont:sourceFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		
		
	}

	CGPoint p;
	p.x = 78;
	p.y = 0;
	
	[sourceColor set];
	[origin drawAtPoint:p withFont:sourceFont];
	
	CGFloat width=self.contentView.bounds.size.width;
	
	[date drawInRect:CGRectMake(width-150, 0, 140, 14) withFont:sourceFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	
	[headlineColor set];
	
	[headline drawInRect:CGRectMake(78, 14, width-88, 18) withFont:headlineFont lineBreakMode:UILineBreakModeTailTruncation];
	
	[synopsisColor set];
	[synopsis drawInRect:CGRectMake(78,35, width-88, 28) withFont:synopsisFont lineBreakMode:UILineBreakModeTailTruncation];
	
	// draw seperator line
	/*CGContextSetLineWidth(context,1);
	
	CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
	
	CGContextMoveToPoint(context,0,70);
	
	CGContextAddLineToPoint(context,width,70);
	
	CGContextStrokePath(context);
	*/
	if([comments length]>0)
	{
		[commentsColor set];
		[comments drawInRect:CGRectMake(78, 74, width-88,28) withFont:commentsFont lineBreakMode:UILineBreakModeTailTruncation];
	}
	else 
	{
		[sourceColor set];
		[@"Tap to add comments" drawInRect:CGRectMake(78, 74, width-88,28) withFont:commentsFont lineBreakMode:UILineBreakModeTailTruncation];
	}
}

- (void)dealloc 
{	[origin release];
	[date release];
	[headline release];
	[synopsis release];
	[comments release];
	[itemImage release];
		[imagePickerPopover release];
	[item release];
    [super dealloc];
}


@end
