//
//  FeedsTableViewCell.m
//  Curator
//
//  Created by Robert Stewart on 2/23/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import "FeedsTableViewCell.h"


@implementation FeedsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}
- (void) drawRect:(CGRect)rect
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

- (void)dealloc {
    [super dealloc];
}


@end
