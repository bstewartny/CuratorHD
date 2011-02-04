//
//  SavedSearch.h
//  Untitled
//
//  Created by Robert Stewart on 2/4/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@interface RSSSavedSearch : Feed {  
	NSString * ID;
	NSString * url;
	NSString * username;
	NSString * password;
}
@property(nonatomic,retain) NSString * ID;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;
@property(nonatomic,retain) NSString * url;

- (id) initWithName:(NSString *)theName withID:(NSString*) theID withUrl:(NSString *) theUrl;

- (NSString*) normalizeSynopsis:(NSString*)s;


@end
