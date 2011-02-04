//
//  SearchArguments.h
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SearchArguments : NSObject {
	NSString * query;
	NSInteger pageSize;
	NSInteger pageNumber;
	NSDate * startDate;
	NSDate * endDate;
	NSArray * facetFields;
	NSArray * fieldNames;
}

@property(nonatomic,retain) NSString * query;
@property(nonatomic,retain) NSDate * startDate;
@property(nonatomic,retain) NSDate * endDate;
@property(nonatomic) NSInteger pageSize;
@property(nonatomic) NSInteger pageNumber;
@property(nonatomic,retain) NSArray * facetFields;
@property(nonatomic,retain) NSArray * fieldNames;


void appendParam(NSMutableString * params,NSString * name,NSString * value);

- (NSString *) urlParams;
- (id) initWithQuery:(NSString*)query;

@end
