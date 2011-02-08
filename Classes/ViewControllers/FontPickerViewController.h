#import <UIKit/UIKit.h>

@interface FontPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	UITableView * tableView;
	id delegate;
	NSArray * fonts;
	NSArray * fontNames;
	NSArray * fontSizes;
	NSArray * fontSizeNames;
	NSArray * fontStyleNames;
	NSInteger tag;
	NSString * fontName;
	NSString * fontSize;
	NSString * fontTitle;
	NSString * fontStyle;
	NSArray * fontStyles;
	NSArray * colorNames;
	NSString * colorName;
	
}
@property(nonatomic,retain) NSString * fontTitle;
@property(nonatomic) NSInteger tag;
@property(nonatomic,retain) NSString * fontName;
@property(nonatomic,retain) NSString * fontSize;
@property(nonatomic,retain) NSString * fontStyle;

@property(nonatomic,retain) NSArray * colorNames;
@property(nonatomic,retain) NSString * colorName;

@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) UITableView * tableView;
@property(nonatomic,retain) NSArray * fonts;
@property(nonatomic,retain) NSArray * fontNames;
@property(nonatomic,retain) NSArray * fontSizes;
@property(nonatomic,retain) NSArray * fontSizeNames;

@end
