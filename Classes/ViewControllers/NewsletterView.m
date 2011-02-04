//
//  NewsletterView.m
//  Untitled
//
//  Created by Robert Stewart on 4/7/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterView.h"
#import "NewsletterItemContentView.h"

@implementation NewsletterView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	///NSLog(@"drawRect in newsletter view");
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetStrokeColorWithColor(context, [[NewsletterItemContentView colorWithHexString:@"336699"] CGColor]);
	
	CGContextSetLineWidth(context, 1.0);
	
	CGContextMoveToPoint(context, 0.0, 31.0);
	
	CGContextAddLineToPoint(context, rect.size.width, 31.0);
	
	CGContextMoveToPoint(context, 0.0, 249.0);
	
	CGContextAddLineToPoint(context, rect.size.width, 249.0);
	
	CGContextStrokePath(context);
}

- (void)dealloc {
    [super dealloc];
}


@end
