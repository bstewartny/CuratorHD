//
//  FacetValue.h
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaNameValue.h"
@class SearchArguments;

@interface FacetValue : MetaValue {
	NSInteger  count;
	SearchArguments * args;
}
@property(nonatomic) NSInteger count;
@property(nonatomic,retain) SearchArguments * args;

@end
