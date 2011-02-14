#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface FastFolderTableViewCell : ABTableViewCell {
	NSString * origin;
	NSString * date;
	NSString * headline;
	NSString * synopsis;
	UIImage * itemImage;
	NSString * comments;
	BOOL touchDownOnImage;
}
@property(nonatomic,retain) NSString * origin;
@property(nonatomic,retain) NSString * date;
@property(nonatomic,retain) NSString * headline;
@property(nonatomic,retain) NSString * synopsis;
@property(nonatomic,retain) UIImage * itemImage;
@property(nonatomic,retain) NSString * comments;

@end
