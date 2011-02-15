#import "FastTweetTableViewCell.h"

@implementation FastTweetTableViewCell
@synthesize userImage,username,tweet,date;

static UIFont * usernameFont;
static UIFont * dateFont;
static UIFont * tweetFont;

+ (void) initialize
{
	if(self==[FastTweetTableViewCell class])
	{
		usernameFont=[[UIFont boldSystemFontOfSize:14] retain];
		tweetFont=[[UIFont systemFontOfSize:16] retain];
		dateFont=[[UIFont systemFontOfSize:12] retain];
	}
}

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void) setTweet:(NSString *)t
{
	[tweet release];
	tweet=[t copy];
	[self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *bbackgroundColor;
	UIColor *tweetColor;
	UIColor *dateColor;
	UIColor *usernameColor;
	
	if(self.selected)
	{
		if(!self.editing)
		{
			bbackgroundColor = [UIColor clearColor];
			tweetColor = [UIColor whiteColor];
			dateColor = [UIColor whiteColor];
			usernameColor=[UIColor whiteColor];
		}
		else 
		{
			bbackgroundColor = [UIColor clearColor];
			tweetColor = [UIColor blackColor];
			dateColor = [UIColor grayColor];
			usernameColor=[UIColor blackColor];
		}
	}
	else 
	{
		bbackgroundColor = [UIColor whiteColor];
		tweetColor = [UIColor blackColor];
		dateColor = [UIColor grayColor];
		usernameColor=[UIColor blackColor];
	}
	
	[bbackgroundColor set];
	
	CGContextFillRect(context, self.contentView.bounds);
	
	[userImage drawAtPoint:CGPointMake(8, 8)];
	
	CGPoint p;
	
	p.x = 16+userImage.size.width;
	p.y = 0;
	
	[usernameColor set];
	
	[username drawAtPoint:p withFont:usernameFont];
	
	CGFloat width=self.contentView.bounds.size.width;
	
	[dateColor set];
	
	[date drawInRect:CGRectMake(width-150, 0, 140, 15) withFont:dateFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	
	[tweetColor set];
	
	[tweet  drawInRect:CGRectMake(p.x, 15, width-p.x, 54) withFont:tweetFont lineBreakMode:UILineBreakModeWordWrap];
}



- (void)dealloc 
{
	[userImage release];
	[username release];
	[tweet release];
	[date release];
    [super dealloc];
}


@end
