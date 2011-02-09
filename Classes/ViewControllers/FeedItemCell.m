#import "FeedItemCell.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeedItemCell
@synthesize readImageView,synopsisLabel,sourceLabel,dateLabel,headlineLabel,sourceImageView;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])
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

@implementation NewsletterHeadlineItemCell
@synthesize imageButton,item,synopsisLabel,sourceLabel,dateLabel,headlineLabel;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])
	{
		CGRect f=self.contentView.bounds;
		
		imageButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		imageButton.frame=CGRectMake(4,4,62,62);
		
		imageButton.clipsToBounds=YES;
		imageButton.opaque=YES;
		imageButton.layer.cornerRadius=9.5;
		[imageButton addTarget:self action:@selector(imageButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
		//itemImageView.contentMode=UIViewContentModeScaleAspectFill;
		imageButton.backgroundColor=[UIColor lightGrayColor];
		
		[self.contentView addSubview:imageButton];
		
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

- (void) setItem:(FeedItem*)theItem
{
	if(![item isEqual:theItem])
	{
		[item release];
		item=[theItem retain];
		
		[imageButton setImage:item.image forState:UIControlStateNormal];
		[imageButton setNeedsDisplay];
		[self setNeedsDisplay];
	}
}

- (void) imageButtonTouch:(id)sender
{
	UIAlertView * a=[[UIAlertView alloc] initWithTitle:@"alert" message:item.headline delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[a show];
	[a release];
}

- (void)dealloc 
{
	[item release];
	[dateLabel release];
	[headlineLabel release];
	[sourceLabel release];
	[synopsisLabel release];
	[imageButton release];
    [super dealloc];
}

@end

@implementation TweetItemCell
@synthesize selectButton,selectButtonOverlay,sourceLabel,dateLineLabel,headlineLabel,dateLineImageView;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
	if(selected)
	{
		self.layer.shadowColor=[UIColor blackColor].CGColor;
		self.layer.shadowOpacity=1.0;
		self.layer.shadowRadius=5.0;
		self.layer.zPosition=9999;
		self.clipsToBounds=NO;
		self.headlineLabel.font=[UIFont systemFontOfSize:16];
	}
	else 
	{
		self.layer.shadowColor=[UIColor clearColor].CGColor;
		self.layer.shadowOpacity=1.0;
		self.layer.shadowRadius=0.0;
		self.layer.shadowOffset=CGSizeMake(0,0);
		self.layer.zPosition=0;
		self.clipsToBounds=YES;
	}
}

- (void)dealloc {
	[selectButton release];
	[selectButtonOverlay release];
	[dateLineLabel release];
	[headlineLabel release];
	[sourceLabel release];
	[dateLineImageView release];
    [super dealloc];
}


@end

