//
//  OfflineCache.h
//  Untitled
//
//  Created by Robert Stewart on 4/28/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OfflineCache : NSObject {
	NSMutableDictionary * cache;
}
@property(nonatomic,retain) NSMutableDictionary * cache;

- (NSString*) getHTML:(NSString*)url;

- (void) cacheHTML:(NSString*)url;

@end
