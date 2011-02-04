#import "FeedItemCell.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
/*@implementation WideFeedItemCell


- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])
	{
		
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
    if(selected)
	{
		self.textLabel.textColor=[UIColor grayColor];
		self.imageView.image=[UIImage imageNamed:@"dot_blank.png"];
	}
}

- (void)dealloc 
{
	[super dealloc];
}

@end

@implementation FolderItemCell

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self=[super initWithReuseIdentifier:reuseIdentifier])
	{
		self.contentView.layer.cornerRadius=11.0;
		
		self.contentView.backgroundColor=[UIColor whiteColor];
		self.contentView.layer.borderColor=[UIColor lightGrayColor].CGColor;
		self.contentView.layer.borderWidth=1.0;
		self.backgroundColor=[UIColor clearColor];
	}
	return self;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentViewFrame=[self bounds];
	contentViewFrame.origin.x+=40;
	contentViewFrame.size.width-=80;
	contentViewFrame.origin.y+=10;
	contentViewFrame.size.height-=20;
	self.contentView.frame=contentViewFrame;
	
	CGRect textLabelFrame=self.textLabel.frame;
	textLabelFrame.origin.y=4;
	textLabelFrame.size.width=(self.bounds.size.width-110);
	self.textLabel.frame=textLabelFrame;
	
	CGRect detailLabelFrame=self.detailTextLabel.frame;
	detailLabelFrame.origin.y=23;
	detailLabelFrame.size.width=(self.bounds.size.width-110);
	detailLabelFrame.size.height=(self.bounds.size.height-20) - (23 + 4);
	self.detailTextLabel.numberOfLines=3;
	self.detailTextLabel.frame=detailLabelFrame;
	
	CGRect imageViewFrame=self.imageView.frame;
	imageViewFrame.origin.y=34;
	self.imageView.frame=imageViewFrame;
}

@end*/

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


@implementation TweetItemCell
@synthesize selectButton,selectButtonOverlay,sourceLabel,dateLineLabel,headlineLabel,dateLineImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		//CAGradientLayer *gradient = [CAGradientLayer layer];
		//gradient.frame = CGRectMake(0,0,320,65); //self.bounds;
		//gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
		//[self.layer insertSublayer:gradient atIndex:0];
	}
    return self;
}

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
	//[synopsisLabel release];
    [super dealloc];
}


@end

