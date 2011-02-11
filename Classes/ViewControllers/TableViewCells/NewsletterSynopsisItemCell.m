#import "NewsletterSynopsisItemCell.h"
#import "FeedItem.h"

@implementation NewsletterSynopsisItemCell
@synthesize sourceLabel,dateLabel,headlineLabel,commentLabel,synopsisTopLabel,synopsisBottomLabel;

static UIFont * _synopsisFont;
static UIFont * _commentsFont;

//static CGFloat _synopsisFontHeight;

+ (UIFont*) synopsisFont
{
	if(_synopsisFont==nil)
	{
		_synopsisFont=[UIFont systemFontOfSize:14];
		
		//NSString * fonttmp=@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
		
		//CGSize fontsize=[fonttmp sizeWithFont:_synopsisFont constrainedToSize:CGSizeMake(20000.0, 20000.0) lineBreakMode:UILineBreakModeWordWrap];
		
		//_synopsisFontHeight=fontsize.height;
	}
	return _synopsisFont;
}

+ (UIFont*) commentsFont
{
	if(_commentsFont==nil)
	{
		_commentsFont=[UIFont italicSystemFontOfSize:17];
		
		//NSString * fonttmp=@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
		
		//CGSize fontsize=[fonttmp sizeWithFont:_synopsisFont constrainedToSize:CGSizeMake(20000.0, 20000.0) lineBreakMode:UILineBreakModeWordWrap];
		
		//_synopsisFontHeight=fontsize.height;
	}
	return _commentsFont;
}

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithReuseIdentifier:reuseIdentifier])
	{
		CGRect f=self.contentView.bounds;
		
		sourceLabel=[[UILabel alloc] initWithFrame:CGRectMake(4,4, 300, 16)];
		sourceLabel.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		sourceLabel.backgroundColor=[UIColor clearColor];
		sourceLabel.textColor=[UIColor grayColor];
		sourceLabel.opaque=NO;
		sourceLabel.font=[UIFont systemFontOfSize:14];
		
		[self.contentView addSubview:sourceLabel];
		
		dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(f.size.width-150,4, 140, 16)];
		dateLabel.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
		dateLabel.backgroundColor=[UIColor clearColor];
		dateLabel.textAlignment=UITextAlignmentRight;
		dateLabel.textColor=[UIColor grayColor];
		dateLabel.opaque=NO;
		dateLabel.font=[UIFont systemFontOfSize:14];
		
		[self.contentView addSubview:dateLabel];
		
		headlineLabel=[[UILabel alloc] initWithFrame:CGRectMake(4, 22, f.size.width-8, 20)];
		headlineLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		headlineLabel.backgroundColor=[UIColor clearColor];
		headlineLabel.opaque=NO;
		headlineLabel.font=[UIFont boldSystemFontOfSize:17];
		
		[self.contentView addSubview:headlineLabel];
		
		synopsisTopLabel=[[UILabel alloc] initWithFrame:CGRectMake(4, 44, f.size.width-70, 16)];
		synopsisTopLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		synopsisTopLabel.backgroundColor=[UIColor clearColor];
		synopsisTopLabel.opaque=NO;
		synopsisTopLabel.font=[UIFont systemFontOfSize:14];
		synopsisTopLabel.numberOfLines=0;//100;
		synopsisTopLabel.textColor=[UIColor grayColor];
		synopsisTopLabel.lineBreakMode=UILineBreakModeWordWrap;
		
		[self.contentView addSubview:synopsisTopLabel];
		
		synopsisBottomLabel=[[UILabel alloc] initWithFrame:CGRectZero];
		synopsisBottomLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		synopsisBottomLabel.backgroundColor=[UIColor clearColor];
		synopsisBottomLabel.opaque=NO;
		synopsisBottomLabel.numberOfLines=0;//100;
		synopsisBottomLabel.font=[UIFont systemFontOfSize:14];
		synopsisBottomLabel.textColor=[UIColor grayColor];
		synopsisBottomLabel.lineBreakMode=UILineBreakModeWordWrap;
		
		[self.contentView addSubview:synopsisBottomLabel];
		
		commentLabel=[[UILabel alloc] initWithFrame:CGRectMake(4, 90, f.size.width-20, 60)];
		commentLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		commentLabel.backgroundColor=[UIColor clearColor];
		commentLabel.opaque=NO;
		commentLabel.numberOfLines=0;
		commentLabel.font=[UIFont italicSystemFontOfSize:17];
		commentLabel.textColor=[UIColor redColor];
		commentLabel.lineBreakMode=UILineBreakModeWordWrap;
		
		[self.contentView addSubview:commentLabel];
		
		imageButton.frame=CGRectMake(4,46,62,62);
		
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void) setItem:(FeedItem *)theItem
{
	[super setItem:theItem];
		
	dateLabel.text=[item shortDisplayDate];
	sourceLabel.text=[item origin];
	headlineLabel.text=[item headline];
	
	synopsisTopLabel.text=nil;
	synopsisBottomLabel.text=nil;
	commentLabel.text=nil;
}

