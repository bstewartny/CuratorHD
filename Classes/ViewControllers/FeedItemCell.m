#import "FeedItemCell.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageResizer.h"
#import "ImageListViewController.h"

@implementation FeedItemCell
@synthesize readImageView,synopsisLabel,sourceLabel,dateLabel,headlineLabel,sourceImageView;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
		CGRect f=self.contentView.bounds;
		
		readImageView=[[UIImageView alloc] initWithFrame:CGRectMake(4, 27, 11, 11)];
		readImageView.clipsToBounds=YES;
		readImageView.opaque=YES;
		
		[self.contentView addSubview:readImageView];
		
		sourceImageView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 4, 16, 16)];
		sourceImageView.clipsToBounds=YES;
		sourceImageView.contentMode=UIViewContentModeScaleAspectFill;
		sourceImageView.opaque=YES;
		
		[self.contentView addSubview:sourceImageView];
		
		sourceLabel=[[UILabel alloc] initWithFrame:CGRectMake(40,4, 300, 16)];
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
		
		headlineLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 22, f.size.width-30, 20)];
		headlineLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		headlineLabel.backgroundColor=[UIColor clearColor];
		headlineLabel.opaque=NO;
		headlineLabel.font=[UIFont boldSystemFontOfSize:17];
		
		[self.contentView addSubview:headlineLabel];
		
		synopsisLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 44, f.size.width-30, 16)];
		synopsisLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		synopsisLabel.backgroundColor=[UIColor clearColor];
		synopsisLabel.opaque=NO;
		synopsisLabel.font=[UIFont systemFontOfSize:14];
		synopsisLabel.textColor=[UIColor grayColor];
		
		[self.contentView addSubview:synopsisLabel];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	[super setSelected:selected animated:animated];

    if(selected)
	{
		self.headlineLabel.textColor=[UIColor grayColor];
		self.readImageView.image=[UIImage imageNamed:@"dot_blank.png"];
	}
}

- (void)dealloc 
{
	[dateLabel release];
	[headlineLabel release];
	[sourceLabel release];
	[sourceImageView release];
	[synopsisLabel release];
	[readImageView release];
    [super dealloc];
}

@end


