//
//  MetaNameResolver.m
//  Untitled
//
//  Created by Robert Stewart on 4/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "MetaNameResolver.h"
#import "MetaNameValue.h"
#import "Base64.h"
#import "TouchXML.h"
#import <CoreData/CoreData.h>


@implementation MetaNameResolver
@synthesize lastUpdated,fetchedResultsController, managedObjectContext;

- (id) init
{
	if([super init])
	{
		self.lastUpdated=[NSDate date];
	}
	return self;
}

- (BOOL) isExpired
{
	// how much time since last update (we'll cache for some time)
	
	double ti = [self.lastUpdated timeIntervalSinceDate:[NSDate date]];
    
	ti = ti * -1;
    
	// wait at least 24 hours between updates...

	if(ti<0 || ti>24*60*60)
	{
		return YES;
	}
	else 
	{
		NSUInteger count=[self countMetaNames];
		
		if(count==0) return YES;
		
		return NO;
	}
}

- (NSUInteger) countMetaNames
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"MetaName" inManagedObjectContext:managedObjectContext]];
	
	[request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
	[request setIncludesPropertyValues:NO];
	
	NSError *err;
	NSUInteger count = [managedObjectContext countForFetchRequest:request error:&err];
	
	if(count == NSNotFound) 
	{
		//Handle error
		return 0;
	}
	else 
	{
		return count;
	}

	[request release];
}


