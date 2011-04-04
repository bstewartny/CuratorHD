#import <UIKit/UIKit.h>

@class ItemFetcher;
@interface FoldersViewController : UIViewController {
	IBOutlet UITableView * tableView;
	ItemFetcher * fetcher;
	id delegate;
	int selectedRow;
}
@property(nonatomic) int selectedRow;

@property(nonatomic,retain)IBOutlet UITableView * tableView;
@property(nonatomic,retain)ItemFetcher * fetcher;
@property(nonatomic,assign) id delegate;

@end
