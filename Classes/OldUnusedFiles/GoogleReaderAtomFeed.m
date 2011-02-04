//
//  GoogleReaderAtomFeed.m
//  Untitled
//
//  Created by Robert Stewart on 7/6/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "GoogleReaderAtomFeed.h"
#import "GoogleReaderClient.h"
#import "TouchXML.h"
#import "FeedItem.h"

@implementation GoogleReaderAtomFeed
@synthesize feedId,atomUrl,htmlUrl;

- (NSArray*) getNewItemsWithFilter:(ItemFilter*)filter
{
	GoogleReaderClient * client=[[GoogleReaderClient alloc] initWithAccount:self.account];
	
	NSMutableArray * items=[[[NSMutableArray alloc] init] autorelease];
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	NSString * data=[client getString:self.atomUrl];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	/* This is required, Cocoa will try to use the current locale otherwise */
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:enUS];
	[enUS release];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"]; /* 2010-07-06T11:14:50Z */
	
	if(data)
	{
		NSDictionary *nsdict = [NSDictionary dictionaryWithObjectsAndKeys:
								@"http://www.w3.org/2005/Atom",
								@"atom", 
								nil];
		
		CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:data options:0 error:nil] autorelease];
		
		NSArray * entries=[xmlParser nodesForXPath:@"//atom:entry" namespaceMappings:nsdict error:nil];
		
		if(entries)
		{
			for(CXMLElement * entry in entries)
			{
				FeedItem * result=[FeedItem new];
				
				result.headline=[FeedItem normalizeHeadline:[entry elementValue:@"title"]];
				
				//<category term="user/01817423256027348310/state/com.google/read" scheme="http://www.google.com/reader/" label="read"/>
				
				NSArray * categories=[entry elementsForName:@"category"];
				
				for(CXMLElement * category in categories)
				{
					
					if([[[category attributeForName:@"label"] stringValue ] isEqualToString:@"read"])
					{
						result.isRead=YES;
						break;
					}
				}
				
				NSArray * links=[entry elementsForName:@"link"];
				
				if(links && [links count]>0)
				{
					result.url=[[[links objectAtIndex:0] attributeForName:@"href"] stringValue];
				}
				
				if(filter)
				{
					if (![filter isNewItem:result]) 
					{
						continue;
					}
				}
				
				result.date=[formatter dateFromString:[entry elementValue:@"published"]];
				
				NSString * synopsis=[entry elementValue:@"summary"];
				
				if(synopsis==nil || [synopsis length]==0)
				{
					synopsis=[entry elementValue:@"content"];
				}
				
				result.origSynopsis=synopsis; 
				
				if(synopsis)
				{
					synopsis=[FeedItem normalizeSynopsis:[client flattenHTML:synopsis trimWhiteSpace:YES]];
				}
				
				result.synopsis=synopsis;
				
				result.origin=self.name;
				result.originUrl=self.htmlUrl;
				result.originId=self.feedId;
				
				[items addObject:result];
				
				[filter rememberItem:result];
				
				[result release];
				
				if([items count]>=kGoogleReaderMaxNumberOfItems)
				{
					break;
				}
			}
		}
	}
	
	[formatter release];
	
	[pool drain];
	
	[client release];
	
	return items;
}

- (void) resolveFeedImages:(NSMutableDictionary*)imageCache
{
	// all items should have the image of the feed...
	
	UIImage * img=[imageCache objectForKey:self.feedId];
	
	if(img==nil)
	{
		if(self.image)
		{
			img=self.image;
		}
		else 
		{
			img=[GoogleReaderClient getFaviconForFeedUrl:self.htmlUrl];
			
			if(img)
			{
				self.image=img;
			}
		}
		
		if(img)
		{
			[imageCache setObject:img forKey:self.feedId];
		}
	}
}

- (void) updateWithFilter:(ItemFilter*)filter;
{
	NSArray * newItems=[self getNewItemsWithFilter:filter];
	[self addItems:newItems withFilter:filter];
	
	[lastUpdated release];
	lastUpdated=[[NSDate alloc] init];
}

- (NSArray*) getNewItems
{
	return [self getNewItemWithFilter:nil];
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:feedId forKey:@"feedId"];
	[encoder encodeObject:atomUrl forKey:@"atomUrl"];
	[encoder encodeObject:htmlUrl forKey:@"htmlUrl"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super initWithCoder:decoder])
	{
		self.feedId=[decoder decodeObjectForKey:@"feedId"];
		self.atomUrl=[decoder decodeObjectForKey:@"atomUrl"];
		self.htmlUrl=[decoder decodeObjectForKey:@"htmlUrl"];
	}
	return self;
}

- (void) dealloc
{
	[feedId release];
	[atomUrl release];
	[htmlUrl release];
	[super dealloc];
}
@end