- (void) setImage:(UIImage*)image
{
	[super setImage:image];
	
	if(_itemLayout.size.height>0)
	{
		// force table view redraw because we may have changed image size enough to overflow the table cell bounds
		if([self.superview isKindOfClass:[UITableView class]])
		{
			[self.superview reloadData];
		}
	}
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	NSLog(@"layoutSubviews");
	
	if(self.contentView.frame.size.width<=480) return; // some reason we get initial call with 320 and then a follow up call with actual cell width...
	
	_itemLayout=[NewsletterSynopsisItemCell layoutForItem:self.item withCellWidth:self.contentView.frame.size.width];
	
	imageButton.frame=_itemLayout.image_frame;
	
	synopsisTopLabel.frame=_itemLayout.synopsis_top_frame;
	
	if(_itemLayout.synopsis_break>0)
	{
		synopsisBottomLabel.frame=_itemLayout.synopsis_bottom_frame;
		
		synopsisBottomLabel.hidden=NO;
		
		synopsisTopLabel.text=[item.synopsis substringToIndex:_itemLayout.synopsis_break+1];
		synopsisBottomLabel.text=[item.synopsis substringFromIndex:_itemLayout.synopsis_break+2];
	}
	else 
	{
		synopsisTopLabel.text=item.synopsis;
		synopsisBottomLabel.frame=CGRectZero;
		synopsisBottomLabel.hidden=YES;
	}
	
	if([item.notes length]>0)
	{
		commentLabel.frame=_itemLayout.comments_frame;
		commentLabel.text=item.notes;
	}
	else 
	{
		commentLabel.frame=_itemLayout.comments_frame;
		commentLabel.text=nil;
	}
}

+ (NewsletterSynopsisItemCellLayout) layoutForItem:(FeedItem*)item withCellWidth:(CGFloat)cellWidth
{
	//NSLog(@"layoutForItem:withCellWidth:%f",cellWidth);

	NewsletterSynopsisItemCellLayout layout;
	
	CGFloat top=46;
	CGFloat left;
	CGFloat bottom;
	CGFloat total_height=0;
	
	if(item.image)
	{
		layout.image_frame=CGRectMake(4, top, item.image.size.width, item.image.size.height);
		left=4+item.image.size.width+8;
		bottom=top+item.image.size.height+8;
	}
	else 
	{
		layout.image_frame=CGRectMake(4, top, 62, 62);
		left=4+62+8;
		bottom=top+62+8;
	}
	
	total_height=bottom;
	
	CGRect top_part=CGRectMake(left, top, cellWidth - (left+8), bottom-top);
	
	UIFont * synopsis_font=[NewsletterSynopsisItemCell synopsisFont];
	
	CGSize size=[item.synopsis sizeWithFont:synopsis_font constrainedToSize:CGSizeMake(top_part.size.width, 20000.0) lineBreakMode:UILineBreakModeWordWrap];
	
	if(size.height<=top_part.size.height)
	{
		layout.synopsis_top_frame=CGRectMake(top_part.origin.x, top_part.origin.y, size.width, size.height);
		layout.synopsis_bottom_frame=CGRectZero;
		layout.synopsis_break=0;
	}
	else 
	{
		layout.synopsis_top_frame=top_part;
		layout.synopsis_break=[NewsletterSynopsisItemCell findBestFit:item.synopsis withFont:synopsis_font constrainedToSize:top_part.size];
		NSString * bottom_synopsis=[item.synopsis substringFromIndex:layout.synopsis_break+2];
		CGSize bottom_size=[bottom_synopsis sizeWithFont:synopsis_font constrainedToSize:CGSizeMake(cellWidth-16, 20000.0) lineBreakMode:UILineBreakModeWordWrap];
		layout.synopsis_bottom_frame=CGRectMake(8, bottom, bottom_size.width, bottom_size.height);
		total_height+=layout.synopsis_bottom_frame.size.height+8;
	}
	
	if([item.notes length]>0)
	{
		UIFont * comments_font=[NewsletterSynopsisItemCell commentsFont];
		
		CGSize comment_size=[item.notes sizeWithFont:comments_font constrainedToSize:CGSizeMake(cellWidth-16, 20000.0) lineBreakMode:UILineBreakModeWordWrap];
		
		layout.comments_frame=CGRectMake(4, total_height, cellWidth-16,comment_size.height);
		
		total_height+=comment_size.height+8;
	}
	else 
	{
		layout.comments_frame=CGRectMake(4, total_height, cellWidth-16, 30);
		total_height+=layout.comments_frame.size.height+8;
	}
	
	total_height+=100;
	
	layout.size=CGSizeMake(cellWidth, total_height);
	
	return layout;
}




