#import "FolderTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FolderItemView.h"

@implementation FolderTableViewCell
@synthesize headlineLabel,dateLabel,sourceLabel,synopsisLabel,commentLabel,itemImageView,itemView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
	{
		UIView * bg=[[UIView alloc] init];
		
		bg.backgroundColor=[UIColor clearColor];
		
		self.selectedBackgroundView=bg;
		
		[bg release];
		
		self.contentView.backgroundColor=[UIColor clearColor];
		self.contentView.opaque=NO;
		
		//self.selectedBackgroundView=nil;
		//self.contentView.backgroundColor=[UIColor clearColor];
		//self.backgroundColor=[UIColor clearColor];
		 
		itemView=[[FolderItemView alloc] initWithFrame:CGRectMake(20,10, self.contentView.bounds.size.width-40,self.contentView.bounds.size.height-20)];
		itemView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		itemView.opaque=YES;
		itemView.clipsToBounds=YES;
		itemView.layer.cornerRadius=11;
		itemView.layer.borderColor=[UIColor lightGrayColor].CGColor;
		itemView.layer.borderWidth=1;
		itemView.backgroundColor=[UIColor whiteColor];
		
		[self.contentView addSubview:itemView];
		
		itemImageView=[[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 72, 72)];
		itemImageView.layer.cornerRadius=10;
		itemImageView.clipsToBounds=YES;
		itemImageView.contentMode=UIViewContentModeScaleAspectFill;
		itemImageView.opaque=YES;
		itemImageView.backgroundColor=[UIColor lightGrayColor];
		
		[itemView addSubview:itemImageView];
		
		sourceLabel=[[UILabel alloc] initWithFrame:CGRectMake(84,8, 300, 16)];
		sourceLabel.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		sourceLabel.backgroundColor=[UIColor clearColor];
		sourceLabel.textColor=[UIColor grayColor];
		sourceLabel.opaque=NO;
		sourceLabel.font=[UIFont systemFontOfSize:14];
		
		[itemView addSubview:sourceLabel];
		
		dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(itemView.frame.size.width-150,8, 140, 16)];
		dateLabel.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
		dateLabel.backgroundColor=[UIColor clearColor];
		dateLabel.textAlignment=UITextAlignmentRight;
		dateLabel.textColor=[UIColor grayColor];
		dateLabel.opaque=NO;
		dateLabel.font=[UIFont systemFontOfSize:14];
		
		[itemView addSubview:dateLabel];
		
		headlineLabel=[[UILabel alloc] initWithFrame:CGRectMake(84, 24, itemView.frame.size.width-(84+10), 20)];
		headlineLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		headlineLabel.backgroundColor=[UIColor clearColor];
		headlineLabel.opaque=NO;
		headlineLabel.font=[UIFont boldSystemFontOfSize:17];
		
		[itemView addSubview:headlineLabel];
		
		synopsisLabel=[[UILabel alloc] initWithFrame:CGRectMake(84, 46, itemView.frame.size.width-(84+10), 30)];
		synopsisLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		synopsisLabel.backgroundColor=[UIColor clearColor];
		synopsisLabel.numberOfLines=2;
		synopsisLabel.opaque=NO;
		synopsisLabel.font=[UIFont systemFontOfSize:14];
		synopsisLabel.textColor=[UIColor grayColor];
		
		[itemView addSubview:synopsisLabel];
		
		commentLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 90, itemView.frame.size.width-20, 20)];
		commentLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		commentLabel.backgroundColor=[UIColor clearColor];
		commentLabel.opaque=NO;
		commentLabel.font=[UIFont italicSystemFontOfSize:17];
		commentLabel.textColor=[UIColor redColor];
		
		[itemView addSubview:commentLabel];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
	
	self.contentView.backgroundColor=[UIColor clearColor];
	
	//self.backgroundColor=[UIColor clearColor];
	//self.selectedBackgroundView.backgroundColor=[UIColor clearColor];
    // Configure the view for the selected state.
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if(synopsisLabel.text)
	{
		CGSize size=[synopsisLabel.text sizeWithFont:synopsisLabel.font];
		
		if(size.width > synopsisLabel.frame.size.width)
		{
			CGRect f=synopsisLabel.frame;
			f.size.height=34;
			synopsisLabel.frame=f;
			synopsisLabel.numberOfLines=2;
		}
		else 
		{
			synopsisLabel.numberOfLines=1;
			CGRect f=synopsisLabel.frame;
			f.size.height=17;
			synopsisLabel.frame=f;
		}
	}
}






- (void)dealloc 
{
	[dateLabel release];
	[sourceLabel release];
	[headlineLabel release];
	[synopsisLabel release];
	[commentLabel release];
	[itemImageView release];
	[itemView release];
    [super dealloc];
}


@end
