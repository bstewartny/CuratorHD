#import "ItemImageCell.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageResizer.h"
#import "ImageListViewController.h"

@implementation ItemImageCell
@synthesize imageButton,itemImageView,item,imagePickerPopover;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
		CGRect f=self.contentView.bounds;
		
		itemImageView=[[UIImageView alloc] initWithFrame:CGRectMake(4,4,62,62)];
		itemImageView.clipsToBounds=YES;
		itemImageView.opaque=YES;
		itemImageView.contentMode=UIViewContentModeScaleAspectFit;
		itemImageView.layer.cornerRadius=9.5;
		itemImageView.backgroundColor=[UIColor lightGrayColor];
		
		[self.contentView addSubview:itemImageView];
		
		imageButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		imageButton.frame=CGRectMake(4,4,62,62);
		
		imageButton.clipsToBounds=YES;
		imageButton.opaque=NO;
		imageButton.layer.cornerRadius=9.5;
		[imageButton addTarget:self action:@selector(imageButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
		imageButton.backgroundColor=[UIColor clearColor];
		
		
		[self.contentView addSubview:imageButton];
		[self.contentMode bringSubviewToFront:imageButton];
	}
	return self;
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
		if(item.image!=nil ||
		   image!=nil)
		{
			item.image=image;
			item.imageUrl=nil;
			[item save];
		}
	}
	if(image)
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
	
	[itemImageView setImage:image];
	[itemImageView setNeedsDisplay];
	[self setNeedsLayout];
}

- (void) imageButtonTouch:(id)sender
{
	UIActionSheet * actionSheet;
	
	if(itemImageView.image)
	{
		actionSheet=[[UIActionSheet alloc] initWithTitle:@"Modify Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Remove Image"	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
		actionSheet.tag=2;
	}
	else 
	{
		actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil	otherButtonTitles:@"From Photo Albums",@"From Web Page",nil];
		actionSheet.tag=1;
	}
	
	[actionSheet showFromRect:itemImageView.frame	inView:itemImageView.superview animated:YES];
	
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
	
	[popover presentPopoverFromRect:itemImageView.frame inView:itemImageView.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
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
	
	[popover presentPopoverFromRect:itemImageView.frame inView:itemImageView.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
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
	[itemImageView release];
    [super dealloc];
}

@end

