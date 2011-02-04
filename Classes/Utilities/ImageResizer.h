//
//  ImageResizer.h
//  Untitled
//
//  Created by Robert Stewart on 4/16/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageResizer : NSObject {

}


+ (UIImage *) resizeImageIfTooBig:(UIImage*)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;

@end
