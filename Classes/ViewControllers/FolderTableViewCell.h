#import <UIKit/UIKit.h>
#import "FeedItemCell.h"
#import "ItemImageCell.h"

@interface FolderTableViewCell : ItemImageCell 
{
	IBOutlet UILabel * headlineLabel;
	IBOutlet UILabel * synopsisLabel;
	IBOutlet UILabel * commentLabel;
	//IBOutlet UIImageView * itemImageView;
	IBOutlet UIView * itemView;
	IBOutlet UILabel * dateLabel;
	IBOutlet UILabel * sourceLabel;
}

@property(nonatomic,retain) IBOutlet UILabel * headlineLabel;
@property(nonatomic,retain) IBOutlet UILabel * synopsisLabel;
@property(nonatomic,retain) IBOutlet UILabel * commentLabel;
//@property(nonatomic,retain) IBOutlet UIImageView * itemImageView;
@property(nonatomic,retain) IBOutlet UIView * itemView;
@property(nonatomic,retain) IBOutlet UILabel * dateLabel;
@property(nonatomic,retain) IBOutlet UILabel * sourceLabel;

@end
