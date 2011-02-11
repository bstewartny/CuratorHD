#import "ItemImageCell.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageResizer.h"
#import "ImageListViewController.h"

@implementation ItemImageCell
@synthesize imageButton,item,imagePickerPopover;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
		CGRect f=self.contentView.bounds;
		
		imageButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		imageButton.frame=CGRectMake(4,4,62,62);
		
		imageButton.clipsToBounds=YES;
		imageButton.opaque=YES;
		imageButton.layer.cornerRadius=9.5;
		[imageButton addTarget:self action:@selector(imageButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
		imageButton.backgroundColor=[UIColor lightGrayColor];
		[imageButton setTitle:@"IMG" forState:UIControlStateNormal];
		imageButton.adjustsImageWhenHighlighted = NO;
		
		[self.contentView addSubview:imageButton];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
    if(selected)
	{
		if(item.image==nil)
		{
			imageButton.backgroundColor=[UIColor lightGrayColor];
		}
	}
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

- (void) setImage:(UIImage*)image
{
	if(![image isEqual:item.image])
	{
		item.image=image;
		item.imageUrl=nil;
		[item save];
	}
	if(image)
	{
		imageButton.imageView.contentMode=UIViewContentModeScaleAspectFit;
		imageButton.backgroundColor=[UIColor clearColor];
	}
	else 
	{
		imageButton.backgroundColor=[UIColor lightGrayColor];
	}
	
	[imageButton setImage:image forState:UIControlStateNormal];
	[imageButton setNeedsDisplay];
	[self setNeedsLayout];
}

- (void) imageButtonTouch:(id)sender
{
	UIActionSheet * actionSheet;
	
	if(imageButton.imageView.image)
	{
		actionSheet=[[UIActionSheet alloc] initWithTitle:@"Modify Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Remove Image"	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
		actionSheet.tag=2;
	}
	else 
	{
		actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
		actionSheet.tag=1;
	}
	
	[actionSheet showFromRect:imageButton.frame	inView:imageButton.superview animated:YES];
	
	[actionSheet release];
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
	
	[popover presentPopoverFromRect:imageButton.frame inView:imageButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
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
	
	[popover presentPopoverFromRect:imageButton.frame inView:imageButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
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

- (void)dealloc 
{
	[item release];
	[imageButton release];
	[imagePickerPopover release];
    [super dealloc];
}

@end

