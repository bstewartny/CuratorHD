#import "TweetItemCell.h"
#import <QuartzCore/QuartzCore.h>

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
