#import "BadgeView.h"

@interface BadgeView ()

@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) NSUInteger width;

@end

@implementation BadgeView

@synthesize width, badgeString, parent, badgeColor, badgeColorHighlighted;
// from private
@synthesize font;

- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		font = [[UIFont boldSystemFontOfSize: 14] retain];
		
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;	
}

- (void) drawRect:(CGRect)rect
{	
	NSString *countString = self.badgeString;
	
	CGSize numberSize = [countString sizeWithFont: font];
	
	self.width = numberSize.width + 16;
	
	CGRect bounds = CGRectMake(0 , 0, numberSize.width + 16 , 18);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	float radius = bounds.size.height / 2.0;
	
	CGContextSaveGState(context);
	
	UIColor *col;
	if (parent.highlighted || parent.selected) {
		if (self.badgeColorHighlighted) {
			col = self.badgeColorHighlighted;
		} else {
			col = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.000];
		}
	} else {
		if (self.badgeColor) {
			col = self.badgeColor;
		} else {
			col = [UIColor colorWithRed:0.530 green:0.600 blue:0.738 alpha:1.000];
		}
	}
	
	CGContextSetFillColorWithColor(context, [col CGColor]);
	
	CGContextBeginPath(context);
	CGContextAddArc(context, radius, radius, radius, M_PI / 2 , 3 * M_PI / 2, NO);
	CGContextAddArc(context, bounds.size.width - radius, radius, radius, 3 * M_PI / 2, M_PI / 2, NO);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	bounds.origin.x = (bounds.size.width - numberSize.width) / 2 +0.5;
	
	CGContextSetBlendMode(context, kCGBlendModeClear);
	
	[countString drawInRect:bounds withFont:self.font];
}

- (void) dealloc
{
	parent = nil;
	
	[font release];
	[badgeColor release];
	[badgeColorHighlighted release];
	
	[super dealloc];
}

@end