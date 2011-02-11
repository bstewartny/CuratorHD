#import "NewsletterHeadlineItemCell.h"

@implementation NewsletterHeadlineItemCell
@synthesize synopsisLabel,sourceLabel,dateLabel,headlineLabel;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithReuseIdentifier:reuseIdentifier])
	{
		CGRect f=self.contentView.bounds;
		
		itemImageView.frame=CGRectMake(4,4,62,62);//, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
		imageButton.frame=CGRectMake(4,4,62,62);
		
		
		sourceLabel=[[UILabel alloc] initWithFrame:CGRectMake(70,4, 300, 16)];
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
		
		headlineLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 22, f.size.width-70, 20)];
		headlineLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		headlineLabel.backgroundColor=[UIColor clearColor];
		headlineLabel.opaque=NO;
		headlineLabel.font=[UIFont boldSystemFontOfSize:17];
		
		[self.contentView addSubview:headlineLabel];
		
		synopsisLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 44, f.size.width-70, 16)];
		synopsisLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		synopsisLabel.backgroundColor=[UIColor clearColor];
		synopsisLabel.opaque=NO;
		synopsisLabel.font=[UIFont systemFontOfSize:14];
		synopsisLabel.textColor=[UIColor grayColor];
		
		[self.contentView addSubview:synopsisLabel];
	}
    return self;
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
	if(editing)
	{
		self.selectionStyle=3;
	}
	else 
	{
		self.selectionStyle=UITableViewCellSelectionStyleNone;
	}
	[super setEditing:editing animated:animated];
}

- (void)dealloc 
{
	[dateLabel release];
	[headlineLabel release];
	[sourceLabel release];
	[synopsisLabel release];
    [super dealloc];
}

@end

