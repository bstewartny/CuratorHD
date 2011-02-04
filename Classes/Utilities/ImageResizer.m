//
//  ImageResizer.m
//  Untitled
//
//  Created by Robert Stewart on 4/16/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ImageResizer.h"


@implementation ImageResizer

+ (UIImage *) resizeImageIfTooBig:(UIImage*)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
	
	if(image.size.width>maxWidth  || image.size.height>maxHeight)
	{
		CGSize newSize;
		
		CGFloat heightRatio=maxHeight/image.size.height;
		
		CGFloat widthRatio=maxWidth/image.size.width;
		
		CGFloat ratio;
		
		if(heightRatio < widthRatio)
		{
			ratio=heightRatio;
		}
		else 
		{
			ratio=widthRatio;
		}
		CGFloat newWidth=ratio * image.size.width;
		CGFloat newHeight=ratio * image.size.height;
		newSize.width=newWidth;
		newSize.height=newHeight;
		
		/*if(image.size.height>maxHeight)
		{
			CGFloat ratio=maxHeight/image.size.height;
			CGFloat newWidth=ratio * image.size.width;
			CGFloat newHeight=ratio * image.size.height;
			newSize.width=newWidth;
			newSize.height=newHeight;
		}
		else
		{
			// resize
			if(image.size.width>image.size.height)
			{
				CGFloat ratio=maxWidth/image.size.width;
				CGFloat newWidth=ratio * image.size.width;
				CGFloat newHeight=ratio * image.size.height;
				newSize.width=newWidth;
				newSize.height=newHeight;
			}
			else
			{
				CGFloat ratio=maxHeight/image.size.height;
				CGFloat newWidth=ratio * image.size.width;
				CGFloat newHeight=ratio * image.size.height;
				newSize.width=newWidth;
				newSize.height=newHeight;
			}
		}*/
		
		UIGraphicsBeginImageContext( newSize );// a CGSize that has the size you want
		
		[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
		
		//image is the original UIImage
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
	}
	
	return image;
	
}
@end
