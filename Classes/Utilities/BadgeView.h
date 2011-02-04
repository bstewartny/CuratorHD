#import <UIKit/UIKit.h>

@interface BadgeView : UIView
{
	NSUInteger width;
	NSString *badgeString;
	
	UIFont *font;
	UITableViewCell *parent;
	
	UIColor *badgeColor;
	UIColor *badgeColorHighlighted;	
}

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, assign) NSString *badgeString;
@property (nonatomic, assign) UITableViewCell *parent;
@property (nonatomic, retain) UIColor *badgeColor;
@property (nonatomic, retain) UIColor *badgeColorHighlighted;

@end
