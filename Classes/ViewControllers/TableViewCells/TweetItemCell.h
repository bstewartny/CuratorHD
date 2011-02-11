#import <UIKit/UIKit.h>

@interface TweetItemCell : UITableViewCell {
	IBOutlet UIButton * selectButton;
	IBOutlet UIButton * selectButtonOverlay;
	IBOutlet UILabel * sourceLabel;
	IBOutlet UILabel * dateLineLabel;
	IBOutlet UILabel * headlineLabel;
	IBOutlet UIImageView * dateLineImageView;
}
@property(nonatomic,retain) IBOutlet UIButton * selectButton;
@property(nonatomic,retain) IBOutlet UIButton * selectButtonOverlay;
@property(nonatomic,retain) IBOutlet UILabel * dateLineLabel;
@property(nonatomic,retain) IBOutlet UILabel * sourceLabel;
@property(nonatomic,retain) IBOutlet UILabel * headlineLabel;
@property(nonatomic,retain) IBOutlet UIImageView * dateLineImageView;

@end
