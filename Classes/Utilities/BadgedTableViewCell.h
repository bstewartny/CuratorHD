#import <UIKit/UIKit.h>
@class BadgeView;

@interface BadgedTableViewCell : UITableViewCell {
	NSString *badgeString;
	BadgeView *badge;
	
	UIColor *badgeColor;
	UIColor *badgeColorHighlighted;
}

@property (nonatomic, retain) NSString *badgeString;
@property (readonly, retain) BadgeView *badge;
@property (nonatomic, retain) UIColor *badgeColor;
@property (nonatomic, retain) UIColor *badgeColorHighlighted;

@end
