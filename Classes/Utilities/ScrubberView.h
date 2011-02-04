//
//  ScrubberView.h
//  Untitled
//
//  Created by Robert Stewart on 7/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScrubberView : UIView {
	NSArray * items;
	int selectedItemIndex;
	id delegate;
}
@property(nonatomic,retain) NSArray * items;
@property(nonatomic) int selectedItemIndex;
@property(nonatomic,assign) id delegate;


@end
