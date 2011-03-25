//
//  NewsletterHTMLRenderer.m
//  Untitled
//
//  Created by Robert Stewart on 11/15/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterHTMLRenderer.h"
#import "Newsletter.h"
#import "NewsletterSection.h"
#import "NewsletterItem.h"
#import "Base64.h"
//#import "UIDeviceAdditions.h"


@implementation NewsletterHTMLRenderer
@synthesize templateName,pageWidth;

- (id) initWithTemplateName:(NSString*)templateName maxSynopsisSize:(int)maxSynopsisSize embedImageData:(BOOL)embedImageData
{
	if([super initWithMaxSynopsisSize:(int)maxSynopsisSize includeSynopsis:YES useOriginalSynopsis:NO embedImageData:embedImageData])
	{
		self.templateName=templateName;
	}
	return self;
}


- (NSString*) getHTML:(Newsletter*) newsletter
{
	return [self getHTMLPreview:newsletter maxItems:-1];
}
- (NSString*) getHTMLPreview:(Newsletter*) newsletter maxItems:(int)maxItems
{
	if(newsletter==nil) return @"";
	
	NSAutoreleasePool * htmlPool=[[NSAutoreleasePool alloc] init];
	
	self.newsletter=newsletter;
	
	NSString   *html = [self getTemplateContents:templateName];
	
	ItemHTMLRenderer * itemRenderer=[[[ItemHTMLRenderer alloc] initWithMaxSynopsisSize:self.maxSynopsisSize includeSynopsis:self.includeSynopsis useOriginalSynopsis:NO embedImageData:self.embedImageData] autorelease];

	itemRenderer.newsletter=newsletter;
	
	if(pageWidth==0)
	{
		pageWidth=700;
	}
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{pageWidth}}" withString:[NSString stringWithFormat:@"%d",pageWidth]];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{newsletter.name}}" withString:newsletter.name];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{newsletter.summary}}" withString:[newsletter.summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
	
	if(embedImageData)
	{
		if(newsletter.logoImage)
		{
			NSData *imageData = UIImagePNGRepresentation(newsletter.logoImage);
		
			NSString * encoded=[Base64 encode:imageData];
		
			html=[html stringByReplacingOccurrencesOfString:@"{{newsletter.logoImage}}" withString:[NSString stringWithFormat:@"<b><img src=\"data:image/png;base64,%@\"></b>",encoded]];
		}
		else 
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{newsletter.logoImage}}" withString:@""];
		}
	}
	else 
	{
		if(newsletter.logoImageUrl)
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{newsletter.logoImage}}" withString:[NSString stringWithFormat:@"<b><img src=\"%@\"></b>",newsletter.logoImageUrl]];
		}
		else 
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{newsletter.logoImage}}" withString:@""];
		}
	}
	 
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	
	[format setDateFormat:@"MMM d, yyyy"];
	
	html=[html stringByReplacingOccurrencesOfString:@"{{newsletter.lastUpdated}}" withString:[format stringFromDate:[NSDate date]]];
	
	[format release];
	
	NSString * sectionTemplate;
	
	NSArray * sortedSections=[newsletter sortedSections];
	
	NSMutableString * sections;
	
	sectionTemplate=[self getTemplateSection:html sectionName:@"newsletter.sections.left"];
	
	if(sectionTemplate!=nil)
	{
		sections=[[NSMutableString alloc] init];
		
		if(sortedSections && [sortedSections count]>0)
		{
			int i=0;
			for (NewsletterSection * section in sortedSections)
			{	
				NSString * tmp=[sectionTemplate stringByReplacingOccurrencesOfString:@"{{section.name}}" withString:section.name];
				
				tmp=[tmp stringByReplacingOccurrencesOfString:@"{{section.ordinal}}" withString:[NSString stringWithFormat:@"%d",i]];
				
				tmp=[tmp stringByReplacingOccurrencesOfStringIfExists:@"{{section.comments}}" withString:[section.summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
				
				i++;
				[sections appendString:tmp];
			}
		}
		
		html=[self replaceTemplateSection:html sectionName:@"newsletter.sections.left" withContent:sections];
		
		[sections release];
	}
	
	sectionTemplate=[self getTemplateSection:html sectionName:@"newsletter.sections.right"];
	
	sections=[[NSMutableString alloc] init];
	int itemCount=0;
		
	if(sortedSections && [sortedSections count]>0)
	{
		int i=0;
		
		for (NewsletterSection * section in sortedSections)
		{	
			NSAutoreleasePool * sectionPool=[[NSAutoreleasePool alloc] init];
			
			NSArray * sortedItems=[section sortedItems];
			
			if(sortedItems==nil || [sortedItems count]==0)
			{
				continue; // ignore empty sections
			}
			
			NSString * tmp=[sectionTemplate stringByReplacingOccurrencesOfString:@"{{section.name}}" withString:section.name];
			
			tmp=[tmp stringByReplacingOccurrencesOfString:@"{{section.ordinal}}" withString:[NSString stringWithFormat:@"%d",i]];
			
			tmp=[tmp stringByReplacingOccurrencesOfStringIfExists:@"{{section.comments}}" withString:[section.summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
			
			i++;
			
			NSMutableString * items=[[NSMutableString alloc] init];
			
			for(FeedItem * item in sortedItems)
			{
				NSAutoreleasePool * itemPool=[[NSAutoreleasePool alloc] init];
				
				NSString * itemHtml=[itemRenderer getItemHTML:item];
				
				if(itemHtml)
				{
					[items appendString:itemHtml];
					itemCount++;
				}
				
				[itemPool drain];
				
				if(maxItems>0)
				{
					if(itemCount>=maxItems)
					{
						break;
					}
				}
			}
			
			tmp=[self replaceTemplateSection:tmp sectionName:@"section.items" withContent:items];
			
			[sections appendString:tmp];
			
			[items release];
			
			[sectionPool drain];
			
			if(maxItems>0)
			{
				if(itemCount>=maxItems)
				{
					break;
				}
			}
		}
	}
	
	if(maxItems>0)
	{
		if(itemCount>=maxItems)
		{
			int totalCount=[newsletter itemCount];
			
			// show message to user that we limited the preview...
			NSString * message=[NSString stringWithFormat:@"Newsletter preview contains %d of %d total items.<br> Published newsletter will contain all items.",itemCount,totalCount];
		
			html=[html stringByReplacingOccurrencesOfStringIfExists:@"<!--preview.message-->" withString:message];
		}
	}
	
	html=[[self replaceTemplateSection:html sectionName:@"newsletter.sections.right" withContent:sections] retain];
	
	[sections release];
	
	[htmlPool drain];
	
	return [html autorelease];
}

- (void) dealloc
{
	[templateName release];
	[super dealloc];
}
@end
