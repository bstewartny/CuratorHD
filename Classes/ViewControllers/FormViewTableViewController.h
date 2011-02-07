
#import <UIKit/UIKit.h>

@interface FormViewTableViewController : UITableViewController <UITextFieldDelegate> {
	NSString * title;
	id delegate;
	NSArray * names;
	NSMutableArray * valueFields;
	NSInteger tag;
	 
}
@property(nonatomic,retain) NSArray * names;
@property(nonatomic,retain) NSString * title;
@property(nonatomic,assign) id delegate;
@property(nonatomic) NSInteger tag;

- (id) initWithTitle:(NSString*)title tag:(NSInteger)tag delegate:(id)delegate names:(NSArray*)names andValues:(NSArray*)values;

@end

