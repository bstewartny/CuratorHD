//
//  Search.h
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchArguments.h"
#import "SearchResults.h"

@interface Search : NSObject {
	SearchArguments	* args;
	SearchResults * results;
	BOOL isRefreshable;
}
@property(nonatomic,retain) SearchArguments	* args;
@property(nonatomic,retain) SearchResults * results;
@property(nonatomic) BOOL isRefreshable;

- (id) initWithQuery:(NSString*)query;

- (void) update;

@end
