//
//  TextMatch.h
//  Untitled
//
//  Created by Robert Stewart on 4/6/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextMatch : NSObject<NSCoding, NSCopying> {
	NSString * text;
	NSInteger position;
	NSInteger length;
	NSInteger weight;
}
@property(nonatomic,retain) NSString * text;
@property(nonatomic) NSInteger position;
@property(nonatomic) NSInteger length;
@property(nonatomic) NSInteger weight;


@end
