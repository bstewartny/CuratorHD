#import "GoogleReaderClient.h"
#import "JSON.h"
#import "FeedItem.h"
#import "TouchXML.h"
#import "ItemFilter.h"
#import "FeedAccount.h"
#import "UrlUtils.h"
#import "UrlParams.h"
#import "GoogleClientLogin.h"
#import "GoogleAppEngineAuth.h"
#import "MarkupStripper.h"
#import "Feed.h"

@implementation GoogleReaderClient
@synthesize  username,password;
static NSString * token;
static NSString * auth;
static NSString * gaeCookie;

- (id) initWithUsername:(NSString*)username password:(NSString*)password
{
	return [self initWithUsername:username password:password useCachedAuth:YES];
}

- (id) initWithUsername:(NSString*)username password:(NSString*)password useCachedAuth:(BOOL)useCachedAuth
{
	NSLog(@"GoogleReaderClient:initWithUserName");
	
	if([super init])
	{
		self.username=username;
		
		self.password=password;
		
		@synchronized(auth)
		{
			if(!useCachedAuth)
			{
				NSLog(@"Clearing static auth cache...");
				[auth release];
				auth=nil;
				[token release];
				token=nil;
				[gaeCookie release];
				gaeCookie=nil;
			}
			
			if(auth==nil || [auth length]==0)
			{
				NSLog(@"Getting auth key from google login...");
				auth=[GoogleClientLogin getAuthKeyWithUsername:username andPassword:password forService:@"reader" withSource:@"CuratorHD"];
				[auth retain];
				NSLog(@"auth key=%@",auth);
			}
			
			if(auth!=nil && [auth length]>0)
			{
				if(token==nil || [token length]==0)
				{
					NSLog(@"Getting edit token...");
					token=[[self getEditToken] retain];
					NSLog(@"Edit token=%@",token);
				}
				/*
				if(gaeCookie==nil || [gaeCookie length]==0)
				{
					NSLog(@"Getting GAE cookie...");
					gaeCookie=[GoogleAppEngineAuth getAuthCookieWithAppURL:@"http://curatorhd.appspot.com" andUsername:username andPassword:password withSource:@"CuratorHD"];

					[gaeCookie retain];
					NSLog(@"GAE Cookie=%@",gaeCookie);
				}*/
			}
		}
	}
	return self;
}

- (NSString*) getEditToken
{
	NSLog(@"getEditToken");
	NSString * url=@"http://www.google.com/reader/api/0/token";
	
	return [self getString:url];
}

