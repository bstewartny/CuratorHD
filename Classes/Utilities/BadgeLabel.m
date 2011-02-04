#import "BadgeLabel.h"

@implementation BadgeLabel
//! Class override to draw badge behind label in textview

- (void) awakeFromNib {
	
	NSLog(@"BadgeLabel awakeFromNib");
	
	// Add rounded edges
	[[self layer] setCornerRadius:9.5f];
	
	// Add border with white color
    [[self layer] setBorderWidth:2.2f];
    [[self layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	
}

- (void)drawTextInRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextClip(context);
	
	CGGradientRef gradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 4;
	CGFloat locations[4] = { 0.0, 0.5, 0.5, 1.0 };
	CGFloat components[16] = { 243/255., 173/255., 173/255., 1.0,  // Start color
        228/255., 76/255., 83/255., 1.0,    // Middle color
        218/255., 8/255., 18/255., 1.0,     // End color
        218/255., 8/255., 18/255., 1.0 };   // End color
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	//CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
	CGPoint botCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
	CGContextDrawLinearGradient(context, gradient, topCenter, botCenter, 0);
	
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(rgbColorspace);             
	
	[super drawTextInRect:rect];
	
}
@end
