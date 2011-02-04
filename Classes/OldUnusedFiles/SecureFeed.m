//
//  SecureFeed.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "SecureFeed.h"
#import "FeedAccount.h"

@implementation SecureFeed
@synthesize account;

- (id) initWithAccount:(FeedAccount*)account
{
	if([super init])
	{
		self.account=account;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:account forKey:@"account"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super initWithCoder:decoder])
	{
		self.account=[decoder decodeObjectForKey:@"account"];
	}
	return self;
}
-(id)copyWithZone:(NSZone*)zone
{
	SecureFeed * copy=[super copyWithZone:zone];
	copy.account=[self.account copy];
	
	return copy;
}
- (void) dealloc
{
	[account release];
	[super dealloc];
}
@end
