#import <UIKit/UIKit.h>
@class Newsletter;

@interface NewsletterFormattingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView * tableView;
	id delegate;
	Newsletter * newsletter;
}
@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,retain) Newsletter * newsletter;
@end
