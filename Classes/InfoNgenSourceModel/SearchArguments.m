//
//  SearchArguments.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchArguments.h"


@implementation SearchArguments
@synthesize query,pageNumber,pageSize,startDate,endDate,facetFields,fieldNames;

- (id) initWithQuery:(NSString*)query
{
	[super init];
	
	self.query=query;
	
	self.startDate=[NSDate dateWithTimeIntervalSinceNow:-(60*60*24*7)];// default 7 days ago
	self.endDate=[NSDate dateWithTimeIntervalSinceNow:60*60*24];// go one day in future to make sure we get all new stuff.
	self.pageNumber=1;
	self.pageSize=50;
	
	return self;
}

- (void)dealloc {
	[query release];
	[startDate release];
	[endDate release];
	[facetFields release];
	[fieldNames release];
	[super dealloc];
}

void appendParam(NSMutableString * params,NSString * name,NSString * value)
{
	if(value!=nil && [value length]>0)
	{
		if([params length]>0)
		{
			[params appendString:@"&"];
		}
		
		NSString *encodedValue = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
		//NSString *encodedValue = (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)value, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
		
		//[params appendFormat:@"%@=%@",name,[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[params appendFormat:@"%@=%@",name,encodedValue]; //[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[encodedValue release];
	}
}



- (NSString *) urlParams
{
	NSMutableString * params=[NSMutableString string];
	
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	// This is required, Cocoa will try to use the current locale otherwise 
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:enUS];
	[enUS release];
	[formatter setDateFormat:@"yyyy-MM-dd"]; 
	
	
	
	// query
	appendParam(params,@"q",query);
							  
	// date range
	// TODO: get real dates
	appendParam(params,@"sd",[formatter stringFromDate:startDate]);   
	appendParam(params,@"ed",[formatter stringFromDate:endDate]);
	
	// page number
	appendParam(params,@"pn",[NSString stringWithFormat:@"%d",pageNumber]);
	appendParam(params,@"ps",[NSString stringWithFormat:@"%d",pageSize]);

	// sorting
	appendParam(params,@"sort",@"date desc");
	
	// clustering
	appendParam(params,@"cluster",@"true");
	appendParam(params,@"cluster.sort",@"EARLIEST");
	
	// facet fields
	
	if(facetFields)
	{
		for(NSString * facetField in facetFields)
		{
			appendParam(params, @"facet.field", facetField);
		}
	}
	/*
	appendParam(params,@"facet.field",@"primarycompany");
	appendParam(params,@"facet.field",@"topic");
	//appendParam(params,@"facet.field",@"keyword");
	appendParam(params,@"facet.field",@"industry");
	appendParam(params,@"facet.field",@"region");
	//appendParam(params,@"facet.field",@"country");
	*/
	
	// fields to return
	
	if(fieldNames)
	{
		for(NSString * fieldName in fieldNames)
		{
			appendParam(params, @"fl", fieldName);
		}
	}
	else 
	{
		appendParam(params,@"fl",@"subject");
		appendParam(params,@"fl",@"date");
		appendParam(params,@"fl",@"synopsis");
		appendParam(params,@"fl",@"uri");
	
		// clusterid is required for clustering to work...
		appendParam(params, @"fl", @"clusterid");
	
	}
	
	appendParam(params, @"fl.maxsize", @"10000");
	
	
	[formatter release];
	return params;
	
}

@end
