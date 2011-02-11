#import <UIKit/UIKit.h>

@class FeedItem;

@interface ItemImageCell : UITableViewCell
{
	UIButton * imageButton;
	UIImageView * itemImageView;
	FeedItem * item;
	UIPopoverController * imagePickerPopover;
}
@property(nonatomic,retain) UIButton * imageButton;
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) UIImageView * itemImageView;
@property(nonatomic,retain) UIPopoverController * imagePickerPopover;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier;

- (void) setImage:(UIImage*)image;

@end
