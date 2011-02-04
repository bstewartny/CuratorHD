//
//  FacetField.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacetField.h"
#import "MetaNameValue.h"

@implementation FacetField
@synthesize values;

- (void)dealloc {
	[values release];
	[super dealloc];
}
@end
