#import <UIKit/UIKit.h>

@interface ColorPickerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	UITableView * tableView;
	id delegate;
	NSArray * colorNames;
	NSInteger tag;
	NSString * colorName;
	NSString * colorTitle;
}
@property(nonatomic,retain) NSString * colorTitle;
@property(nonatomic) NSInteger tag;
@property(nonatomic,retain) NSString * colorName;
@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) UITableView * tableView;
@property(nonatomic,retain) NSArray * colorNames;
@end
