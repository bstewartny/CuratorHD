#import "FastFolderTableViewCell.h"

@implementation FastFolderTableViewCell
@synthesize origin,date,headline,synopsis,comments,itemImage;

static UIFont * sourceFont;
static UIFont * headlineFont;
static UIFont * synopsisFont;
static UIFont * commentsFont;

+ (void) initialize
{
	if(self==[FastFolderTableViewCell class])
	{
		sourceFont=[[UIFont systemFontOfSize:12] retain];
		headlineFont=[[UIFont boldSystemFontOfSize:17] retain];
		synopsisFont=[[UIFont systemFontOfSize:12] retain];
		commentsFont=[[UIFont italicSystemFontOfSize:14] retain];
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

- (void) setHeadline:(NSString *)h
{
	[headline release];
	headline=[h copy];
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(self.editing)
	{
		touchDownOnImage=NO;
		[super touchesBegan:touches withEvent:event];
		return;
	}
	touchDownOnImage=NO;
	if([self didTouchImage:touches])
	{
		touchDownOnImage=YES;
	}
	if(!touchDownOnImage)
	{
		[super touchesBegan:touches withEvent:event];
	}
}

- (BOOL) didTouchImage:(NSSet*)touches
{
	if([touches count]==1)
	{
		UITouch * touch=[touches anyObject];
		if([touch tapCount]>0 && [touch tapCount]<3)
		{
			CGPoint location=[touch locationInView:contentView2];
			
			if(location.x>=4 && location.x<=4+62 &&
			   location.y>=4 && location.y<=4+62)
			{
				
				NSLog(@"user touched image");
				return YES;
			}
		}
	}
	return NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(self.editing)
	{
		touchDownOnImage=NO;
		[super touchesMoved:touches withEvent:event];
		return;
	}
	
	if(touchDownOnImage)
	{
		touchDownOnImage=NO;
	}
	else 
	{
		[super touchesMoved:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(self.editing)
	{
		touchDownOnImage=NO;
		[super touchesEnded:touches withEvent:event];
		return;
	}
	
	if(touchDownOnImage)
	{
		touchDownOnImage=NO;
		if([self didTouchImage:touches])
		{
			 // show action sheet...
			UIActionSheet * sheet=[[UIActionSheet alloc] initWithTitle:@"Test" delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:@"test" otherButtonTitles:nil];
			
			[sheet showFromRect:CGRectMake(4, 4, 62, 62) inView:contentView2 animated:YES];
			
			[sheet release];
		}
	}
	else 
	{
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchDownOnImage=NO;
	[super touchesCancelled:touches withEvent:event];
}

- (void)drawContentView:(CGRect)r
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *bbackgroundColor;
	UIColor *headlineColor;
	UIColor *sourceColor;
	UIColor *synopsisColor;
	UIColor *commentsColor;
	
	if(self.selected)
	{
		if(!self.editing)
		{
			bbackgroundColor = [UIColor clearColor];
			headlineColor = [UIColor whiteColor];
			sourceColor = [UIColor whiteColor];
			synopsisColor = [UIColor whiteColor];
			commentsColor=[UIColor whiteColor];
		}
		else 
		{
			bbackgroundColor = [UIColor clearColor];
			headlineColor =[UIColor blackColor];
			sourceColor = [UIColor grayColor];
			synopsisColor = [UIColor grayColor];
			commentsColor=[UIColor redColor];
		}
	}
	else 
	{
		bbackgroundColor = [UIColor whiteColor];
		headlineColor =[UIColor blackColor];
		sourceColor = [UIColor grayColor];
		synopsisColor = [UIColor grayColor];
		commentsColor=[UIColor redColor];
	}
	
	[bbackgroundColor set];
	CGContextFillRect(context, self.contentView.bounds);
	
	if(itemImage)
	{
		[itemImage drawInRect:CGRectMake(4, 4, 62, 62)];
	}
	else 
	{
		// draw add image button
		[sourceColor set];
		
		CGRect r=CGRectMake(4,4,62,62);
		CGFloat radius=8;
		CGFloat left=CGRectGetMinX(r);
		CGFloat right=CGRectGetMaxX(r);
		CGFloat top=CGRectGetMinY(r);
		CGFloat bottom=CGRectGetMaxY(r);
		//CGFloat	line_length=r.size.width-(radius*2);
		
		CGContextSetLineWidth(context, 1);
		CGContextMoveToPoint(context, left+radius, top);
		CGContextAddLineToPoint(context, right-radius, top);
		CGContextAddArcToPoint(context, right, top, right, top+radius,radius);
		CGContextAddLineToPoint(context,right, bottom-radius);
		CGContextAddArcToPoint(context, right, bottom, right-radius, bottom, radius);
		CGContextAddLineToPoint(context, left+radius, bottom);
		CGContextAddArcToPoint(context, left, bottom, left, bottom-radius, radius);
		CGContextAddLineToPoint(context, left, top+radius);
		CGContextAddArcToPoint(context, left, top, left+radius, top, radius);
		
		CGContextStrokePath(context);
		
		[@"Add" drawInRect:CGRectMake(left, (bottom-top)/2 - 13, right-left, 14) withFont:sourceFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		[@"Image" drawInRect:CGRectMake(left, (bottom-top)/2 + 1, right-left, 14) withFont:sourceFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		
		
	}

	CGPoint p;
	p.x = 70;
	p.y = 0;
	
	[sourceColor set];
	[origin drawAtPoint:p withFont:sourceFont];
	
	CGFloat width=self.contentView.bounds.size.width;
	
	[date drawInRect:CGRectMake(width-150, 0, 140, 14) withFont:sourceFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	
	[headlineColor set];
	
	[headline drawInRect:CGRectMake(70, 14, width-78, 18) withFont:headlineFont lineBreakMode:UILineBreakModeTailTruncation];
	
	[synopsisColor set];
	[synopsis drawInRect:CGRectMake(70,35, width-78, 28) withFont:synopsisFont lineBreakMode:UILineBreakModeTailTruncation];
	
	// draw seperator line
	/*CGContextSetLineWidth(context,1);
	
	CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
	
	CGContextMoveToPoint(context,0,70);
	
	CGContextAddLineToPoint(context,width,70);
	
	CGContextStrokePath(context);
	*/
	if([comments length]>0)
	{
		[commentsColor set];
		[comments drawInRect:CGRectMake(70, 74, width-78,28) withFont:commentsFont lineBreakMode:UILineBreakModeTailTruncation];
	}
	else 
	{
		[sourceColor set];
		[@"Tap to add comments" drawInRect:CGRectMake(70, 74, width-78,28) withFont:commentsFont lineBreakMode:UILineBreakModeTailTruncation];
	}
}

- (void)dealloc 
{	[origin release];
	[date release];
	[headline release];
	[synopsis release];
	[comments release];
	[itemImage release];
    [super dealloc];
}


@end
