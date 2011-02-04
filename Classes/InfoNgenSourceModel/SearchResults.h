//
//  SearchResults.h
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FacetField;

@interface SearchResults : NSObject {
	NSArray * results;
	NSArray * facets;
}
@property(nonatomic,retain) NSArray * results;
@property(nonatomic,retain) NSArray * facets;


- (FacetField*) getFacetWithFieldName:(NSString*)fieldName;

@end
