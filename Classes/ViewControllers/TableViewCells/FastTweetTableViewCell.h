
#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface FastTweetTableViewCell : ABTableViewCell {
	UIImage * userImage;
	NSString * username;
	NSString * tweet;
	NSString * date;
}
@property(nonatomic,retain) UIImage * userImage;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * tweet;
@property(nonatomic,retain) NSString * date;

@end
