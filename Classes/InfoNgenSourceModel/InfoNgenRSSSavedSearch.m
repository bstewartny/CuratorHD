//
//  SavedSearch.m
//  Untitled
//
//  Created by Robert Stewart on 2/4/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "InfoNgenRSSSavedSearch.h"
#import "FeedItem.h"
#import "TouchXML.h"
#import "MetaTag.h"
#import "FeedAccount.h"

@implementation InfoNgenRSSSavedSearch

- (NSArray*) getNewItems
{
	@try {
		return [self getNewItemsImpl];
	}
	@catch (NSException * e) {
		NSLog(@"Exception in getNewItems: %@",[e description]);
		return nil;
	}
	@finally {
	
	}
}

- (NSArray*) getNewItemsImpl
{
	if(!url) return nil;
	
	ItemFilter * filter=[ItemFilter new];
	
	for(FeedItem  * item in items)
	{
		[filter rememberItem:item];
	}
		
	NSData * data = [self getRssData];
	
	if(data==nil) return nil;
	
	NSDictionary *nsdict = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"http://www.rixml.org/2005/3/RIXML",
						  @"rixml", 
						  nil];
	
	CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
	
	// Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
	NSArray * itemNodes = [xmlParser nodesForXPath:@"//item" error:nil];
	
	NSMutableArray * array=[[[NSMutableArray alloc] init] autorelease];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	/* This is required, Cocoa will try to use the current locale otherwise */
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:enUS];
	[enUS release];
	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"]; /* Unicode Locale Data Markup Language e.g. @"Thu, 11 Sep 2008 12:34:12 GMT" */
	
	// Loop through the resultNodes to access each items actual data
	for (CXMLElement *itemNode in itemNodes) 
	{
		FeedItem * result=[FeedItem new];
		
		result.headline=[FeedItem normalizeHeadline:[[[itemNode elementsForName:@"title"] objectAtIndex:0] stringValue]];
		
		result.url=[[[itemNode elementsForName:@"link"] objectAtIndex:0] stringValue];
		
		if (![filter isNewItem:result]) 
		{
			continue;
		}
		
		result.date = [formatter dateFromString:[[[itemNode elementsForName:@"pubDate"] objectAtIndex:0] stringValue]]; /*e.g. @"Thu, 11 Sep 2008 12:34:12 GMT" */
	
		NSArray * contentNodes=[itemNode nodesForXPath:@".//rixml:Synopsis" namespaceMappings:nsdict error:nil];
		
		NSString * synopsis=nil;
		
		if (contentNodes) 
		{
			if([contentNodes count]>0)
			{
				synopsis=[[contentNodes objectAtIndex:0] stringValue];
				
				if(synopsis && [synopsis length]>0)
				{
					synopsis=[synopsis stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR>"];
					
					result.origSynopsis=synopsis;
					
					synopsis=[FeedItem normalizeSynopsis:synopsis];
				}
			}
		}
				
		result.synopsis=synopsis;
		
		if(result.url && [result.url length]>0)
		{
			if(result.origin==nil || [result.origin length]==0)
			{
				// make origin the domain of the URL...
				if ([result.url hasPrefix:@"http://"]) {
					NSURL * urlobject=[NSURL URLWithString:result.url];
					
					NSString * host=urlobject.host;
					
					if(host && [host length]>0)
					{
						result.originUrl=host;
						result.originId=host;
						
						if([host hasPrefix:@"www."] || [host hasPrefix:@"rss."])
						{
							host=[host substringFromIndex:4];
						}
						
						result.origin=host;
					}
				}
			}
		}
		
		[array addObject:result];
				
		[filter rememberItem:result];
				
		[result release];
	}
	
	[formatter release];
	
	[filter release];
	
	return array;
}

- (NSInteger) maxItems
{
	return 100;
}

- (void) dealloc
{
	[super dealloc];
}
@end
