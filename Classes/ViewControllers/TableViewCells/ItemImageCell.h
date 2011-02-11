#import <UIKit/UIKit.h>

@class FeedItem;

@interface ItemImageCell : UITableViewCell
{
	UIButton * imageButton;
	FeedItem * item;
	UIPopoverController * imagePickerPopover;
}
@property(nonatomic,retain) IBOutlet UIButton * imageButton;
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) UIPopoverController * imagePickerPopover;

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier;

- (void) setImage:(UIImage*)image;

@end
