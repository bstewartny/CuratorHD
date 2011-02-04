//
//  MetaTag.h
//  Untitled
//
//  Created by Robert Stewart on 4/5/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MetaTag : NSObject <NSCoding, NSCopying>{
	NSString * value;
	NSString * name;
	NSString * ticker;
	NSString * fieldName;
	NSString * fieldValue;
	NSInteger relevance;
	NSArray * matches;
}
@property(nonatomic,retain) NSString * value;
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * ticker;
@property(nonatomic,retain) NSString * fieldName;
@property(nonatomic,retain) NSString * fieldValue;
@property(nonatomic) NSInteger relevance;
@property(nonatomic,retain) NSArray * matches;
@end
