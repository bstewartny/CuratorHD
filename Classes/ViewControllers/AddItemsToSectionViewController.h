#import <UIKit/UIKit.h>

@class Newsletter;
@interface AddItemsToSectionViewController : UIViewController {
	IBOutlet UITableView * tableView;
	Newsletter * newsletter;
}

@property(nonatomic,retain)IBOutlet UITableView * tableView;

@property(nonatomic,retain)Newsletter * newsletter;


@end
