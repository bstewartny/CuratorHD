//
//  SavedSearch.h
//  Untitled
//
//  Created by Robert Stewart on 2/4/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedSearch : NSObject { //<NSCoding, NSCopying>{
	NSString * name;
	NSString * ID;
	NSString * url;
	NSMutableArray * items;
	NSDate * lastUpdated;
	NSString * username;
	NSString * password;
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * ID;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;

@property(nonatomic,retain) NSString * url;
@property(retain) NSMutableArray * items;
@property(nonatomic,retain) NSDate * lastUpdated;

- (id) initWithName:(NSString *)theName withID:(NSString*) theID withUrl:(NSString *) theUrl;

- (void) update;
- (NSString*) normalizeSynopsis:(NSString*)s;


@end
