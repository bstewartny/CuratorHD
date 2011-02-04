//
//  MetaNameValue.m
//  Untitled
//
//  Created by Robert Stewart on 4/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "MetaNameValue.h"


@implementation MetaName
@synthesize name,shortName,displayName;

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:shortName forKey:@"shortName"];
	[encoder encodeObject:displayName forKey:@"displayName"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.name=[decoder decodeObjectForKey:@"name"];
		self.shortName=[decoder decodeObjectForKey:@"shortName"];
		self.displayName=[decoder decodeObjectForKey:@"displayName"];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	MetaName * copy=[[[self class] allocWithZone:zone] init];
	copy.name=[self.name copy];
	copy.shortName=[self.shortName copy];
	copy.displayName=[self.displayName copy];
	
	return copy;
}

- (NSString*) description
{
	return name;
}

-(void) dealloc
{	
	[name release];
	[shortName release];
	[displayName release];
	[super dealloc];
}
@end


@implementation MetaValue
@synthesize value,shortValue,displayValue;

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:value forKey:@"value"];
	[encoder encodeObject:shortValue forKey:@"shortValue"];
	[encoder encodeObject:displayValue forKey:@"displayValue"];
	//[encoder encodeObject:description forKey:@"description"];
	
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.value=[decoder decodeObjectForKey:@"value"];
		self.shortValue=[decoder decodeObjectForKey:@"shortValue"];
		self.displayValue=[decoder decodeObjectForKey:@"displayValue"];
		//self.description=[decoder decodeObjectForKey:@"description"];
		
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	MetaValue * copy=[[[self class] allocWithZone:zone] init];
	copy.value=[self.value copy];
	copy.shortValue=[self.shortValue copy];
	copy.displayValue=[self.displayValue copy];
	//copy.description=[self.description copy];
	
	
	return copy;
}

- (NSString*) description
{
	return value;
}

-(void) dealloc
{	
	[value release];
	[shortValue release];
	[displayValue release];
	//[description release];
	
	[super dealloc];
}
@end

@implementation MetaNameValue
@synthesize name,value;

- (id) init
{
	if([super init])
	{
		self.name=[[MetaName alloc] init];
		self.value=[[MetaValue alloc] init];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:value forKey:@"value"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.name=[decoder decodeObjectForKey:@"name"];
		self.value=[decoder decodeObjectForKey:@"value"];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	MetaNameValue * copy=[[[self class] allocWithZone:zone] init];
	copy.name=[self.name copy];
	copy.value=[self.value copy];
	return copy;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"%@=%@",name.name,value.value];
}

-(void) dealloc
{	
	[name release];
	[value release];
	[super dealloc];
}
@end
