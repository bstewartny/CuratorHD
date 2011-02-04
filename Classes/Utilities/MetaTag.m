//
//  MetaTag.m
//  Untitled
//
//  Created by Robert Stewart on 4/5/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "MetaTag.h"


@implementation MetaTag
@synthesize name,value,ticker,fieldName,fieldValue,matches,relevance;


- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:value forKey:@"value"];
	[encoder encodeObject:ticker forKey:@"ticker"];
	[encoder encodeObject:fieldName forKey:@"fieldName"];	
	[encoder encodeObject:fieldValue forKey:@"fieldValue"];
	[encoder encodeObject:matches	forKey:@"matches"];
	[encoder encodeInt:relevance forKey:@"relevance"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.name=[decoder decodeObjectForKey:@"name"];
		self.value=[decoder decodeObjectForKey:@"value"];
		self.ticker=[decoder decodeObjectForKey:@"ticker"];
		self.fieldName=[decoder decodeObjectForKey:@"fieldName"];
		self.fieldValue=[decoder decodeObjectForKey:@"fieldValue"];
		self.matches=[decoder decodeObjectForKey:@"matches"];
		self.relevance=[decoder decodeIntForKey:@"relevance"];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	MetaTag * copy=[[[self class] allocWithZone:zone] init];
	copy.name=[self.name copy];
	copy.value=[self.value copy];
	copy.ticker=[self.ticker copy];
	copy.fieldName=[self.fieldName copy];
	copy.fieldValue=[self.fieldValue copy];
	copy.matches=[self.matches copy];
	copy.relevance=self.relevance;
	
	return copy;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"%@=%@",name,value];
}


- (void)dealloc {
	[name release];
	[value release];
	[ticker release];
	[fieldName release];
	[fieldValue release];
	[matches release];
	[super dealloc];
}
@end
