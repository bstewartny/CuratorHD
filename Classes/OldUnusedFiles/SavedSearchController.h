//
//  SavedSearchController.h
//  Untitled
//
//  Created by Robert Stewart on 2/3/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedSearch.h"

@interface SavedSearchController : UITableViewController<UITableViewDelegate,UITableViewDataSource> {
	SavedSearch * savedSearch;
}
@property(nonatomic,retain) SavedSearch * savedSearch;

@end
