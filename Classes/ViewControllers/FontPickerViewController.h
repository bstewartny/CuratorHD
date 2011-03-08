#import <UIKit/UIKit.h>
@class Font;
@interface FontPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	UITableView * tableView;
	id delegate;
	
	Font * font;
	NSString * sectionName;
	NSArray * families;
	NSArray * styles; 
	NSArray * sizes;
	NSArray * weights;
	NSArray * colors;
}
@property(nonatomic,retain) Font * font;
@property(nonatomic,assign) NSString * sectionName;
@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) UITableView * tableView;
@property(nonatomic,retain) NSArray * families;
@property(nonatomic,retain) NSArray * styles; 
@property(nonatomic,retain) NSArray * sizes;
@property(nonatomic,retain) NSArray * weights;
@property(nonatomic,retain) NSArray * colors;

- (id) initWithFont:(Font*)font;

@end
