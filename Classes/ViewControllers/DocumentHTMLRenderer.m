//
//  DocumentHTMLRenderer.m
//  Untitled
//
//  Created by Robert Stewart on 11/16/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DocumentHTMLRenderer.h"
#import "FeedItem.h"
#import "Base64.h"


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
- (NSString*) getTwitterItemHTML:(FeedItem*)item
{
	NSLog(@"getTwitterItemHTML");
	
	if(item==nil) return @"";
	
	//NSString   *html = [self getTemplateContents:@"DefaultItem"];
	NSString   *html = [self getTemplateContents:@"TwitterItem"];
	
	//NSString * userlink=[NSString stringWithFormat:@"<a style=\"text-decoration:none\" href=\"http://twitter.com/%@\">%@</a>",item.originUrl,item.originUrl];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:item.originUrl];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.url}}" withString:[NSString stringWithFormat:@"http://twitter.com/%@",item.originUrl]];
	
	//NSString * tweet=[NSString stringWithFormat:@"%@ %@",userlink,item.origSynopsis];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.synopsis}}" withString:item.origSynopsis];
	
	NSString * dateString=nil;
	
	if(item.date)
	{
		dateString=[self formatDate:item.date];
		
		//if(item.origin && [item.origin length]>0)
		//{
		//	dateString=[dateString stringByAppendingFormat:@" - %@ via Twitter",item.origin];
		//}
	}
	else 
	{
		//if(item.origin && [item.origin length]>0)
		//{
		//	dateString=[NSString stringWithFormat:@"%@ via Twitter",item.origin];
		//}
	}
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.date}}" withString:dateString];
	
	if(embedImageData && item.image)
	{
		NSLog(@"encoding image data...");
		
		NSData *imageData = UIImagePNGRepresentation(item.image);
		
		NSString * encoded=[Base64 encode:imageData];
		
		html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0 7px 0 0; float:left\" src=\"data:image/png;base64,%@\">",encoded]];
	}
	else 
	{
		if(item.imageUrl)
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0 7px 0 0; float:left\" width=\"48\" height=\"48\" src=\"%@\">",item.imageUrl]];
		}
		else 
		{
			// TODO: use default twitter profile image here...
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
		}
	}
	
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.screenname}}" withString:item.originUrl];
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.origin}}" withString:item.origin];
	
	/*if(includeSynopsis && [item.notes length]>0)
	 {
	 NSString * commentsSection=[self getTemplateSection:html sectionName:@"item.comments.section"];
	 
	 commentsSection=[commentsSection stringByReplacingOccurrencesOfStringIfExists:@"{{item.comments}}" withString:[item.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
	 
	 html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:commentsSection];
	 }
	 else
	 {
	 html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:@""];
	 }*/
	
	return html;
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
