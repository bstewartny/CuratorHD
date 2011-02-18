#import <UIKit/UIKit.h>
#import "UpdatableFeedViewController.h"

@class ItemFetcher;

@interface FeedsViewController : UpdatableFeedViewController {
	IBOutlet UITableView * tableView;
	ItemFetcher * fetcher;
	id itemDelegate;
	BOOL editable;
	NSArray * items;
}
@property(nonatomic,retain) NSArray * items;
@property(nonatomic,retain) ItemFetcher * fetcher;
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,assign) id itemDelegate;
@property(nonatomic) BOOL editable;

- (IBAction) addFeed:(id)sender;
- (IBAction) toggleEdit:(id)sender;

@end
