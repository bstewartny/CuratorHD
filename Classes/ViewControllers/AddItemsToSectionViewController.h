#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class Newsletter;
@interface AddItemsToSectionViewController : UIViewController<MBProgressHUDDelegate> {
	IBOutlet UITableView * tableView;
	Newsletter * newsletter;
	id delegate;
	NSIndexPath * selectedIndexPath;
	MBProgressHUD * HUD;
}

@property(nonatomic,retain)IBOutlet UITableView * tableView;

@property(nonatomic,retain)Newsletter * newsletter;
@property(nonatomic,assign) id delegate;


@end
