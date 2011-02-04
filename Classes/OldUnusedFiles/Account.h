//
//  Account.h
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject <NSCoding>{
	NSString * name;
	NSString * username;
	NSString * password;
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;

- (id) initWithName:(NSString*)name username:(NSString*)username password:(NSString*)password;

- (BOOL) isValid;

- (NSArray*) feeds;

@end
