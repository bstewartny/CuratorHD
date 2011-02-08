#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class FeedItem;

@interface FeedItemCell : UITableViewCell {
	IBOutlet UILabel * sourceLabel;
	IBOutlet UILabel * dateLabel;
	IBOutlet UILabel * headlineLabel;
	IBOutlet UILabel * synopsisLabel;
	IBOutlet UIImageView * sourceImageView;
	IBOutlet UIImageView * readImageView;
}

@property(nonatomic,retain) IBOutlet UILabel * dateLabel;
@property(nonatomic,retain) IBOutlet UILabel * sourceLabel;
@property(nonatomic,retain) IBOutlet UILabel * headlineLabel;
@property(nonatomic,retain) IBOutlet UIImageView * sourceImageView;
@property(nonatomic,retain) IBOutlet UILabel * synopsisLabel;
@property(nonatomic,retain) IBOutlet UIImageView * readImageView;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end

@interface NewsletterHeadlineItemCell : UITableViewCell
{
	IBOutlet UILabel * sourceLabel;
	IBOutlet UILabel * dateLabel;
	IBOutlet UILabel * headlineLabel;
	IBOutlet UILabel * synopsisLabel;
	IBOutlet UIImageView * itemImageView;
}

@property(nonatomic,retain) IBOutlet UILabel * dateLabel;
@property(nonatomic,retain) IBOutlet UILabel * sourceLabel;
@property(nonatomic,retain) IBOutlet UILabel * headlineLabel;
@property(nonatomic,retain) IBOutlet UILabel * synopsisLabel;
@property(nonatomic,retain) IBOutlet UIImageView * itemImageView;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end


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
