//
//  SearchResults.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchResults.h"
#import "FacetField.h"
#import "FacetValue.h"

@implementation SearchResults
@synthesize results,facets;
 
- (FacetField*) getFacetWithFieldName:(NSString*)fieldName
{
	if(facets)
	{
		for (FacetField * fieldFacet in facets)
		{
			if([fieldFacet.name isEqualToString:fieldName])
			{
				return fieldFacet;
			}
		}
	}
	return nil;
}

- (void)dealloc {
	[results release];
	[facets release];
	[super dealloc];
}
@end
