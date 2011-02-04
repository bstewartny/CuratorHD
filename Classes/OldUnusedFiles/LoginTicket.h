//
//  LoginTicket.h
//  Untitled
//
//  Created by Robert Stewart on 2/16/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoginTicket : NSObject {
	NSString * ticket;
	 
}
@property(nonatomic,retain) NSString * ticket;
 
- (NSString *)urlEncodeValue:(NSString *)str;

- (id) initWithUsername:(NSString *)username password:(NSString *)password useCachedCookie:(BOOL)useCachedCookie;

- (NSString*) getAuthCookie;

@end