- (void) appendAcceptGzipEncodingHeader:(NSMutableURLRequest*)request
{
	//User-Agent: my program (gzip)
	//Accept-Encoding: gzip
	
	[request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
}

- (void) appendUserAgentHeader:(NSMutableURLRequest*)request useGzip:(BOOL)useGzip
{
	if(useGzip)
	{
		[request addValue:@"InfoNgen Curator HD (gzip)" forHTTPHeaderField:@"User-Agent"];
	}
	else 
	{
		[request addValue:@"InfoNgen Curator HD" forHTTPHeaderField:@"User-Agent"];
	}
}

- (void) appendAuthHeader:(NSMutableURLRequest*)request
{
	@synchronized(auth)
	{
		if(auth && [auth length]>0)
		{
			NSString * value=[NSString stringWithFormat:@"GoogleLogin auth=%@",auth];
			
			[request addValue:value forHTTPHeaderField:@"Authorization"];
			
			[request setValue:auth forHTTPHeaderField:@"auth"];
		}
	}
}

- (BOOL) postEditCommand:(NSString*)url params:(UrlParams*)params
{
	@try 
	{
		[[NSURLCache sharedURLCache] removeAllCachedResponses];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		
		[request setHTTPMethod:@"POST"];
		[self appendAuthHeader:request];
		[self appendUserAgentHeader:request useGzip:NO];
		 
		[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		
		NSString *post = [params getQueryString];
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		
		[request addValue:postLength forHTTPHeaderField:@"Content-Length"];
		
		[request setHTTPBody:postData];
		
		NSHTTPURLResponse * response=NULL;
		
		NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
		
		NSInteger code=[response statusCode];
		
		if(code >=200 && code < 404)
		{
			if(data)
			{
				// returns OK if success, otherwise failed...
				NSString * responseString= [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
				
				if([responseString isEqualToString:@"OK"] ||
				   [responseString isEqualToString:@"Ok"] ||
				   [responseString isEqualToString:@"ok"])
				{
					return YES;
				}
				else 
				{
					return NO;
				}
			}
			else 
			{
				return NO;
			}
		}
		else 
		{
			NSLog(@"Got status code %d from server, returning nil for data...",code);
			return NO;
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception in getData for url: %@: %@",url,[e description]);
		return NO;
	}
	@finally 
	{
	}
}

- (NSData*) getData:(NSString*)url
{
	@try 
	{
		NSLog(@"getData: %@",url);
		
		// attempt to avoid leaking NSData from response?
		//NSLog(@"clearing cached responses");
		[[NSURLCache sharedURLCache] removeAllCachedResponses];
		//NSLog(@"done clearing cached responses");
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		[self appendAuthHeader:request];
		[self appendUserAgentHeader:request useGzip:YES];
		[self appendAcceptGzipEncodingHeader:request];
		
		NSHTTPURLResponse * response=NULL;
		
		
		NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	
		NSInteger code=[response statusCode];
		
		if(code >=200 && code < 404)
		{
			return data;
		}
		else 
		{
			NSLog(@"Got status code %d from server, returning nil for data...",code);
			return nil;
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception in getData for url: %@: %@",url,[e description]);
		return nil;	
	}
	@finally 
	{
	}
}

- (NSDictionary*) getJson:(NSString*)url
{
	@try {
		NSString * json=[self getString:url];	
		
		if(json)
		{
			return [json JSONValue];
		}
		else 
		{
			return nil;
		}
	}
	@catch (NSException * e) {
		NSLog(@"Exception in getJson for url: %@: %@",url,[e description]);
		return nil;
	}
	@finally 
	{
	}
}

- (NSString*) getString:(NSString*)url
{
	@try {
		NSData * data=[self getData:url];	
		
		if(data)
		{
			return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		}
		else 
		{
			return nil;
		}
	}
	@catch (NSException * e) {
		NSLog(@"Exception in getJson for getString: %@: %@",url,[e description]);
		return nil;
	}
	@finally 
	{
	}
}

- (NSArray*) getClippedItemsWithFilter:(ItemFilter*)filter
{
	NSLog(@"getClippedItemsWithFilter");
	
	NSMutableArray * tmp=[[[NSMutableArray alloc] init] autorelease];
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	NSArray * items=nil;
	
	@try 
	{
		items=[self getJson:@"http://curatorhd.appspot.com/items"];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Failed to get items from http://curatorhd.appspot.com/items");
	}
	@finally 
	{
		
	}
	
	if(items && [items count]>0)
	{
		MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
		NSLog(@"Got %d items from GAE",[items count]);
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		
		NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		
		// 2010-10-27T20:09:21.808860
		
		[formatter setLocale:enUS];
		[enUS release];
		[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:S"]; 
		
		
		for(NSDictionary * item in items)
		{
			TempFeedItem * result=[[TempFeedItem alloc] init];
			
			@try 
			{
				
				NSString * url=[item objectForKey:@"url"];
				NSString * timestamp=[item objectForKey:@"timestamp"]; //2010-10-27T20:09:21.808860
				NSString * title=[item objectForKey:@"title"];
				NSString * synopsis=[item objectForKey:@"synopsis"];
				NSString * folder=[item objectForKey:@"folder"];
				
				if([folder length]==0)
				{
					folder=@"Read Later";
				}
				
				NSString * comment=[item objectForKey:@"comment"];
				if([comment length]==0)
				{
					comment=nil;
				}
				
				result.url=url;
				result.headline=title;
				result.date=[formatter dateFromString:timestamp];
				
				if(filter)
				{
					if ([filter isOldDate:result.date]) 
					{
						// all other items in this feed are older since feed is sorted in desc order, so we can break the loop now
						break;
					}
					
					if(![filter isNewItem:result])
					{
						continue;
					}
				}
				
				result.synopsis=synopsis;
				result.origSynopsis=synopsis;
				
				if(comment && [comment length]>0)
				{
					result.notes=[stripper stripMarkup:comment] ;//[comment flattenHTML];
				}
				
				[tmp addObject:result];
			}
			@catch (NSException * e) 
			{
				NSLog(@"Exception parsing result item from response: %@",[e description]);
			}
			@finally 
			{
				[result release];
			}
		}
		[formatter release];
	}
	else {
		NSLog(@"Got 0 items from GAE");
	}

	[pool drain];
	
	return tmp;
	
}


- (NSArray*) getTags
{
	/*
	 
	 <list name="tags">
	 <object>
		<string name="id">user/01817423256027348310/state/com.google/starred</string>
		<string name="sortid">C0F128A5</string></object>
	 <object>
		<string name="id">user/01817423256027348310/state/com.google/broadcast</string>
		<string name="sortid">B7F45CD9</string>
	 </object>
	 <object>
		<string name="id">user/01817423256027348310/label/Entrepreneurship</string>
		<string name="sortid">C31B46CC</string>
	 </object>
	 <object>
		<string name="id">user/01817423256027348310/label/Personal</string>
		<string name="sortid">341517B7</string>
	 </object>
	 <object>
		<string name="id">user/01817423256027348310/label/Programming</string>
		<string name="sortid">82DE8EF8</string>
	 </object>
	 <object>
		<string name="id">user/01817423256027348310/state/com.blogger/blogger-following</string>
		<string name="sortid">48035E7F</string>
	 </object>
	 </list>
	 
	*/
	
	NSString * data=[self getString:@"http://www.google.com/reader/api/0/tag/list"];
	
	NSMutableArray * tagnames=[[[NSMutableArray alloc] init] autorelease];
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:data options:0 error:nil] autorelease];
	
	NSArray * tags=[xmlParser nodesForXPath:@"object/list[@name='tags']/object/string[@name='id']" error:nil];
	
	if(tags)
	{
		for(CXMLElement * tag in tags)
		{
			NSString * tagid=[tag  stringValue];
			NSRange range=[tagid rangeOfString:@"/label/"];
			if(range.location!=NSNotFound)
			{
				NSString * tagName=[tagid substringFromIndex:range.location + 7];
				
				[tagnames addObject:tagName];
			}
		}
	}
	
	[pool drain];
	
	return tagnames;
}





/*
 
 {"crawlTimeMsec":"1283957112668",
 "id":"tag:google.com,2005:reader/item/34fc3eefa9fec5fe",
 "categories":["user/01817423256027348310/label/testtag1",
 "user/01817423256027348310/label/testtag2",
 "user/01817423256027348310/source/com.google/link",
 "user/01817423256027348310/state/com.google/broadcast",
 "user/01817423256027348310/state/com.google/read",
 "user/01817423256027348310/state/com.google/fresh"],
 "title":"An Introduction To Domain-Driven Design",
 "published":1283957112,
 "updated":1283957112,
 "alternate":[{"href":"http://msdn.microsoft.com/en-us/magazine/dd419654.aspx","type":"text/html"}],
 "related":[{"href":"http://msdn.microsoft.com/","title":"msdn.microsoft.com"}],
 "likingUsers":[],
 "comments":[],
 "annotations":[{"content":"Another sharing test for ipad app...",
 "author":"Bob",
 "userId":"01817423256027348310",
 "profileId":"105780325577497843914",
 "profileCardParams":"uid\u003d105780325577497843914\u0026bc\u003d0\u0026hl\u003den\u0026service\u003dreader\u0026name\u003dBob\u0026clt\u003dFollow+Bob\u0026clue\u003damF2YXNjcmlwdDp0b3AuRlJfRnJpZW5kc19zdGFydEZvbGxvd2luZygnMDE4MTc0MjMyNTYwMjczNDgzMTAnLCAnMTA1NzgwMzI1NTc3NDk3ODQzOTE0JywgJ0JvYicp\u0026s\u003dAB_q7XGJuhwxSXGCmbRg_23NBO8i1AA32g"}],
 "origin":{"streamId":"user/01817423256027348310/source/com.google/link",
 "title":"msdn.microsoft.com",
 "htmlUrl":"http://msdn.microsoft.com/"
 }}
 
 
 
 */

- (NSArray*) getItems:(GoogleReaderFeedType)feedType tag:(NSString*)tag filter:(ItemFilter*)filter
{
	return [self getItemsForUrl:[self getUrlForType:feedType tag:tag] filter:filter];
}

- (NSString*) getUrlForType:(GoogleReaderFeedType)feedType tag:(NSString*)tag
{
	switch(feedType)
	{
		case GoogleReaderFeedTypeAllItems:
			return @"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/reading-list";
		case GoogleReaderFeedTypeSharedItems:
			return @"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/broadcast";
		case GoogleReaderFeedTypeStarredItems:
			return @"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/starred";
		case GoogleReaderFeedTypeTaggedItems:
			return [NSString stringWithFormat:@"http://www.google.com/reader/api/0/stream/contents/user/-/label/%@",[tag stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
		case GoogleReaderFeedTypeFollowingItems:
			return @"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/broadcast-friends";
		case GoogleReaderFeedTypeNotes:
			return @"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/created";
		default:
			return @"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/reading-list";
	}
}

- (NSArray*) getItemsForUrl:(NSString*)url  filter:(ItemFilter*)filter
{
	NSLog(@"getItemsForUrl:%@",url);
	
	unsigned long current_seconds=[[NSDate date] timeIntervalSince1970];
	
	NSString * timestamp=[NSString stringWithFormat:@"%D",current_seconds];
	
	url=[url stringByAppendingFormat:@"?n=%d&ck=%@&client=%@",kGoogleReaderMaxNumberOfItems,timestamp,kGoogleReaderClientName];
	
	if(filter)
	{
		if(filter.minDate)
		{
			unsigned long min_date_seconds=[filter.minDate timeIntervalSince1970];
			NSString * ot=[NSString stringWithFormat:@"%D",min_date_seconds];
			url=[url stringByAppendingFormat:@"&ot=%@",ot];
		}
	}
	
	NSMutableArray * tmp=[[[NSMutableArray alloc] init] autorelease];
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	NSDictionary * dict=[self getJson:url];
	
	MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
	
	
	if(dict)
	{
		NSArray * items=[dict objectForKey:@"items"];
	
		if(items && [items count]>0)
		{
			for(NSDictionary * item in items)
			{
				FeedItem * result=[[FeedItem alloc] init];
				
				@try {
					 
					// "id":"tag:google.com,2005:reader/item/857fa79a25a8a188",
					// "categories":["user/01817423256027348310/state/com.google/read"
					
					NSString * dateString=[item objectForKey:@"published"];
					
					// unix time, number of seconds from January 1st, 1970 00:00 UTC
					
					NSTimeInterval seconds=[dateString doubleValue];
					
					NSDate * theDate=[NSDate dateWithTimeIntervalSince1970:seconds];
					
					result.date=theDate;
					
					//result.headline=[FeedItem normalizeHeadline:[item objectForKey:@"title"]];
					result.headline=[stripper stripMarkup:[item objectForKey:@"title"]];
					
					NSArray * categories=[item objectForKey:@"categories"];
					
					for (NSString * category in categories)
					{
						if([category hasPrefix:@"user/"] && [category hasSuffix:@"/state/com.google/read"])
						{
							// item has been read
							result.isRead=[NSNumber numberWithBool:YES];
							break;
						}
					}
					
					if([item objectForKey:@"alternate"])
					{
						result.url=[[[item objectForKey:@"alternate"] objectAtIndex:0] objectForKey:@"href"];
					}
					
					if(filter)
					{
						if ([filter isOldDate:result.date]) 
						{
							// all other items in this feed are older since feed is sorted in desc order, so we can break the loop now
							break;
						}
						
						if(![filter isNewItem:result])
						{
							continue;
						}
					}
					
					NSString * synopsis;
					
					if([item objectForKey:@"summary"])
					{
						synopsis=[[item objectForKey:@"summary"] objectForKey:@"content"];
					}
					else 
					{
						synopsis=[[item objectForKey:@"content"] objectForKey:@"content"];
					}

					result.origSynopsis=synopsis;//[NSString stringWithFormat:@"@%",synopsis]; ///  [synopsis copy];
					
					if ([item objectForKey:@"annotations"]) 
					{
						NSArray * annotations=[item objectForKey:@"annotations"];
						if([annotations count]>0)
						{
							NSString * notes=[[annotations objectAtIndex:0] objectForKey:@"content"];
							
							if (notes && [notes length]>0) 
							{
								result.notes=[stripper stripMarkup:notes];//[notes flattenHTML];
								
								//result.notes=[self flattenHTML:notes trimWhiteSpace:YES];
							}
						}
					}
					
					if ([item objectForKey:@"origin"])
					{
						NSString * origin=[stripper stripMarkup:[[item objectForKey:@"origin"] objectForKey:@"title"]];
						NSString * htmlUrl=[[item objectForKey:@"origin"] objectForKey:@"htmlUrl"];
						NSString * streamId=[[item objectForKey:@"origin"] objectForKey:@"streamId"];
						
						result.origin=origin;
						result.originUrl=htmlUrl;
						result.originId=streamId;
					}
					
					[tmp addObject:result];
				}
				@catch (NSException * e) 
				{
					NSLog(@"Exception parsing result item from response: %@",[e userInfo]);
				}
				@finally 
				{
					[result release];
				}
			}
		}
	}
	
	[pool drain];
	
	return tmp;
}

- (NSArray*) getUnreadIds:(int)max
{
	NSString * url=[NSString stringWithFormat:@"http://www.google.com/reader/api/0/stream/items/ids?s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&n=%d",max ];
	
	return [self getIds:url];
}

- (NSArray*) getReadIds:(int)max
{
	NSString * url=[NSString stringWithFormat:@"http://www.google.com/reader/api/0/stream/items/ids?s=user/-/state/com.google/read&n=%d",max];
	
	return [self getIds:url];
}

- (NSArray*) getIds:(NSString*)url
{
	NSString * data=[self getString:url];
	
	NSMutableArray * array=[[[NSMutableArray alloc] init] autorelease];
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:data options:0 error:nil] autorelease];
	
	/*
	 
	 <object>
		<list name="itemRefs">
			<object>
				<number name="id">-1652467681005343241</number>
				<list name="directStreamIds">
					<string>user/01817423256027348310/state/com.google/read</string>
				</list>
				<number name="timestampUsec">1283196633742994</number>
			</object>
			...
	 
	 
	*/

	NSArray * tags=[xmlParser nodesForXPath:@"object/list[@name='itemRefs']/object/number[@name='id']" error:nil];
	
	if(tags)
	{
		for(CXMLElement * tag in tags)
		{
			NSString * itemid=[tag  stringValue];
			
			[array addObject:[self translateItemId:itemid]];
		}
	}
	
	[pool drain];
	
	return array;
}

- (NSString*) translateItemId:(NSString*)raw
{
	// We need id in format: 'tag:google.com,2005:reader/item/<translated unsigned long>'
	long long n=[raw longLongValue];
	
	NSString * tmp=[NSString stringWithFormat:@"%qx",n];
	
	// pad with leading zeros...
	while([tmp length]<16)
	{
		tmp=[NSString stringWithFormat:@"0%@",tmp];
	}
		
	if([tmp length]!=16)
	{
		NSLog(@"!!!!!!!******** id is NOT 16 characters wide: %@ *******!!!!!!!",tmp);
	}
	
	return [NSString stringWithFormat:@"tag:google.com,2005:reader/item/%@",tmp];
}

- (BOOL) isValid
{
	@synchronized(auth)
	{
		return (auth!=nil && [auth length]>0);
	}
}

- (void) markAsRead:(FeedItem*)item
{
	NSString * url=@"http://www.google.com/reader/api/0/edit-tag";
	
	if(token==nil || [token length]==0)
	{
		NSLog(@"Failed to get edit token for Google Reader, cannot mark as read...");
		return;
	}
	
	NSString * itemId=item.uid; // get item id in the form tag:google.com,2005:reader/item/... 
	
	if(itemId==nil || [itemId length]==0)
	{
		NSLog(@"item has no id, cannot mark as read...");
		return;
	}
	UrlParams * params=[[UrlParams alloc] init];
	
	[params appendParam:@"i" value:itemId];
	[params appendParam:@"a" value:@"user/-/state/com.google/read"];
	[params appendParam:@"ac" value:@"edit"];
		
	[params appendParam:@"T" value:token];
	
	if(![self postEditCommand:url params:params])
	{
		NSLog(@"Failed to mark item as read: %@",[params getQueryString]);
		/*@synchronized(token)
		{
			// maybe edit token is expired...
			[token release];
			token=[[self getEditToken] retain];
		}*/
	}

	[params release];
}

- (NSArray*) getSubscriptionList:(NSMutableDictionary*)imageCache
{
	// get users subscription list 
	
	NSMutableArray * feeds=[[NSMutableArray alloc] init];

	NSDictionary * results=[self getJson:@"http://www.google.com/reader/api/0/subscription/list?output=json"];
	
	BOOL requiresFaviconDownload=NO;
	if(results)
	{
		MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
		NSArray * subscriptions=[results objectForKey:@"subscriptions"];
		
		if(subscriptions)
		{
			for(NSDictionary * subscription in subscriptions)
			{
				/*
					"id":"feed/http://feeds.feedburner.com/10xSoftwareDevelopment",
					"title":"10x Software Development",
					"categories":[{"id":"user/01817423256027348310/label/Programming","label":"Programming"}],
					"sortid":"64BE0E52",
					"firstitemmsec":"1207017119481",
					"htmlUrl":"http://forums.construx.com/blogs/stevemcc/default.aspx"}
				 */
				
				
				TempFeed * feed=[TempFeed new];
				
				//feed.name=[stripper stripMarkup:[subscription objectForKey:@"title"]];
				feed.name=[subscription objectForKey:@"title"];
				
				feed.feedId=[subscription objectForKey:@"id"];
				feed.htmlUrl=[subscription objectForKey:@"htmlUrl"];
				
				feed.url=[NSString stringWithFormat:@"http://www.google.com/reader/atom/%@",[subscription objectForKey:@"id"]];
				
				// get category (folder to put feed into)
				feed.feedType=@"GoogleAtom";
				
				NSArray * categories=[subscription objectForKey:@"categories"];
				NSMutableString * feedCategory=[[NSMutableString alloc] init];
				
				if(categories && [categories count]>0)
				{
					// get first category (only support one for now)
					for(NSString * category in categories)
					{
						NSString * label=[category objectForKey:@"label"];
						
						if(label && [label length]>0)
						{
							if([feedCategory length]==0)
							{
								[feedCategory appendString:@"|"];
							}
							
							[feedCategory appendFormat:@"%@|",label];
						}
					}
				}
				
				if([feedCategory length]>0)
				{
					feed.feedCategory=feedCategory;
				}
				else 
				{
					feed.feedCategory=@"_none"; // not categorized into a folder...
				}

				
				[feedCategory release];
				
				[feeds addObject:feed];
				
				[feed release];
			}
		}
	}
	
	return feeds;
}

- (NSArray*) getFollowingItems:(ItemFilter*)filter
{
	return [self getItemsForUrl:@"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.blogger/blogger-following" filter:filter];
}

- (NSArray*) getSharedItems:(ItemFilter*)filter
{
	return [self getItemsForUrl:@"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/broadcast" filter:filter];
}

- (NSArray*) getNotes:(ItemFilter*)filter
{
	return [self getItemsForUrl:@"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/created" filter:filter];
}
- (NSArray*) getStarredItems:(ItemFilter*)filter
{
	return [self getItemsForUrl:@"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/starred" filter:filter];
}

- (NSArray*) getAllItems:(ItemFilter*)filter
{
	return [self getItemsForUrl:@"http://www.google.com/reader/api/0/stream/contents/user/-/state/com.google/reading-list" filter:filter];
}

- (NSArray*) getTaggedItems:(NSString*)tag filter:(ItemFilter*)filter
{
	// TODO: encode data
	// replace spaces in URL
	NSString * encoded_tag=[tag stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	return [self getItemsForUrl:[NSString stringWithFormat:@"http://www.google.com/reader/api/0/stream/contents/user/-/label/%@",encoded_tag]  filter:filter];
}

- (void) dealloc
{
	[username release];
	[password release];
	[super dealloc];
}
@end
