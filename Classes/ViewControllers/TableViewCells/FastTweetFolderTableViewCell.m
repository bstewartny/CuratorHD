#import "FastTweetFolderTableViewCell.h"

@implementation FastTweetFolderTableViewCell
@synthesize comments;

static UIFont * commentsFont;

+ (void) initialize
{
	if(self==[FastTweetFolderTableViewCell class])
	{
		commentsFont=[[UIFont italicSystemFontOfSize:14] retain];
	}
}

- (void)drawContentView:(CGRect)r
{
	//NSLog(@"drawContentView: %@",NSStringFromCGRect(r));
	
	[super drawContentView:r];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *commentsColor;
	UIColor *sourceColor;
	if(self.selected)
	{
		if(!self.editing)
		{
			sourceColor=[UIColor whiteColor];
			commentsColor=[UIColor whiteColor];
		}
		else 
		{
			sourceColor=[UIColor grayColor];
			commentsColor=[UIColor redColor];
		}
	}
	else 
	{
		sourceColor=[UIColor grayColor];
		commentsColor=[UIColor redColor];
	}
	 
	CGFloat width=self.contentView.bounds.size.width;
	
	if([comments length]>0)
	{
		[commentsColor set];
		[comments drawInRect:CGRectMake(16+userImage.size.width, 74, (width-16+userImage.size.width)-8,34) withFont:commentsFont lineBreakMode:UILineBreakModeTailTruncation];
	}
	else 
	{
		[sourceColor set];
		[@"Tap to add comments" drawInRect:CGRectMake(16+userImage.size.width, 74, (width-16+userImage.size.width)-8,34) withFont:commentsFont lineBreakMode:UILineBreakModeTailTruncation];
	}
}

- (void)dealloc 
{
	[comments release];
    [super dealloc];
}


@end