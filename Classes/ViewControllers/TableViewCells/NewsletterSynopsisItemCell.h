#import <UIKit/UIKit.h>
#import "ItemImageCell.h"

#define kCellWidth 625

#define kCellPadding 10
#define kFontSize 14
#define kHeadlineFontSize 16
#define kDateFontSize 14
#define kLineSpacing 4

struct NewsletterSynopsisItemCellLayout 
{
	CGSize size;
	//CGRect headline_frame;
	//CGRect source_frame;
	//CGRect date_frame;
	CGRect image_frame;
	int synopsis_break;
	CGRect synopsis_top_frame;
	CGRect synopsis_bottom_frame;
	CGRect comments_frame;
	//CGRect comments_frame;
	//CGRect cell_rect; // the rect this size was generated for...
};

typedef struct NewsletterSynopsisItemCellLayout NewsletterSynopsisItemCellLayout;

@interface NewsletterSynopsisItemCell : ItemImageCell
{
	UILabel * sourceLabel;
	UILabel * dateLabel;
	UILabel * headlineLabel;
	UILabel * synopsisTopLabel;
	UILabel * synopsisBottomLabel;
	UILabel * commentLabel;
	NewsletterSynopsisItemCellLayout _itemLayout;
}

@property(nonatomic,retain) UILabel * dateLabel;
@property(nonatomic,retain) UILabel * sourceLabel;
@property(nonatomic,retain) UILabel * headlineLabel;
@property(nonatomic,retain) UILabel * synopsisTopLabel;
@property(nonatomic,retain) UILabel * synopsisBottomLabel;
@property(nonatomic,retain) UILabel * commentLabel;

+ (UIFont*) synopsisFont;

+ (NewsletterSynopsisItemCellLayout) layoutForItem:(FeedItem*)item withCellWidth:(CGFloat)cellWidth;

+ (int) findBestFit:(NSString*)text withFont:(UIFont*)font constrainedToSize:(CGSize)constraint;

@end


