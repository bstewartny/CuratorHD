#import <UIKit/UIKit.h>
#import "ItemImageCell.h"

@interface NewsletterHeadlineItemCell : ItemImageCell
{
	UILabel * sourceLabel;
	UILabel * dateLabel;
	UILabel * headlineLabel;
	UILabel * synopsisLabel;
	
}

@property(nonatomic,retain) UILabel * dateLabel;
@property(nonatomic,retain) UILabel * sourceLabel;
@property(nonatomic,retain) UILabel * headlineLabel;
@property(nonatomic,retain) UILabel * synopsisLabel;


@end


@end
