//
//  InstapaperClient.h
//  Untitled
//
//  Created by Robert Stewart on 8/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InstapaperClient : NSObject {
	NSString * username;
	NSString * password; 
}
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;

- (id) initWithUsername:(NSString*)username password:(NSString*)password;

- (BOOL) post:(NSString*)url title:(NSString*)title selection:(NSString*)selection;

@end
