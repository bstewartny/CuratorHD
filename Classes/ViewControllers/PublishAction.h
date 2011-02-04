//
//  PublishAction.h
//  Untitled
//
//  Created by Robert Stewart on 6/21/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PublishAction : NSObject <NSCoding> {

	BOOL isFavorite;
	BOOL isSource;
}
@property(nonatomic) BOOL isFavorite;
@property(nonatomic) BOOL isSource;

- (void)action:(id)sender;
- (void)longAction:(id)sender;
- (void)longPress:(UILongPressGestureRecognizer*)recognizer;
- (void)actionComplete;
- (UIImage*)image;
- (NSString*)title;
- (int)count;

@end
