//
//  ScrubberPageControl.m
//  Untitled
//
//  Created by Robert Stewart on 10/26/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ScrubberPageControl.h"


@implementation ScrubberPageControl
@synthesize imageNormal,imageCurrent;

- (void) dealloc
{
	[imageNormal release];
	[imageCurrent release];
	
	[super dealloc];
}


/** override to update dots */
- (void) setCurrentPage:(NSInteger)currentPage
{
	[super setCurrentPage:currentPage];
	
	// update dot views
	[self updateDots];
}

/** override to update dots */
- (void) updateCurrentPageDisplay
{
	[super updateCurrentPageDisplay];
	
	// update dot views
	[self updateDots];
}

/** Override setImageNormal */
- (void) setImageNormal:(UIImage*)image
{
	[imageNormal release];
	imageNormal = [image retain];
	
	// update dot views
	[self updateDots];
}

/** Override setImageCurrent */
- (void) setImageCurrent:(UIImage*)image
{
	[imageCurrent release];
	imageCurrent = [image retain];
	
	// update dot views
	[self updateDots];
}

/** Override to fix when dots are directly clicked */
- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event 
{
	[super endTrackingWithTouch:touch withEvent:event];
	
	[self updateDots];
}
 
#pragma mark - (Private)

- (void) layoutSubviews
{
	[self updateDots];
}

- (void) updateDots
{
	if(imageCurrent && imageNormal)
	{
		int dotWidth=imageNormal.size.width;
		int dotHeight=imageNormal.size.height;
		int totalWidth=dotWidth * self.numberOfPages;
		int left=(self.frame.size.width - totalWidth)/2;
		int top=(self.frame.size.height - dotHeight)/2;
		if(top<0) top=0;
		if(left<0) left=0;
		
		// Get subviews
		NSArray* dotViews = self.subviews;
		for(int i = 0; i < dotViews.count; ++i)
		{
			UIImageView* dot = [dotViews objectAtIndex:i];
			// TODO: verify dot is a UIImageView and fail gracefully if it is not (incase of future change to UIPageControl)
			// Set image
			//NSLog(@"dot frame = %@",NSStringFromCGRect(dot.frame));
			
			dot.image = (i == self.currentPage) ? imageCurrent : imageNormal;
			
			dot.frame = CGRectMake(left, top, dotWidth,dotHeight);
		
			
			left+=dotWidth;
		
		}
	}
}


@end
