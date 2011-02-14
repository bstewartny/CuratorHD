#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface FastFeedItemCell : ABTableViewCell 
{
	NSString * origin;
	NSString * date;
	NSString * headline;
	NSString * synopsis;
	UIColor * readHeadlineColor;
}

@property(nonatomic,retain) NSString * origin;
@property(nonatomic,retain) NSString * date;
@property(nonatomic,retain) NSString * headline;
@property(nonatomic,retain) NSString * synopsis;
@property(nonatomic,retain) UIColor * readHeadlineColor;

@end
