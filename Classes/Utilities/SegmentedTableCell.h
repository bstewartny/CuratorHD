//
//  SegmentedTableCell.h
//  Untitled
//
//  Created by Robert Stewart on 2/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SegmentedTableCell : UITableViewCell {
	UISegmentedControl* segmentedControl;
}
@property(nonatomic,retain) UISegmentedControl * segmentedControl;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier buttonNames:(NSArray*)buttonNames;

@end
