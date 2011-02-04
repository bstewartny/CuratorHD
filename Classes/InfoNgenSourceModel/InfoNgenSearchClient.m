//
//  SearchClient.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InfoNgenSearchClient.h"
#import "TouchXML.h"
#import "SearchResults.h"
#import "FeedItem.h"
#import "FacetField.h"
#import "FacetValue.h"
#import "Base64.h"
#import "InfoNgenLoginTicket.h"
//#import "InfoNgenRSSSavedSearch.h"
#import "MetaTag.h"
#import "TextMatch.h"
#import "MetaNameValue.h"
#import "FeedAccount.h"
#import "Feed.h"
#import "UrlUtils.h"

@implementation InfoNgenSearchClient
@synthesize serverUrl,account;

- (id) initWithServer:(NSString *)url  account:(FeedAccount*)account
{
	[super init];
	
	self.serverUrl=url;
	self.account=account;
	
	return self;
}

- (NSData *) loadDataFromURLForcingBasicAuth:(NSURL *)url  {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:90.0];
	// use FF user agent so server is ok with us...
	[request setValue: @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16" forHTTPHeaderField: @"User-Agent"];
	if (self.account.username!=nil && self.account.password!=nil && [self.account.username length]>0)
	{
		NSString *authString = [Base64 encode:[[NSString stringWithFormat:@"%@:%@",self.account.username,self.account.password] dataUsingEncoding:NSUTF8StringEncoding]]; 
		[request setValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"];
	}
	return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	return str;
	//return str;
	//NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	//NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
	
	
	//return [result autorelease];
	
	//NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
	//return result;
	
	//return [result autorelease];
}
/*
- (NSMutableArray*) getTags:(NSString*)text
{
	NSMutableArray * tags=[[NSMutableArray alloc] init];
	
	NSString * license=@"LIC/1.0/D79488B7-A51F-4e65-86A6-5908F0A852F2";
	
	NSURL * url=[NSURL URLWithString:@"https://opentagging.infongen.com/InfoNgen.OpenTagging.Service/RevealSemantics2"];
	
	NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
	[request setHTTPMethod:@"POST"];
	
	[request addValue:license forHTTPHeaderField:@"InfoNgen-LicenseId"];
	[request addValue:@"XML/InfoNgen/Semantics/2.0" forHTTPHeaderField:@"InfoNgen-OutputFormat"];
	[request addValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request addValue:@"ReportCompanySymbols" forHTTPHeaderField:@"InfoNgen-Options"];
	[request addValue:@"Company;Topic;Industry;Region;Country" forHTTPHeaderField:@"InfoNgen-EntityTypes"];
	[request addValue:@"Sample Program" forHTTPHeaderField:@"InfoNgen-ClientApplication"];
	[request addValue:@"1.0.0.0" forHTTPHeaderField:@"InfoNgen-ClientApplicationVersion"];
	
	NSString *post = text;
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	[request addValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	[request setHTTPBody:postData];
	
	NSURLResponse * response=NULL;
	
	NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];	
	
	if(data)
	{
		NSDictionary *nsdict = [NSDictionary dictionaryWithObjectsAndKeys:
								@"http://schemas.infongen.com/Service/OpenTagging/RevealSemanticsResult/2.0",
								@"ii", 
								nil];
		
		CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
		
		NSArray * entities=[xmlParser nodesForXPath:@"ii:RevealSemanticsResult/ii:Metadata/ii:Entities/ii:Entity" namespaceMappings:nsdict error:nil];
		
		if(entities)
		{
			for(CXMLElement * entity in entities)
			{
				NSString * category=[[entity attributeForName:@"Category"] stringValue];
				NSString * value=[[entity attributeForName:@"Id"] stringValue];
				NSString * name=[[entity attributeForName:@"Name"] stringValue];
				NSString * rel=[[entity attributeForName:@"Relevance"] stringValue];
				
				MetaTag * tag=[[MetaTag alloc] init];
				
				tag.fieldName=category;
				tag.fieldValue=value;
				tag.value=name;
				tag.name=category;
				
				if(rel)
				{
					tag.relevance=[rel intValue];
				}
				
				NSArray * symbolNodes=[entity nodesForXPath:@"ii:Symbol" namespaceMappings:nsdict error:nil];
				
				if(symbolNodes && [symbolNodes count]>0)
				{
					CXMLElement * symbolNode=[symbolNodes objectAtIndex:0];
					
					tag.ticker=[[symbolNode attributeForName:@"Value"] stringValue];
				}
				
				NSArray * textMatches=[entity nodesForXPath:@"ii:TextMatches/ii:TextMatch" namespaceMappings:nsdict error:nil];
				
				if(textMatches && [textMatches count]>0)
				{
					NSMutableArray * tmp=[[NSMutableArray alloc] init];
					for(CXMLElement * match in textMatches)
					{
						TextMatch * textMatch=[[TextMatch alloc] init];
						
						textMatch.text=[[match attributeForName:@"Text"] stringValue];
						textMatch.position=[[[match attributeForName:@"Position"] stringValue] intValue];
						textMatch.length=[[[match attributeForName:@"Length"] stringValue] intValue];
						textMatch.weight=[[[match attributeForName:@"Weight"] stringValue] intValue];
						
						[tmp addObject:textMatch];
					}
					tag.matches=tmp;
				}
				
				[tags addObject:tag];
				
			}
		}
	}
	
	return tags;
}
*/

- (NSMutableArray*) getSavedSearchesForAccount:(Account*)account imageCache:(NSMutableDictionary*)imageCache
{
	@try 
	{
		return [self getSavedSearchesForAccountImpl:account imageCache:imageCache];
	}
	@catch (NSException * e) {
		NSLog(@"Exception in getSavedSearchesForUser: %@",[e description]);
		return nil;
	}
	@finally {
		
	}
}

- (NSMutableArray*) getSavedSearchesForAccountImpl:(FeedAccount*)account imageCache:(NSMutableDictionary*)imageCache
{
	
	
	InfoNgenLoginTicket * ticket=[[InfoNgenLoginTicket alloc] initWithAccount:account useCachedCookie:YES];
	
	
	if([ticket.ticket length]==0)
	{
		NSLog(@"No ticket found, authentication probably failed.");
		[ticket release];
		return nil;
	}
	NSMutableArray * searches=[[NSMutableArray alloc] init];
	
	
	NSURL * url=[NSURL URLWithString:@"http://www.infongen.com/DynamicDataProcessor.aspx?page=ManageSearches"];
	
	// attempt to avoid leaking NSData from response?
	[[NSURLCache sharedURLCache] removeAllCachedResponses];

	NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
	[request setHTTPMethod:@"POST"];
	
	[request addValue:@"ExecuteCommand (*)" forHTTPHeaderField:@"mAction"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request addValue:[NSString stringWithFormat:@"iiAuth=%@",ticket.ticket] forHTTPHeaderField:@"Cookie"];
	
	NSString *post = @"ctltype=InfoNgen.TouchPoint.Modules.Common.Search.AllSavedSearches&mname=Common.AllSavedSearches&prntid=_cc_ctl18n_c&xml=true";
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	[request addValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	[request setHTTPBody:postData];
		
	NSHTTPURLResponse * response=NULL;
	
	NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];	
	
	
	NSInteger statusCode=[response statusCode];
	
	NSLog(@"Got status %d from saved search request...",statusCode);
	
	
	if(data)
	{
		CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
		
		NSArray * searchItems = [xmlParser nodesForXPath:@"//SearchItem" error:nil];
		
		// Loop through the resultNodes to access each items actual data
		for (CXMLElement *searchItem in searchItems) {
		
			// <SearchItem index="4"><PageId>Feeds</PageId><ID>241052525</ID><Title>Microsoft</Title><AlrId>0</AlrId></SearchItem>
			//NSString * ID=[[[searchItem elementsForName:@"ID"] objectAtIndex:0] stringValue];
			NSString * Title=[self urlEncodeValue:[[[searchItem elementsForName:@"Title"] objectAtIndex:0] stringValue]];
			
			NSString* escapedTitle = [Title   
									stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
			
			
			TempFeed * savedSearch=[[TempFeed alloc] init];
			
			savedSearch.name=Title;
			savedSearch.url=[NSString stringWithFormat:@"http://rss.infongen.com/search.rss?name=%@",escapedTitle];
			savedSearch.feedCategory=@"_top";
			
			savedSearch.image=[UIImage imageNamed:@"InfoNgen-Logo-White-Wide.png"];
			
			//savedSearch.image=[UrlUtils faviconFromUrl:savedSearch.url imageCache:imageCache];
			
			[searches addObject:savedSearch];
			
			[savedSearch release];
		}
	}
	
	[ticket release];
	
	return [searches autorelease];	
}

- (SearchResults *) search:(SearchArguments *) args
{
	SearchResults * results=[[SearchResults alloc] init];
	
	NSString * params=[args urlParams];
	
	NSString * urlString=[NSString stringWithFormat:@"%@/search?%@",self.serverUrl,params];
	
	NSURL *url = [NSURL URLWithString: urlString];
	
	NSData * data=[self loadDataFromURLForcingBasicAuth:url];
	
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	// This is required, Cocoa will try to use the current locale otherwise 
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:enUS];
	[enUS release];
	[formatter setDateFormat:@"yyyyMMddHHmmss"]; 
	
	NSMutableArray * resultItems=[[NSMutableArray alloc] init];
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    NSArray * resultNodes = [xmlParser nodesForXPath:@"/SearchResults/Results/map/fields" error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *fields in resultNodes) {
		
        FeedItem * result=[[FeedItem alloc] init];
		
        int counter;
		
        for(counter = 0; counter < [fields childCount]; counter++) {
			
			CXMLElement * f=(CXMLElement*)[fields childAtIndex:counter];
			
			// get field name
			NSString * name=[[f attributeForName:@"n"] stringValue];
			
			NSString * value=[[f childAtIndex:0] stringValue];
			
			if([name isEqualToString:@"subject"])
			{
				result.headline=[FeedItem normalizeHeadline:value];
			}
			if([name isEqualToString:@"date"])
			{
				//20091121082741 = YYYYMMDDHHMMSS
				if([value length]==14)
				{
					
					result.date = [formatter dateFromString:value];  
				}
			}
			if([name isEqualToString:@"synopsis"])
			{
				result.synopsis=[FeedItem normalizeSynopsis:value];
			}
			if([name isEqualToString:@"uri"])
			{
				result.url=value;
			}
		}
		
        [resultItems addObject:result];
		
		[result release];
    }
	
	results.results=resultItems;
	
	[resultItems release];
	
	NSMutableArray * facetItems=[[NSMutableArray alloc] init];
	
	NSArray * facetNodes = [xmlParser nodesForXPath:@"/SearchResults/Facets/FieldFacets" error:nil];
	
    for (CXMLElement *fieldFacets in facetNodes) {
		
        FacetField * facetField=[[FacetField alloc] init];
		
		facetField.name=[[fieldFacets attributeForName:@"name"] stringValue];
		
		facetField.displayName=facetField.name;
		facetField.shortName=facetField.name;
		
		NSArray * facetValues=[fieldFacets nodesForXPath:@"Facets/Facet" error:nil];
	
		NSMutableArray * values=[[NSMutableArray alloc] init];
		
		for (CXMLElement *facet in facetValues) {
			
			FacetValue * facetValue = [[FacetValue alloc ] init];
			
			//facetValue.name.name=facetField.name;
			facetValue.value=[[facet attributeForName:@"value"] stringValue];
			
			facetValue.displayValue=facetValue.value;
			facetValue.shortValue=facetValue.value;
			//facetValue.description=facetValue.value;
			
			facetValue.count=[[[facet attributeForName:@"count"] stringValue] intValue];
			
			SearchArguments * facetArgs=[[SearchArguments alloc] init];
			
			if(args.query==nil || [args.query length]==0)
			{
				//facetArgs.query=[NSString stringWithFormat:@"+(%@:%@>75)",facetValue.fieldName,facetValue.fieldValue];
				facetArgs.query=[NSString stringWithFormat:@"+(%@:%@)",facetField.name,facetValue.value];
			}
			else
			{
				//facetArgs.query=[NSString stringWithFormat:@"+(%@) +(%@:%@>75)",args.query,facetValue.fieldName,facetValue.fieldValue];
				facetArgs.query=[NSString stringWithFormat:@"+(%@) +(%@:%@)",args.query,facetField.name,facetValue.value];
			}
			
			facetValue.args=facetArgs;
			[facetArgs release];
			
			 
			[values addObject:facetValue];
			
			[facetValue release];
		}
		
		facetField.values=values;
		
		[values release];
		
        [facetItems addObject:facetField];
		
		[facetField release];
    }
	
	results.facets=facetItems;
	
	[facetItems release];
	
	[formatter release];
	
	return results;
}

@end
