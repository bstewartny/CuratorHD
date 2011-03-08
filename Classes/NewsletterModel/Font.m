//
//  Font.m
//  Curator
//
//  Created by Robert Stewart on 3/8/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import "Font.h"

@implementation FontValue
@synthesize name,value;

+ (FontValue*) withName:(NSString*)name andValue:(NSString*)value
{
	FontValue * v=[[FontValue alloc] init];
	v.name=name;
	v.value=value;
	return [v autorelease];
}
- (void) dealloc
{
	[name release];
	[value release];
	[super dealloc];
}

@end


@implementation Font
@synthesize family,style,weight,size,color;

- (id) initWithFamily:(NSString*)family weight:(NSString*)weight style:(NSString*)style size:(NSString*)size color:(NSString*)color
{
	if(self=[super init])
	{
		self.family=family;
		self.weight=weight;
		self.style=style;
		self.size=size;
		self.color=color;
	}
	return self;
}
- (NSString*) cssStyle
{
	NSString * css= [NSString stringWithFormat:@"font-family:%@; font-style:%@; font-weight:%@; font-size:%@; color:%@; ",family,style,weight,size,color];
	NSLog(css);
	return css;
}

- (id) copyWithZone: (NSZone *) zone
{
	Font * copy=[[Font allocWithZone:zone] init];
	copy.family=[[family copy] autorelease];
	copy.style=[[style copy] autorelease];
	copy.weight=[[weight copy] autorelease];	
	copy.size=[[size copy] autorelease];
	copy.color=[[color copy] autorelease];
	
	return copy;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		self.family=[decoder decodeObjectForKey:@"family"];
		self.style=[decoder decodeObjectForKey:@"style"];
		self.weight=[decoder decodeObjectForKey:@"weight"];
		self.size=[decoder decodeObjectForKey:@"size"];
		self.color=[decoder decodeObjectForKey:@"color"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:family forKey:@"family"];
	[encoder encodeObject:style forKey:@"style"];
	[encoder encodeObject:weight forKey:@"weight"];
	[encoder encodeObject:size forKey:@"size"];
	[encoder encodeObject:color forKey:@"color"];
}

- (void) dealloc
{
	[family release];
	[style release];
	[weight release];
	[size release];
	[color release];
	
	[super dealloc];
	
}
@end
