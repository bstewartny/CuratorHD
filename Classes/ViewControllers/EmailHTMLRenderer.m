//
//  EmailHTMLRenderer.m
//  Untitled
//
//  Created by Robert Stewart on 11/15/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "EmailHTMLRenderer.h"
#import "FeedItem.h"

@implementation EmailHTMLRenderer

- (NSString*) getHTML:(NSArray*)items
{
	
	NSString   *html = [self getTemplateContents:@"EmailDocument"];
	
	ItemHTMLRenderer * itemRenderer=[[ItemHTMLRenderer alloc] initWithMaxSynopsisSize:self.maxSynopsisSize includeSynopsis:self.includeSynopsis useOriginalSynopsis:self.useOriginalSynopsis embedImageData:self.embedImageData];
	
	NSString * itemsHtml=@"";
	
	for(FeedItem * item in items)
	{
		NSString * itemHtml=[itemRenderer getItemHTML:item];
		
		if(itemHtml)
		{
			itemsHtml=[itemsHtml stringByAppendingString:itemHtml];
		}
	}
	
	html=[self replaceTemplateSection:html sectionName:@"items" withContent:itemsHtml];
	
	[itemRenderer release];
	return html;
}

@end
