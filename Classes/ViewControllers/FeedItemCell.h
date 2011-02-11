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
