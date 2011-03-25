//
//  FeedsTableViewCell.m
//  Curator
//
//  Created by Robert Stewart on 2/23/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import "FeedsTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeedsTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	isSelected=selected;
	
	if(!selected)
	{
		self.backgroundView=nil;
		self.textLabel.textColor=[UIColor lightGrayColor];
		self.imageView.highlighted=NO;
	}
	else 
	{
		self.backgroundView=[[[UIView alloc] init] autorelease];
		self.backgroundView.backgroundColor=[UIColor blackColor];
		self.backgroundView.alpha=0.3;
		self.textLabel.textColor=[UIColor whiteColor];
		self.imageView.highlighted=YES;
	}

	[super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{	
	if(!isSelected)
	{
		CGRect b=self.bounds;

		CGContextRef context = UIGraphicsGetCurrentContext();

		CGContextSetLineWidth(context,1);

		CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);

		CGContextMoveToPoint(context,0,0);

		CGContextAddLineToPoint(context,b.size.width,0);

		CGContextStrokePath(context);

		CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);

		CGContextMoveToPoint(context,0,b.size.height);

		CGContextAddLineToPoint(context,b.size.width,b.size.height);

		CGContextStrokePath(context);
	}
}

@end
