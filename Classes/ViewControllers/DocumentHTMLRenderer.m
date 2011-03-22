//
//  DocumentHTMLRenderer.m
//  Untitled
//
//  Created by Robert Stewart on 11/16/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DocumentHTMLRenderer.h"
#import "FeedItem.h"

@implementation DocumentHTMLRenderer

- (NSString*) getItemHTML:(FeedItem*)item
{
	NSString   *html = [self getTemplateContents:@"ItemDocument"];
	NSString * itemHtml=[super getItemHTML:item];
	
	html=[self replaceTemplateSection:html sectionName:@"item" withContent:itemHtml];
	
	return html;
}
@end

@implementation FeedItemHTMLRenderer

- (NSString*) getItemHTML:(FeedItem*)item
{
	if([item.originId isEqualToString:@"Note"])
	{
		return [self getNoteItemHTML:item];
	}
	if([item.originId isEqualToString:@"twitter"])
	{
		return [self getTwitterItemHTML:item];
	}
	else 
	{
		return [self getDefaultItemHTML:item];
	}
}
  
- (NSString*) getDefaultItemHTML:(FeedItem*)item
{
	if(defaultItemTemplateContents==nil)
	{
		defaultItemTemplateContents=[[self getTemplateContents:@"FeedItemDocument"] retain];
	}

	NSString * html=defaultItemTemplateContents;//[self getTemplateContents:@"FeedItemDocument"];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:item.headline];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.url}}" withString:item.url];
	
	NSString * dateString=nil;
	
	if(item.date)
	{
		dateString=[self formatDate:item.date];
		
		if(item.origin && [item.origin length]>0)
		{
			dateString=[dateString stringByAppendingFormat:@" - %@",item.origin];
		}
	}
	else 
	{
		if(item.origin && [item.origin length]>0)
		{
			dateString=item.origin;
		}
	}
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.date}}" withString:dateString];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.synopsis}}" withString:item.origSynopsis];
	
	return html;
}
@end
