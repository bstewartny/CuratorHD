//
//  UILabelEx.h
//  Untitled
//
//  Created by Robert Stewart on 2/8/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

/*
 A UILabel which supports vertical alignment of multi-line text.
*/

@interface UILabelEx : UILabel {
@private
	VerticalAlignment verticalAlignment_;
}

@property(nonatomic,assign) VerticalAlignment verticalAlignment;

@end
