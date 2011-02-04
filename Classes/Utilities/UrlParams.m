//
//  UrlParams.m
//  Untitled
//
//  Created by Robert Stewart on 4/12/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "UrlParams.h"


@implementation UrlParams

- (id) init
{
	if([super init])
	{
		params=[[NSMutableString alloc] init];
	}
	return self;
}

void appendParam2(NSMutableString * params,NSString * name,NSString * value)
{
	NSLog(@"appendParam2:%@=%@",name,value);
	if(value!=nil && [value length]>0)
	{
		if([params length]>0)
		{
			[params appendString:@"&"];
		}
		
		NSString *encodedValue = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
		[params appendFormat:@"%@=%@",name,encodedValue]; //[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[encodedValue release];
	}
}

- (void) appendParam:(NSString*)name value:(NSString*)value
{
	appendParam2(params, name, value);
}

- (NSString *) getQueryString
{
	return params;
}

- (void) dealloc
{
	[params release];
	[super dealloc];
}

@end
