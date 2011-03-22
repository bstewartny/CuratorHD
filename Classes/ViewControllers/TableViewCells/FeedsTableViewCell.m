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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	if(highlighted)
	{
		NSLog(@"setHighlighted:YES");
		
	}
	else {
		NSLog(@"setHighlighted:NO");
	}

	//self.imageView.highlighted=highlighted;
	[super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	isSelected=selected;
	
	if(!selected)
	{
		//self.layer.opacity=1.0;
		self.backgroundView=nil;
		//self.backgroundView.backgroundColor=[UIColor clearColor];
		//self.backgroundView.alpha=1.0;
		//self.backgroundColor=[UIColor clearColor];
		self.textLabel.textColor=[UIColor lightGrayColor];
		self.imageView.highlighted=NO;
	}
	else 
	{
		self.backgroundView=[[[UIView alloc] init] autorelease];
		self.backgroundView.backgroundColor=[UIColor blackColor];
		self.backgroundView.alpha=0.3;
		//self.backgroundColor=[UIColor blackColor];
		self.textLabel.textColor=[UIColor whiteColor];
		//self.layer.opacity=0.4;
		self.imageView.highlighted=YES;
	}

	
	
	
	
	
	[super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{	
	//[super drawRect:rect];
	//NSLog(@"FeedsTableViewCell::drawRect");
	
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
	else {
		
		/*CGRect b=self.bounds;
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSetLineWidth(context,1);
		
		CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
		
		CGContextMoveToPoint(context,0,0);
		
		CGContextAddLineToPoint(context,b.size.width,0);
		
		CGContextStrokePath(context);
		*/
		/*CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
		
		CGContextMoveToPoint(context,0,b.size.height);
		
		CGContextAddLineToPoint(context,b.size.width,b.size.height);
		
		CGContextStrokePath(context);
		*/
		
		
	}

	
	
}

- (void)dealloc {
    [super dealloc];
}


@end
