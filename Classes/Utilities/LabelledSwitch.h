//
//  LabelledSwitch.h
//  Untitled
//
//  Created by Robert Stewart on 6/15/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UICustomSwitch;

@interface LabelledSwitch : UIControl {
	UICustomSwitch * centerSwitch;
	UILabel * leftLabel;
	UILabel * rightLabel;
	BOOL on;
}
@property(nonatomic,retain) UICustomSwitch * centerSwitch;
@property(nonatomic,retain) UILabel * leftLabel;
@property(nonatomic,retain) UILabel * rightLabel;
@property(nonatomic) BOOL on;

- (id) initWithFrame:(CGRect) frame leftLabelText:(NSString*)leftLabelText rightLabelText:(NSString*)rightLabelText;

@end
