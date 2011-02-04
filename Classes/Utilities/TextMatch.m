//
//  TextMatch.m
//  Untitled
//
//  Created by Robert Stewart on 4/6/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TextMatch.h"


@implementation TextMatch
@synthesize text,position,length,weight;


- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:text forKey:@"text"];
	[encoder encodeInt:position forKey:@"position"];
	[encoder encodeInt:length forKey:@"length"];
	[encoder encodeInt:weight forKey:@"weight"];
	 
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.text=[decoder decodeObjectForKey:@"text"];
		self.position=[decoder decodeIntForKey:@"position"];
		self.length=[decoder decodeIntForKey:@"length"];
		self.weight=[decoder decodeIntForKey:@"weight"];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	TextMatch * copy=[[[self class] allocWithZone:zone] init];
	copy.text=[self.text copy];
	 
	copy.position=self.position;
	copy.length=self.length;
	copy.weight=self.weight;
	
	return copy;
}


- (void)dealloc {
	[text release];
	[super dealloc];
}
@end
