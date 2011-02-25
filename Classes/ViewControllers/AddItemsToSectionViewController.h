#import <UIKit/UIKit.h>

@class Newsletter;
@interface AddItemsToSectionViewController : UIViewController {
	IBOutlet UITableView * tableView;
	Newsletter * newsletter;
	id delegate;
}

@property(nonatomic,retain)IBOutlet UITableView * tableView;

@property(nonatomic,retain)Newsletter * newsletter;
@property(nonatomic,assign) id delegate;


@end
