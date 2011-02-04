//
//  SavedSearch.m
//  Untitled
//
//  Created by Robert Stewart on 2/4/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "SavedSearch.h"
#import "SearchResult.h"
#import "Base64.h"
#import "TouchXML.h"
#import "MetaTag.h"

@implementation SavedSearch
@synthesize name,url,items,username,password,lastUpdated,ID;

/*- (id) init
{
	return [self initWithName:@"Unknown" withID:nil withUrl:nil];
}*/

- (id) initWithName:(NSString *)theName withID:(NSString*) theID withUrl:(NSString *) theUrl
{
	if(![super init])
	{
		return nil;
	}
	
	self.name=theName;
	self.url=theUrl;
	self.ID=theID;
	self.items=[[NSMutableArray alloc] init];
	self.lastUpdated=[[NSDate alloc] init];
	
	return self;
}




/*
- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:url forKey:@"url"];
	[encoder encodeObject:ID forKey:@"id"];
	
	[encoder encodeObject:items forKey:@"items"];
	[encoder encodeObject:lastUpdated forKey:@"lastUpdated"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.name=[decoder decodeObjectForKey:@"name"];
		self.url=[decoder decodeObjectForKey:@"url"];
		self.ID=[decoder decodeObjectForKey:@"id"];
		self.items=[decoder decodeObjectForKey:@"items"];
		self.lastUpdated=[decoder decodeObjectForKey:@"lastUpdated"];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	SavedSearch * copy=[[[self class] allocWithZone:zone] init];
	copy.name=[self.name copy];
	copy.url=[self.url copy];
	copy.ID=[self.ID copy];
	copy.lastUpdated=[self.lastUpdated copy];
	copy.items=[self.items copy];
	return copy;
}
*/
- (void) update
{
	if(!url) return;
	
	// how much time since last update (we'll cache for some time)
	NSDate * now=[NSDate date];
	
	double ti = [lastUpdated timeIntervalSinceDate:now];
    
	ti = ti * -1;
    
	// wait at least 5 mins between updates...
	
	if(items==nil || [items count]==0 || (ti<0) || (ti>300))
	{
		NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
		
		if(items && [items count]>0)
		{
			for(SearchResult * result in items)
			{
				[dict setObject:result forKey:result.headline];
				if(result.url && [result.url length]>30)
				{
					[dict setObject:result forKey:result.url];
				}
			}
		}
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy
														   timeoutInterval:90.0];
		// use FF user agent so server is ok with us...
		[request setValue: @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16" forHTTPHeaderField: @"User-Agent"];
		
		if (self.username!=nil && self.password!=nil && [self.username length]>0)
		{
			NSString *authString = [Base64 encode:[[NSString stringWithFormat:@"%@:%@",self.username,self.password] dataUsingEncoding:NSUTF8StringEncoding]]; 
			[request setValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"];
		}
		
		NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		NSDictionary *nsdict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"http://www.rixml.org/2005/3/RIXML",
							  @"rixml", 
							  nil];
		
		CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
		
		// Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
		NSArray * itemNodes = [xmlParser nodesForXPath:@"//item" error:nil];
		
		NSMutableArray * array=[[NSMutableArray alloc] init];

		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		
		/* This is required, Cocoa will try to use the current locale otherwise */
		NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[formatter setLocale:enUS];
		[enUS release];
		[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"]; /* Unicode Locale Data Markup Language e.g. @"Thu, 11 Sep 2008 12:34:12 GMT" */
		
		// Loop through the resultNodes to access each items actual data
		for (CXMLElement *itemNode in itemNodes) 
		{
			
			NSString * title=[[[itemNode elementsForName:@"title"] objectAtIndex:0] stringValue];
			
			title=[SearchResult normalizeHeadline:title];
			
			if([dict objectForKey:title]==nil)
			{
				NSString * link=[[[itemNode elementsForName:@"link"] objectAtIndex:0] stringValue];
			
				if(link==nil || ([link length]<30) || ([dict objectForKey:link]==nil))
				{
					NSString * dateString=[[[itemNode elementsForName:@"pubDate"] objectAtIndex:0] stringValue];
				
					NSDate *theDate = [formatter dateFromString:dateString]; /*e.g. @"Thu, 11 Sep 2008 12:34:12 GMT" */
				
					NSArray * contentNodes=[itemNode nodesForXPath:@".//rixml:Synopsis" namespaceMappings:nsdict error:nil];
					
					NSString * synopsis=nil;
					
					if (contentNodes) 
					{
						if([contentNodes count]>0)
						{
							synopsis=[[contentNodes objectAtIndex:0] stringValue];
							
							if(synopsis && [synopsis length]>0)
							{
								synopsis=[SearchResult normalizeSynopsis:synopsis];
							}
						}
					}
					
					SearchResult * result=[[SearchResult alloc] initWithHeadline:title withUrl:link withSynopsis:synopsis withDate:theDate];
				
					/*NSArray * issuerNodes=[itemNode nodesForXPath:@".//rixml:Issuer" namespaceMappings:nsdict error:nil];
					
					if(issuerNodes)
					{
						for(CXMLElement * issuerNode in issuerNodes)
						{
							MetaTag * tag=[[MetaTag alloc] init];
							
							NSString * primaryIndicator=[[issuerNode attributeForName:@"primaryIndicator"] stringValue];
							
							if([primaryIndicator isEqualToString:@"Yes"])
							{
								tag.fieldName=@"primarycompany";
							}
							else 
							{
								tag.fieldName=@"company";
							}
							
							NSArray * nameNodes=[issuerNode nodesForXPath:@"rixml:IssuerName/rixml:NameValue" namespaceMappings:nsdict error:nil];
							if(nameNodes)
							{
								tag.name=[[nameNodes objectAtIndex:0] stringValue];
								
								nameNodes=[issuerNode nodesForXPath:@"rixml:IssuerID[@idType='PublisherDefined']" namespaceMappings:nsdict error:nil];
								
								if (nameNodes) 
								{
									for(CXMLElement * nameNode in nameNodes)
									{
										NSString * nameType=[[nameNode attributeForName:@"publisherDefinedValue"] stringValue];
										if([nameType isEqualToString:@"IssuerId"])
										{
											tag.fieldValue=[[nameNode attributeForName:@"idValue"] stringValue];
										}
										else
										{
											if ([nameType isEqualToString:@"ExchangeTicker"]) 
											{
												tag.ticker=[[nameNode attributeForName:@"idValue"] stringValue];
											}
										}
									}
								}
								[result.metadata addObject:tag];
							}
						}
					}*/
					
					
					
					
					
					
					[array addObject:result];
				
					[dict setObject:result forKey:result.headline];
					if(result.url && [result.url length]>30)
					{
						[dict setObject:result forKey:result.url];
					}
					
					[result release];
				}
			}
		}
		
		[formatter release];
		 
		// only add in items that dont already exist
		// we will just use headline as the unique key for now...
		
		if(items && [items count]>0 && [array count]>0)
		{
			// append to items
			[items addObjectsFromArray:array];
			
			// re-sort by date in desc order
			
			//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
			
			//NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			//[array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
			
			//[sortDescriptor release];
		}
		else
		{
			self.items=array;
		}
		
		[dict release];
		[array release];
	
		[lastUpdated release];
		lastUpdated=[[NSDate alloc] init];
	}
}

- (void) dealloc
{
	[name release];
	[url release];
	[ID release];
	[items release];
	[username release];
	[password release];
	[lastUpdated release];
	[super dealloc];
}
@end