+ (int) findBestFit:(NSString*)text withFont:(UIFont*)font constrainedToSize:(CGSize)constraint
{
	NSLog(@"findBestFit");
	
	CGSize tmp_size=CGSizeMake(constraint.width, 20000.0f);
	
	// set up for search
    NSMutableString * dest = [[[NSMutableString alloc] initWithCapacity:20] autorelease];
    
    NSInteger position=0;
	
	NSInteger lo = 0;
	NSInteger hi = [text length];
	
    // binary search for the best-fitting string
    while (true)
    {
        position = lo + ((hi - lo) / 2);
        
		if ((position == lo) && (lo != hi)) position++;
        
		NSLog(@"Test best fit at positiong: %d",position);
		
		NSString * tmp=[text substringToIndex:position] ;
        
		CGSize size=[tmp sizeWithFont:font constrainedToSize:tmp_size lineBreakMode:UILineBreakModeWordWrap];
		
		BOOL fits=(size.height <= constraint.height);
                
        if (fits)
        {
            lo = position;
        }    
        else
        {
            hi = position - 1;
        }    
		
        if ((lo >= hi) && fits) break;
		
        if ((lo <= 0) && (hi <= 0)) break;
    }
	
	// go back from position to find next word boundary...
	unichar c=[text characterAtIndex:position];
	
	while (!(c==' ' || c=='\n')) 
	{
		NSLog(@"backup one character...");
		position--;
		c=[text characterAtIndex:position];
	}		
	
	return position;
}
/*
+ (int) findBestFit:(NSString*)text withFont:(UIFont*)font constrainedToSize:(CGSize)constraint
{
	NSMutableString * copy=[[text mutableCopy] autorelease];
	
	NSLog(@"findBestFit: size=%d",[text length]);
	
	int i=[text length] -1;
	
	CGSize tmp_size=CGSizeMake(constraint.width, 20000.0f);
	
	BOOL found_middle=NO;
	
	unichar prev='\0';
	
	while(i>0)
	{
		if(!found_middle)
		{
			int middle = i / 2;
			
			[copy deleteCharactersInRange:NSMakeRange(middle, [copy length]-middle)];
			
			//NSString * tmp=[text substringToIndex:middle];
			
			CGSize size = [copy sizeWithFont:font constrainedToSize:tmp_size lineBreakMode:UILineBreakModeWordWrap];
			
			if(size.height <=constraint.height)
			{
				found_middle=YES;
				copy=[[text mutableCopy] autorelease];
			}
			else 
			{
				i=middle+1;
				continue;
			}
		}
		
		unichar c=[text characterAtIndex:i--];
		
		if(c==' ' || c=='\n')
		{
			if(prev==' ' || prev=='\n')
			{
				NSLog(@"prev was whitespace, skipping test...");
				continue;
			}
			
			[copy deleteCharactersInRange:NSMakeRange(i+1, [copy length]-(i+1))];
			
			//NSString * tmp=[text substringToIndex:i+1];
			
			NSLog(@"Checking size to index: %d",i);
			
			CGSize size = [copy sizeWithFont:font constrainedToSize:tmp_size lineBreakMode:UILineBreakModeWordWrap];
			
			if(size.height <= constraint.height)
			{
				break;
			}
		}
		
		prev=c;
	}
	
	NSLog(@"got best fit: %d",i);
	return i;
}*/

- (void)dealloc 
{
	[sourceLabel release];
	[dateLabel release];
	[headlineLabel release];
	[synopsisBottomLabel release];
	[synopsisTopLabel release];
	[commentLabel release];
    [super dealloc];
}


@end
