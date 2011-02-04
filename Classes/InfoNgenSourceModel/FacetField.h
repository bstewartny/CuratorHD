//
//  FacetField.h
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaNameValue.h"

@interface FacetField : MetaName {
	NSArray * values;
}
@property(nonatomic,retain) NSArray * values;

@end
