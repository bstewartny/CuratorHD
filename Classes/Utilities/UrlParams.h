//
//  UrlParams.h
//  Untitled
//
//  Created by Robert Stewart on 4/12/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UrlParams : NSObject {
	NSMutableString * params;
}


- (void) appendParam:(NSString *)name value:(NSString*)value;

- (NSString*) getQueryString;


@end
