//
//  ScrubberPageControl.h
//  Untitled
//
//  Created by Robert Stewart on 10/26/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScrubberPageControl : UIPageControl 
{
	UIImage* imageNormal;
	UIImage* imageCurrent;
}
@property (nonatomic, readwrite, retain) UIImage* imageNormal;
@property (nonatomic, readwrite, retain) UIImage* imageCurrent;
- (void) updateDots;
@end
