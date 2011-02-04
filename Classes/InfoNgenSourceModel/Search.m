//
//  Search.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Search.h"
#import "SearchArguments.h"
#import "SearchResults.h"
#import "FeedItem.h"
#import "FacetField.h"
#import "FacetValue.h"
#import "SearchClient.h"

@implementation Search
@synthesize args,results,isRefreshable;

- (id) init
{
	[super init];
	
	
	self.isRefreshable=YES;
	//self.query=@"+language:ENG";
	
	return self;
}

- (id) initWithQuery:(NSString*)query
{
	[super init];
	
	self.isRefreshable=YES;
	
	SearchArguments * targs=[[SearchArguments alloc] initWithQuery:query];
	
	self.args=targs;
	[targs release];
	
	return self;
}

- (void) update
{
	if(!self.isRefreshable)
	{
		return;
	}
	if(self.results==nil || self.results.results==nil || [self.results.results count]==0)
	{
		NSUserDefaults * settings=[NSUserDefaults standardUserDefaults];
		
		NSString * server=[settings objectForKey:@"server"];
		NSString * username=[settings objectForKey:@"username"];
		NSString * password=[settings objectForKey:@"password"];
		
		SearchClient * client=[[SearchClient alloc] initWithServer:server withUsername:username withPassword:password];
		
		self.results=[client search:self.args];
		
		[client release];
		
		/*
		SearchResults * tmp_results=[[SearchResults alloc] init];
		
		// get results
		NSMutableArray * tmp=[[NSMutableArray alloc] init];
		
		for(int i=0;i<50;i++)
		{
			SearchResult * result=[[SearchResult alloc] init];
			
			result.headline=[NSString stringWithFormat:@"Headline for Result %d",i];
			//result.synopsis=@"This is a test synpsis";
			
			NSMutableString * s=[[NSMutableString alloc] init];
			
			for(int j=0;j<i*2;j++)
			{
				[s appendString:@"This is another synopsis sentence.  "];
			}
			
			result.synopsis=s;
			
			[s release];
			result.url=@"http://www.dflskjfl.com/sdlfsdsd/sdfsdf";
			result.date=[[NSDate alloc] init];
			
			[tmp addObject:result];
		}
		
		tmp_results.results=tmp;
		[tmp release];
		
		// get facets
		
		NSMutableArray * facets=[[NSMutableArray alloc] init];
		
		FacetField * topicField=[[FacetField alloc] init];
		topicField.displayName=@"Topics";
		topicField.fieldName=@"topic";
		
		NSMutableArray * values=[[NSMutableArray alloc] init];
		
		for(int i=0;i<10;i++)
		{
			FacetValue * value=[[FacetValue alloc] init];
			value.fieldName=topicField.fieldName;
			value.displayName=@"Mergers & Acquisitions";
			value.fieldValue=@"m&a";
			value.count=1234;
			value.search=self;
			
			[values addObject:value];
			
			[value release];
		}
		
		topicField.values=values;
		
		[values release];
		
		[facets addObject:topicField];
		
		[topicField release];
		
		
		FacetField * companyField=[[FacetField alloc] init];
		companyField.displayName=@"Companies";
		companyField.fieldName=@"primarycompany";
		
		values=[[NSMutableArray alloc] init];
		
		for(int i=0;i<10;i++)
		{
			FacetValue * value=[[FacetValue alloc] init];
			value.fieldName=companyField.fieldName;
			value.displayName=@"Microsoft Corp.";
			value.fieldValue=@"10003434";
			value.count=97584;
			value.search=self;
			
			[values addObject:value];
			
			[value release];
		}
		
		companyField.values=values;
		
		[values release];
		
		[facets addObject:companyField];
		
		[companyField release];
		
		tmp_results.facets=facets;
		[facets release];
		
		self.results=tmp_results;
		*/
	}
	
}

- (void)dealloc {
	[args release];
	[results release];
    [super dealloc];
}

@end
