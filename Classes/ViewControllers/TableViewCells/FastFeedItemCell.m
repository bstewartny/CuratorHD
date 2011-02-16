#import "FastFeedItemCell.h"

@implementation FastFeedItemCell
@synthesize origin,date,headline,synopsis,readHeadlineColor;

static UIFont * sourceFont;
static UIFont * headlineFont;
static UIFont * synopsisFont;

+ (void) initialize
{
	if(self==[FastFeedItemCell class])
	{
		sourceFont=[[UIFont systemFontOfSize:12] retain];
		headlineFont=[[UIFont boldSystemFontOfSize:17] retain];
		synopsisFont=[[UIFont systemFontOfSize:14] retain];
	}
}

- (void) setHeadline:(NSString *)h
{
	[headline release];
	headline=[h copy];
	[self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{    
    [super setSelected:selected animated:animated];
	if(selected)
	{
		self.readHeadlineColor=[UIColor grayColor];
		[self setNeedsDisplay];
	}
}

- (void)drawContentView:(CGRect)r
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *bbackgroundColor;
	UIColor *headlineColor;
	UIColor *sourceColor;
	UIColor *synopsisColor;
	
	if(self.selected)
	{
		if(!self.editing)
		{
			bbackgroundColor = [UIColor clearColor];
			headlineColor = [UIColor whiteColor];
			sourceColor = [UIColor whiteColor];
			synopsisColor = [UIColor whiteColor];
		}
		else 
		{
			bbackgroundColor = [UIColor clearColor];
			headlineColor =readHeadlineColor;
			sourceColor = [UIColor grayColor];
			synopsisColor = [UIColor grayColor];
		}
	}
	else 
	{
		bbackgroundColor = [UIColor whiteColor];
		headlineColor =readHeadlineColor;
		sourceColor = [UIColor grayColor];
		synopsisColor = [UIColor grayColor];
	}

	[bbackgroundColor set];
	CGContextFillRect(context, self.contentView.bounds);
	
	CGPoint p;
	p.x = 10;
	p.y = 4;
	
	[sourceColor set];
	[origin drawAtPoint:p withFont:sourceFont];
	
	CGFloat width=self.contentView.bounds.size.width;
	
	[date drawInRect:CGRectMake(width-150, 4, 140, 14) withFont:sourceFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	
	[headlineColor set];
	
	[headline drawInRect:CGRectMake(10, 18, width-18, 18) withFont:headlineFont lineBreakMode:UILineBreakModeTailTruncation];
	
	[synopsisColor set];
	[synopsis drawInRect:CGRectMake(10,40, width-18, 40) withFont:synopsisFont lineBreakMode:UILineBreakModeTailTruncation];
}

- (void)dealloc 
{
	[origin release];
	[synopsis release];
	[date release];
	[headline release];
	[readHeadlineColor release];
    [super dealloc];
}


@end