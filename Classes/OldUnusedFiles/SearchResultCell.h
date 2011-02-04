//
//  SearchResultCell.h
//  Untitled
//
//  Created by Robert Stewart on 2/8/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabelEx.h"

@interface SearchResultCell : UITableViewCell {
	IBOutlet UILabelEx * headlineLabel;
	IBOutlet UILabelEx * dateLabel;
	IBOutlet UILabelEx * synopsisLabel;
}
@property(nonatomic,retain) UILabelEx * headlineLabel;
@property(nonatomic,retain) UILabelEx * dateLabel;
@property(nonatomic,retain) UILabelEx * synopsisLabel;


@end
