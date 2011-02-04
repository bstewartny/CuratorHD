//
//  Account.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "Account.h"


@implementation Account
@synthesize name,username,password;


- (id) initWithName:(NSString*)name username:(NSString*)username password:(NSString*)password
{
	if([super init])
	{
		self.name=name;
		self.username=username;
		self.password=password;
	}
	return self;
}

- (BOOL) isValid
{
	return YES;
}

- (NSArray*) feeds
{
	return nil;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:password forKey:@"password"];	
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.name=[decoder decodeObjectForKey:@"name"];
		self.username=[decoder decodeObjectForKey:@"username"];
		self.password=[decoder decodeObjectForKey:@"password"];
	}
	return self;
}

- (void) dealloc
{
	[name release];
	[username release];
	[password release];
	[super dealloc];
}
@end
