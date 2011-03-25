//
//  AddItemsViewController.h
//  Curator
//
//  Created by Robert Stewart on 1/24/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@class ItemFetcher;
 
@interface AddItemsViewController : UIViewController<MBProgressHUDDelegate> {
		IBOutlet UITableView * tableView;
		ItemFetcher * newslettersFetcher;
		ItemFetcher * foldersFetcher;
		id delegate;
		NSIndexPath * selectedIndexPath;
	MBProgressHUD * HUD;
	}
	
	@property(nonatomic,retain)IBOutlet UITableView * tableView;
	
	@property(nonatomic,retain)ItemFetcher * newslettersFetcher;
	@property(nonatomic,retain)ItemFetcher * foldersFetcher;
	@property(nonatomic,assign) id delegate;


@end
