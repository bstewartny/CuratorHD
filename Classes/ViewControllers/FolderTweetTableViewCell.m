#import "FolderTweetTableViewCell.h"

@implementation FolderTweetTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
	{
		self.sourceLabel.font=[UIFont boldSystemFontOfSize:14];
		self.sourceLabel.textColor=[UIColor blackColor];
		self.headlineLabel.font=[UIFont systemFontOfSize:16];
		
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
