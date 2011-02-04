//
//  FacetValue.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacetValue.h"
#import "MetaNameValue.h"
#import "SearchArguments.h"

@implementation FacetValue
@synthesize count,args;

- (void)dealloc {
	[args release];
	[super dealloc];
}
@end
