//
//  NewsletterAPI.m
//  Untitled
//
//  Created by Robert Stewart on 4/12/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterClient.h"
#import "UrlParams.h"
#import "TouchXML.h"
//#import "MetaNameValue.h"
#import "UrlParams.h"
#import "JSON.h"

@implementation NewsletterClient
@synthesize username,password,baseURI,ticket;//,metaNameCache;

//- (void) init
//{
//	baseURI=@"http://api.qa.infongen.cc/Services/InfoNgen.NewsletterHelper.Service/"; ///<<< NOTE: trailing / is important!!!!
//}

- (id) initWithUrl:(NSString *)baseURI  withUsername:(NSString*)username withPassword:(NSString*) password
{
	[super init];
	
	self.baseURI=baseURI;
	self.username=username;
	self.password=password;
	//self.metaNameCache=[[NSMutableDictionary alloc] init]
	
	return self;
}

- (NSData*) getData:(NSString*)relativeURI
{
	// append to base URI
	NSString * uri=[baseURI stringByAppendingString:relativeURI];
	
	NSURL * url=[NSURL URLWithString:uri];
	
	NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
	[request setHTTPMethod:@"GET"];
	
	// add auth ticket as cookie
	if(ticket)
	{
		//[request addValue:[NSString stringWithFormat:@"iiAuth=%@",ticket] forHTTPHeaderField:@"Cookie"];
		[request addValue:ticket forHTTPHeaderField:@"iiAuth"];
	}
	
	NSURLResponse * response=NULL;
	
	NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];	
	
	return data;
}

- (NSData*) postData:(NSString*)relativeURI params:(UrlParams*)params
{
	NSString * uri=[baseURI stringByAppendingString:relativeURI];
	
	NSURL * url=[NSURL URLWithString:uri];
	
	NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
	[request setHTTPMethod:@"POST"];
	
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

	// add auth ticket as cookie
	if(ticket)
	{
		//[request addValue:[NSString stringWithFormat:@"iiAuth=%@",ticket] forHTTPHeaderField:@"Cookie"];
		[request addValue:ticket forHTTPHeaderField:@"iiAuth"];
	}
	
	NSString *post = [params getQueryString];
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	[request addValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	[request setHTTPBody:postData];
	
	NSURLResponse * response=NULL;
	
	NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];	
	
	return data;
	
}

- (NSArray*) postJson:(NSString*)relativeURI  params:(UrlParams*)params
{
	NSData * data=[self postData:relativeURI params:params];
	
	if(data)
	{
		// Store incoming data into a string
		NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
		// Create a dictionary from the JSON string
		NSArray *results = [jsonString JSONValue];
	
		return results;
	}
	else 
	{
		return nil;
	}
}


- (NSArray*) getNewsletters
{
	NSMutableArray * newsletters=[[[NSMutableArray alloc] init] autorelease];
	
	NSString * uri= @"newsletters.json";
	
	NSData * data=[self getData:uri];
	
	NSString * str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	//NSLog(str);
	
	[str release];
	
	return newsletters;
	
}

- (NSArray*) getSavedSearches
{
	NSMutableArray * searches=[[[NSMutableArray alloc] init] autorelease];
	
	NSString * uri= @"savedsearches.json";

	NSData * data=[self getData:uri];
	
	
	NSString * str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	//NSLog(str);
	
	[str release];

	return searches;
		
}

- (NSString *) loginWithUsername:(NSString*)username password:(NSString*)password
{
	UrlParams * params=[[UrlParams alloc] init];
						
	[params appendParam:@"username" value:username];
	[params appendParam:@"password" value:password];
	
	// TODO: encode params...
	NSString * uri=[NSString stringWithFormat:@"login?%@",[params getQueryString]];
	
	[params release];
	
	NSData * data=[self getData:uri];
	
	//<string>
	//D9499879EBB80E8605DCD93AD49BBE9FB44D985CAE76E34DAC889D6446DE85D2BA1FF5205399EF493B06A1FAD30C963B11B510FE46917451B5A378CDB90411160168239833560921B76BB2668FFA9122A6EB284CE6A977AF85D75DFE0D0C1ABB
	//</string>
	
	ticket=nil;
	
	CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
	
	ticket=[[[xmlParser nodesForXPath:@"//." error:nil] objectAtIndex:1] stringValue];
	
	return ticket;
}
/*
- (void) ResolveMetaNames:(NSArray*)metadata useRemoteIfNotInCache:(BOOL)useRemote
{
	NSMutableArray * nonCached=[[NSMutableArray alloc] init];
	for(MetaNameValue * tag in metadata)
	{
		if(tag.value.displayValue==nil)
		{
			MetaNameValue * metaNameValue=[cache objectForKey:[tag description]];
			if(metaNameValue!=nil)
			{
				tag.value=metaNameValue.value;
			}
			else
			{
				[nonCached addObject:tag];
			}
		}
	}
	
	if([nonCached count]>0)
	{
		if(useRemote)
		{
			[self ResolveMetaNamesRemote:nonCached];
		}
	}
	
	[nonCached release];
}

- (void) ResolveMetaNamesRemote:(NSArray*)metadata
{
	// dedup metadata so only send unique items to server
	NSMutableDictionary * uniques=[[NSMutableDictionary alloc] init];
	NSMutableArray * dups=[[NSMutableArray alloc] init];
	UrlParams * params=[[UrlParams alloc] init];
	
	// form request
	for(MetaNameValue * tag in metadata)
	{
		if([uniques objectForKey:[tag description]]==nil)
		{
			// append to request
			[params appendParam:tag.name.name value:tag.value.value];
			[uniques setObject:tag forKey:[tag description]];
		}
		else 
		{
			// item is dup, append to dups list
			[dups addObject:tag];
		}
	}
	
	// send request
	NSArray * results=[self postJson:@"resolve?format=json" params:params];
	
	// parse results
	if(results)
	{
		for(NSDictionary * dict in results)
		{
			// get tag name...
			NSString * key=[dict objectForKey:@"Key"];
			
			NSArray * values=[dict objectForKey:@"Value"];
			
			if(values && [values count]>0)
			{
				for(NSDictionary * valueDict in values)
				{
					NSString * description=[valueDict objectForKey:@"Description"];
					NSString * displayValue=[valueDict objectForKey:@"DisplayValue"];
					NSString * shortValue=[valueDict objectForKey:@"ShortValue"];
					NSString * value=[valueDict objectForKey:@"Value"];
					
					MetaNameValue * metaNameValue=[[MetaNameValue alloc] init];
					
					metaNameValue.name.name=key;
					metaNameValue.name.displayName=key;
					metaNameValue.name.shortName=key;
					
					metaNameValue.value.value=value;
					metaNameValue.value.description=description;
					metaNameValue.value.shortValue=value;
					metaNameValue.value.displayValue=displayValue;
					
					MetaNameValue * unique=[uniques objectForKey:[metaNameValue description]];
					
					if (unique!=nil) 
					{
						unique.value=metaNameValue.value;
					}
					
					[cache setObject:metaNameValue forKey:[metaNameValue description]];
					
					[metaNameValue release];
				}
			}
		}
	}
	
	// if we have dups get dups from cache
	if ([dups count]>0) 
	{
		[self ResolveMetaNames:dups useRemoteIfNotInCache:NO];
	}
	
	[params release];
	[uniques release];
	[dups release];
}
*/


- (void) dealloc
{
	[ticket release];
	[username release];
	[password release];
	[baseURI release];
	//[metaNameCache release];
	
	[super dealloc];
}

@end