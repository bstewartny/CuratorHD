#import <UIKit/UIKit.h>
@class ItemFetcher;
@interface RootFeedsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView * tableView;
	ItemFetcher * sourcesFetcher;
	ItemFetcher * newslettersFetcher;
	ItemFetcher * foldersFetcher;
	id itemDelegate;
}

@property(nonatomic,retain)IBOutlet UITableView * tableView;
@property(nonatomic,retain)ItemFetcher * sourcesFetcher;
@property(nonatomic,retain)ItemFetcher * newslettersFetcher;
@property(nonatomic,retain)ItemFetcher * foldersFetcher;
@property(nonatomic,assign) id itemDelegate;
@end
