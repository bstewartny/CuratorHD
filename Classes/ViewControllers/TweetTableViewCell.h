#import <UIKit/UIKit.h>

@interface TweetTableViewCell : UITableViewCell {
	IBOutlet UILabel * tweetLabel;
	IBOutlet UIImageView * itemImageView;
	IBOutlet UILabel * dateLabel;
	IBOutlet UILabel * sourceLabel;
}

@property(nonatomic,retain) IBOutlet UILabel * tweetLabel;
@property(nonatomic,retain) IBOutlet UIImageView * itemImageView;
@property(nonatomic,retain) IBOutlet UILabel * dateLabel;
@property(nonatomic,retain) IBOutlet UILabel * sourceLabel;


@end
