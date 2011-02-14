#import <UIKit/UIKit.h>
#import "FastTweetTableViewCell.h"

@interface FastTweetFolderTableViewCell : FastTweetTableViewCell {
	NSString * comments;
}
@property(nonatomic,retain) NSString * comments;
@end