- (void) update:(NSString*)url username:(NSString*)username password:(NSString*)password
{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:90.0];
	// use FF user agent so server is ok with us...
	[request setValue: @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16" forHTTPHeaderField: @"User-Agent"];
	
	if (username!=nil && password!=nil && [username length]>0)
	{
		NSString *authString = [Base64 encode:[[NSString stringWithFormat:@"%@:%@",username,password] dataUsingEncoding:NSUTF8StringEncoding]]; 
		[request setValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"];
	}
	
	[request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
	
	NSLog(@"Fetching meta names data...");
	
	NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if(data)
	{
		NSLog(@"Got meta names data... now parsing...");
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		// parse XML
		CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
		
		// Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
		NSArray * nameNodes = [xmlParser nodesForXPath:@"/metanames/n" error:nil];
		
		if(nameNodes!=nil && [nameNodes count]>0)
		{
			NSString * name;
			NSString * value;
			NSString * displayName;
			NSString * displayValue;
			NSString * shortName;
			NSString * shortValue;
			
			// delete existing core data entities
			NSLog(@"reset existing metanames database");
			
			[[[UIApplication sharedApplication] delegate] resetMetaNamesStore];
		
			
			NSLog(@"Enumerating names...");
			
			// Loop through the resultNodes to access each items actual data
			for (CXMLElement *nameNode in nameNodes) 
			{
				
				name=[[nameNode attributeForName:@"n"] stringValue];
				shortName=[[nameNode attributeForName:@"s"] stringValue];
				displayName=[[nameNode attributeForName:@"d"] stringValue];
				
				NSArray * valueNodes=[nameNode nodesForXPath:@"v" error:nil];
				
				NSLog(@"Enumerating values for %@",name);
				
				for(CXMLElement * valueNode in valueNodes)
				{
					NSAutoreleasePool * inner_pool = [[NSAutoreleasePool alloc] init];
					
					value=[[valueNode attributeForName:@"v"] stringValue];
					shortValue=[[valueNode attributeForName:@"s"] stringValue];
					displayValue=[[valueNode attributeForName:@"d"] stringValue];
					
					// create core data entity
					NSManagedObject *newMetaName = [NSEntityDescription insertNewObjectForEntityForName:@"MetaName" inManagedObjectContext:managedObjectContext];
					
					// If appropriate, configure the new managed object.
					[newMetaName setValue:name forKey:@"name"];
					[newMetaName setValue:shortName forKey:@"shortName"];
					[newMetaName setValue:displayName forKey:@"displayName"];
					[newMetaName setValue:value forKey:@"value"];
					[newMetaName setValue:shortValue forKey:@"shortValue"];
					[newMetaName setValue:displayValue forKey:@"displayValue"];
					
					[inner_pool drain];
					
				}
				
				
			}
			
			// save core data entities
			NSLog(@"Saving core data entities");
			
			// Save the context.
			NSError *error = nil;
			if (![managedObjectContext save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}
			NSLog(@"Saved all core data entities");
			
			[pool drain];
		}
	}

	self.lastUpdated=[NSDate date];
}

// lookup name given name and value - used to resolve names from search results and facets for display
- (MetaNameValue*) resolveByName:(NSString*)name value:(NSString*)value
{
	if ([name isEqualToString:@"primarycompany"]) {
		name=@"company";
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MetaName" inManagedObjectContext:managedObjectContext];
    
	[fetchRequest setEntity:entity];
	
	// TODO: store combined value of "name:value" and index that single field for fast lookup
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"value == %@",value]];
	
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    NSError *error;
	
	NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if (array == nil || [array count]==0)
	{
		
		NSLog(@"Found no values for fetch query");	
		return nil;
	}
	else 
	{
		NSManagedObject * object=[array objectAtIndex:0];
		
		MetaNameValue * result=[[MetaNameValue alloc] init];
		
		result.name.name=name;
		result.value.value=value;
		result.name.displayName=[object valueForKey:@"displayName"];
		result.name.shortName=[object valueForKey:@"shortName"];
		result.value.displayValue=[object valueForKey:@"displayValue"];
		result.value.shortValue=[object valueForKey:@"shortValue"];
		
		return [result autorelease];
	}

	[fetchRequest release];
	
	return nil;
}

- (NSArray*) lookupByName:(NSString*)name displayValue:(NSString*)displayValue
{
	NSMutableArray * matches=[[[NSMutableArray alloc] init] autorelease];
	
	if(displayValue && [displayValue length]>0)
	{
	
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"MetaName" inManagedObjectContext:managedObjectContext];
		
		[fetchRequest setEntity:entity];
		
		if(name!=nil && [name length]>0)
		{
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND ((displayValue BEGINSWITH[cd] %@) OR (shortValue BEGINSWITH[cd] %@))",name,displayValue,displayValue]];
		}
		else 
		{
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(displayValue BEGINSWITH[cd] %@) OR (shortValue BEGINSWITH[cd] %@)",displayValue,displayValue]];
		}
	
		NSSortDescriptor *sortByDisplayValue = [[NSSortDescriptor alloc] initWithKey:@"displayValue" ascending:YES];
		
		[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDisplayValue]];
		[sortByDisplayValue release];

		// Set the batch size to a suitable number.
		[fetchRequest setFetchBatchSize:50];
		
		NSError *error;
		
		NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
		
		if (array)
		{
			for(NSManagedObject * object in array)
			{
				MetaNameValue * result=[[MetaNameValue alloc] init];
				
				result.name.name=[object valueForKey:@"name"];
				result.value.value=[object valueForKey:@"value"];
				result.name.displayName=[object valueForKey:@"displayName"];
				result.name.shortName=[object valueForKey:@"shortName"];
				result.value.displayValue=[object valueForKey:@"displayValue"];
				result.value.shortValue=[object valueForKey:@"shortValue"];
				
				[matches addObject:result];
				
				[result release];
			}
		}
		
		[fetchRequest release];
	}
	
	return matches;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	NSLog(@"MetaNameResolver::encodeWithCoder");
	NSLog(@"encode lastUpdated");
	[encoder encodeObject:lastUpdated forKey:@"lastUpdated"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.lastUpdated=[decoder decodeObjectForKey:@"lastUpdated"];
	}
	return self;
}

- (void) dealloc
{
	[lastUpdated release];
	[super dealloc];
}


@end
