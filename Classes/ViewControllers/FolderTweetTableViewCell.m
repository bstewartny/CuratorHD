#import "FolderTweetTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FolderTweetTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) 
	{
		/*itemImageView=[[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 72, 72)];
		itemImageView.layer.cornerRadius=10;
		itemImageView.clipsToBounds=YES;
		itemImageView.contentMode=UIViewContentModeScaleAspectFill;
		itemImageView.opaque=YES;
		itemImageView.backgroundColor=[UIColor lightGrayColor];
		 
		[itemView addSubview:itemImageView];
		 */
		
		sourceLabel.frame=CGRectMake(84,8, 300, 16);
		sourceLabel.textColor=[UIColor blackColor];
		sourceLabel.font=[UIFont boldSystemFontOfSize:14];
		
		headlineLabel.frame=CGRectMake(84, 24, itemView.frame.size.width-(84+10), 20);
		headlineLabel.font=[UIFont systemFontOfSize:17];
		
	}
	return self;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if(headlineLabel.text)
	{
		CGSize size=[headlineLabel.text sizeWithFont:headlineLabel.font];
		
		if(size.width > headlineLabel.frame.size.width)
		{
			CGRect f=headlineLabel.frame;
			f.size.height=40;
			headlineLabel.frame=f;
			headlineLabel.numberOfLines=2;
		}
		else 
		{
			headlineLabel.numberOfLines=1;
			CGRect f=headlineLabel.frame;
			f.size.height=22;
			headlineLabel.frame=f;
		}
	}
}

@end
