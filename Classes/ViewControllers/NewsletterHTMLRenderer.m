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
	if(newsletter==nil) return @"";
	
	self.newsletter=newsletter;
	
	NSString   *html = [self getTemplateContents:templateName];
	
	ItemHTMLRenderer * itemRenderer=[[[ItemHTMLRenderer alloc] initWithMaxSynopsisSize:self.maxSynopsisSize includeSynopsis:self.includeSynopsis useOriginalSynopsis:NO embedImageData:self.embedImageData] autorelease];

	itemRenderer.newsletter=newsletter;
	
	if(pageWidth==0)
	{
		pageWidth=700;
	}
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{pageWidth}}" withString:[NSString stringWithFormat:@"%d",pageWidth]];
	
	// append newsletter header...
		
	//html=[self applyNewsletterStyles:newsletter toHtml:html];
	
	// replace styles in template...
	/*html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{titleFont}}" withString:newsletter.titleFont];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{titleColor}}" withString:newsletter.titleColor];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{commentsFont}}" withString:newsletter.commentsFont];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{commentsColor}}" withString:newsletter.commentsColor];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{sectionFont}}" withString:newsletter.sectionFont];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{sectionColor}}" withString:newsletter.sectionColor];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{headlineFont}}" withString:newsletter.headlineFont];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{headlineColor}}" withString:newsletter.headlineColor];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{bodyFont}}" withString:newsletter.bodyFont];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{bodyColor}}" withString:newsletter.bodyColor];
	*/
	
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
	
	if(sortedSections && [sortedSections count]>0)
	{
		int i=0;
		for (NewsletterSection * section in sortedSections)
		{	
			NSArray * sortedItems=[section sortedItems];
			
			if(sortedItems==nil || [sortedItems count]==0)
			{
				continue; // ignore empty sections
			}
			
			NSString * tmp=[sectionTemplate stringByReplacingOccurrencesOfString:@"{{section.name}}" withString:section.name];
			
			tmp=[tmp stringByReplacingOccurrencesOfString:@"{{section.ordinal}}" withString:[NSString stringWithFormat:@"%d",i]];
			
			tmp=[tmp stringByReplacingOccurrencesOfStringIfExists:@"{{section.comments}}" withString:[section.summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
			
			i++;
			
			//NSString * tmpTemplate=[self getTemplateSection:tmp sectionName:@"section.items"];
			
			NSMutableString * items=[[NSMutableString alloc] init];
			
			for(FeedItem * item in sortedItems)
			{
				NSString * itemHtml=[itemRenderer getItemHTML:item];
				
				if(itemHtml)
				{
					[items appendString:itemHtml];
				}
			}
			
			tmp=[self replaceTemplateSection:tmp sectionName:@"section.items" withContent:items];
			
			[sections appendString:tmp];
			
			[items release];
		}
	}
	
	html=[self replaceTemplateSection:html sectionName:@"newsletter.sections.right" withContent:sections];
	
	[sections release];
	
	return html;
}

- (void) dealloc
{
	[templateName release];
	[super dealloc];
}
@end
