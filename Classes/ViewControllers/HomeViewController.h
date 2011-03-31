//
//  HomeViewController.h
//  Curator
//
//  Created by Robert Stewart on 3/29/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
 
#import "AQGridView.h"
#import "AQGridViewCell.h"

@class ItemFetcher;

@interface HomeViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource, UITableViewDelegate,UITableViewDataSource>{
	ItemFetcher * sourcesFetcher;
	ItemFetcher * newslettersFetcher;
	ItemFetcher * foldersFetcher;
	id itemDelegate;
	//IBOutlet AQGridView * gridView;
	IBOutlet UITableView * tableView;
	AQGridViewCell * _draggingCell;
	
	NSUInteger _emptyCellIndex;
    AQGridView * _draggingGridView;
	
    NSUInteger _dragOriginIndex;
    CGPoint _dragOriginCellOrigin;
	int _deleteSection;
	int _deleteIndex;
	AQGridView * _deleteGridView;
}
//@property (nonatomic, retain) IBOutlet AQGridView * gridView;
@property (nonatomic, retain) IBOutlet UITableView * tableView;

@property(nonatomic,retain)ItemFetcher * sourcesFetcher;
@property(nonatomic,retain)ItemFetcher * newslettersFetcher;
@property(nonatomic,retain)ItemFetcher * foldersFetcher;
@property(nonatomic,assign) id itemDelegate;

- (CGFloat) heightForSection:(NSInteger)section width:(CGFloat)width;
- (int) numberOfItemsInSection:(NSInteger)section;

@end
