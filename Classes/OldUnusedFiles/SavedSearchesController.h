//
//   SavedSearchesController.h
//  Untitled
//
//  Created by Robert Stewart on 2/3/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SavedSearchesController : UITableViewController< UITableViewDelegate,UITableViewDataSource> {
	NSArray * controllers;
}

@property(nonatomic,retain) NSArray * controllers;

@end
