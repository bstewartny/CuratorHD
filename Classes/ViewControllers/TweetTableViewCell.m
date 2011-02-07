#import "TweetTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
 

@implementation TweetTableViewCell
@synthesize tweetLabel,dateLabel,sourceLabel,itemImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
	{
		itemImageView=[[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 50, 50)];
		itemImageView.layer.cornerRadius=4;
		itemImageView.clipsToBounds=YES;
		itemImageView.contentMode=UIViewContentModeScaleAspectFill;
		itemImageView.opaque=YES;
		
		[self.contentView addSubview:itemImageView];
		
		sourceLabel=[[UILabel alloc] initWithFrame:CGRectMake(60,2, 300, 16)];
		sourceLabel.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		sourceLabel.backgroundColor=[UIColor clearColor];
		sourceLabel.textColor=[UIColor blackColor];
		sourceLabel.opaque=NO;
		sourceLabel.font=[UIFont boldSystemFontOfSize:14];
		
		[self.contentView addSubview:sourceLabel];
		
		dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-150,2, 140, 16)];
		dateLabel.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
		dateLabel.backgroundColor=[UIColor clearColor];
		dateLabel.textAlignment=UITextAlignmentRight;
		dateLabel.textColor=[UIColor lightGrayColor];
		dateLabel.opaque=NO;
		dateLabel.font=[UIFont systemFontOfSize:14];
		
		[self.contentView addSubview:dateLabel];
		
		tweetLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 20, self.frame.size.width-(58+10), 38)];
		tweetLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		tweetLabel.backgroundColor=[UIColor clearColor];
		tweetLabel.numberOfLines=2;
		tweetLabel.opaque=NO;
		tweetLabel.font=[UIFont systemFontOfSize:16];
		tweetLabel.textColor=[UIColor blackColor];
		
		[self.contentView addSubview:tweetLabel];
	
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
}
/*
- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if(tweetLabel.text)
	{
		CGSize size=[tweetLabel.text sizeWithFont:tweetLabel.font];
	
		if(size.width > tweetLabel.frame.size.width)
		{
			CGRect f=tweetLabel.frame;
			f.size.height=38;
			tweetLabel.frame=f;
			tweetLabel.numberOfLines=2;
		}
		else {
			tweetLabel.numberOfLines=1;
			CGRect f=tweetLabel.frame;
			f.size.height=19;
			tweetLabel.frame=f;
		}
	}
}*/
- (void)dealloc 
{
	[dateLabel release];
	[sourceLabel release];
	[tweetLabel release];
	[itemImageView release];
    [super dealloc];
}


@end

