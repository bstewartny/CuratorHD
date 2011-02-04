//
//  TextViewTableCell.h
//  Untitled
//
//  Created by Robert Stewart on 2/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextViewTableCell : UITableViewCell {
	UITextView * textView;
}
@property(nonatomic,retain) UITextView * textView;

@end
