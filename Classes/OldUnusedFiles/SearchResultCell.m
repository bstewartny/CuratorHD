//
//  SearchResultCell.m
//  Untitled
//
//  Created by Robert Stewart on 2/8/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

@synthesize headlineLabel,synopsisLabel,dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
