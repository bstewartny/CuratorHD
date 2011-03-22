//
//  ItemHTMLRenderer.m
//  Untitled
//
//  Created by Robert Stewart on 11/15/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ItemHTMLRenderer.h"
#import "FeedItem.h"
#import "Base64.h"
#import "Newsletter.h"
#import "Font.h"

@implementation ItemHTMLRenderer
@synthesize embedImageData,newsletter,includeSynopsis,maxSynopsisSize,useOriginalSynopsis;

- (NSString*) applyDefaultStyles:(NSString*)html
{
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{titleStyle}}" withString:@"font-family:Arial; font-style:bold; font-weight:normal; font-size:x-large; color:black; "];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{summaryStyle}}" withString:@"font-family:Georgia; font-style:normal; font-weight:normal; font-size:medium; color:grey; "];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{headlineStyle}}" withString:@"font-family:Arial; font-style:bold; font-weight:normal; font-size:x-large; color:black; "];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{sectionStyle}}" withString:@"font-family:Arial; font-style:bold; font-weight:normal; font-size:large; color:black; "];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{commentsStyle}}" withString:@"font-family:Arial; font-style:bold; font-weight:italic; font-size:medium; color:red; "];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{bodyStyle}}" withString:@"font-family:Arial; font-style:normal; font-weight:normal; font-size:normal; color:black; "];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{dateStyle}}" withString:@"font-family:Arial; font-style:normal; font-weight:normal; font-size:medium; color:grey; "];
	
	return html;
}

- (NSString*) applyNewsletterStyles:(Newsletter*)newsletter toHtml:(NSString*)html
{
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{titleStyle}}" withString:[newsletter.titleFont cssStyle]];
																						 
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{summaryStyle}}" withString:[newsletter.summaryFont cssStyle]];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{headlineStyle}}" withString:[newsletter.headlineFont cssStyle]];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{sectionStyle}}" withString:[newsletter.sectionFont cssStyle]];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{commentsStyle}}" withString:[newsletter.commentsFont cssStyle]];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{bodyStyle}}" withString:[newsletter.bodyFont cssStyle]];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{dateStyle}}" withString:[newsletter.dateFont cssStyle]];
	
	return html;
}
/*
- (NSString*) getStyleForFontFamily:(NSString*)fontFamily fontSize:(NSString*)fontSize fontColor:(NSString*)fontColor
{
	if([fontFamily length]==0)
	{
		fontFamily=@"sans-serif";
	}
	if([fontSize length]==0)
	{
		fontSize=@"16pt";
	}
	if([fontColor length]==0)
	{
		fontColor=@"#000000";
	}
	NSString * style=[NSString stringWithFormat:@"font-family:'%@'; font-size:%@; color:%@;",fontFamily,fontSize,fontColor];
	return style;
}
*/
- (void) dealloc
{
	[newsletter release];
	newsletter=nil;
	[format release];
	[super dealloc];
}
- (id)initWithMaxSynopsisSize:(int)maxSynopsisSize includeSynopsis:(BOOL)includeSynopsis useOriginalSynopsis:(BOOL)useOriginalSynopsis embedImageData:(BOOL)embedImageData
{
	if([super init])
	{
		self.maxSynopsisSize=maxSynopsisSize;
		self.includeSynopsis=includeSynopsis;
		self.embedImageData=embedImageData;
		self.useOriginalSynopsis=useOriginalSynopsis;
		
		format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"MMM d, yyyy h:mm a"];

		
		
	}
	return self;
}

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
	if([item.originId isEqualToString:@"facebook.status"])
	{
		return [self getFacebookStatusHTML:item];
	}
	if([item.originId isEqualToString:@"facebook.photo"])
	{
		return [self getFacebookPhotoHTML:item];
	}	
	return [self getDefaultItemHTML:item];
}

- (NSString*) getTwitterItemHTMLOld:(FeedItem*)item
{
	NSLog(@"getTwitterItemHTML");
	
	if(item==nil) return @"";
	
	NSString   *html = [self getTemplateContents:@"TwitterItem"];
	
	NSString * userlink=[NSString stringWithFormat:@"<a style=\"text-decoration:none\" href=\"http://twitter.com/%@\">%@</a>",item.originUrl,item.originUrl];
	
	NSString * tweet=[NSString stringWithFormat:@"%@ %@",userlink,item.origSynopsis];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:tweet];
	
	NSString * dateString=nil;
	
	if(item.date)
	{
		dateString=[self formatDate:item.date];
		
		if(item.origin && [item.origin length]>0)
		{
			dateString=[dateString stringByAppendingFormat:@" - %@ via Twitter",item.origin];
		}
	}
	else 
	{
		if(item.origin && [item.origin length]>0)
		{
			dateString=[NSString stringWithFormat:@"%@ via Twitter",item.origin];
		}
	}
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.date}}" withString:dateString];
	
	if(embedImageData && item.image)
	{
		NSLog(@"encoding image data...");
		
		NSData *imageData = UIImagePNGRepresentation(item.image);
			
		NSString * encoded=[Base64 encode:imageData];
		
		html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0\" src=\"data:image/png;base64,%@\">",encoded]];
	}
	else 
	{
		if(item.imageUrl)
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0\" width=\"48\" height=\"48\" src=\"%@\">",item.imageUrl]];
		}
		else 
		{
			// TODO: use default twitter profile image here...
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
		}
	}
	
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.screenname}}" withString:item.originUrl];
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.origin}}" withString:item.origin];
	
	if(includeSynopsis && [item.notes length]>0)
	{
		NSString * commentsSection=[self getTemplateSection:html sectionName:@"item.comments.section"];
		
		commentsSection=[commentsSection stringByReplacingOccurrencesOfStringIfExists:@"{{item.comments}}" withString:[item.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
		
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:commentsSection];
	}
	else
	{
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:@""];
	}
	
	return html;
}

- (NSString*) getTwitterItemHTML:(FeedItem*)item
{
	NSLog(@"getTwitterItemHTML");
	
	if(item==nil) return @"";
	
	NSString   *html = [self getTemplateContents:@"DefaultItem"];
	
	//NSString * userlink=[NSString stringWithFormat:@"<a style=\"text-decoration:none\" href=\"http://twitter.com/%@\">%@</a>",item.originUrl,item.originUrl];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:item.originUrl];
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.url}}" withString:[NSString stringWithFormat:@"http://twitter.com/%@",item.originUrl]];
	
	//NSString * tweet=[NSString stringWithFormat:@"%@ %@",userlink,item.origSynopsis];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.synopsis}}" withString:item.origSynopsis];
	
	NSString * dateString=nil;
	
	if(item.date)
	{
		dateString=[self formatDate:item.date];
		
		if(item.origin && [item.origin length]>0)
		{
			dateString=[dateString stringByAppendingFormat:@" - %@ via Twitter",item.origin];
		}
	}
	else 
	{
		if(item.origin && [item.origin length]>0)
		{
			dateString=[NSString stringWithFormat:@"%@ via Twitter",item.origin];
		}
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
	
	if(includeSynopsis && [item.notes length]>0)
	{
		NSString * commentsSection=[self getTemplateSection:html sectionName:@"item.comments.section"];
		
		commentsSection=[commentsSection stringByReplacingOccurrencesOfStringIfExists:@"{{item.comments}}" withString:[item.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
		
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:commentsSection];
	}
	else
	{
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:@""];
	}
	
	return html;
}


- (NSString*) getNoteItemHTML:(FeedItem*)item
{
	if(item==nil) return @"";
	
	NSString   *html = [self getTemplateContents:@"NoteItem"];
	
	if([item.headline length]>0)
	{
		html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:item.headline];
	}
	else 
	{
		html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:@"[Note]"];
	}

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
	
	if(includeSynopsis)
	{
		NSString * synopsis=[item.synopsis stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"];
			
		if(maxSynopsisSize>0)
		{
			// limit synopsis length...
			if([synopsis length]>maxSynopsisSize)
			{
				synopsis=[[synopsis substringToIndex:maxSynopsisSize] stringByAppendingString:@"..."];
			}
		}
		
		html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.synopsis}}" withString:synopsis];
	}
	else
	{
		html=[html stringByReplacingOccurrencesOfString:@"{{item.synopsis}}" withString:@""];
	}
	
	if(includeSynopsis && [item.notes length]>0)
	{
		NSString * commentsSection=[self getTemplateSection:html sectionName:@"item.comments.section"];
		
		commentsSection=[commentsSection stringByReplacingOccurrencesOfStringIfExists:@"{{item.comments}}" withString:[item.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
		
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:commentsSection];
	}
	else
	{
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:@""];
	}
	
	if(includeSynopsis)
	{
		// only include images if NOT using original synopsis
		if(!useOriginalSynopsis)
		{
			if(item.image)
			{
				if(embedImageData)
				{
					NSData *imageData = UIImagePNGRepresentation(item.image);
					
					NSString * encoded=[Base64 encode:imageData];
					
					html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<b><img style=\"float:left;margin-right:4px\" src=\"data:image/png;base64,%@\"></b>",encoded]];
				}
				else 
				{
					if(item.imageUrl)
					{
						html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<b><img style=\"float:left;margin-right:4px\" src=\"%@\"></b>",item.imageUrl]];
					}
					else 
					{
						html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
					}
				}
			}
			else 
			{
				html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
			}
		}
		else 
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
		}
	}
	else 
	{
		html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
	}
	
	return html;
	
}

- (NSString*) getFacebookStatusHTML:(FeedItem*)item
{
	if(item==nil) return @"";
	
	NSString   *html = [self getTemplateContents:@"FacebookStatusItem"];
	
	//NSString * userlink=[NSString stringWithFormat:@"<a style=\"text-decoration:none\" href=\"http://twitter.com/%@\">%@</a>",item.originUrl,item.originUrl];
	
	//NSString * tweet=[NSString stringWithFormat:@"%@ %@",userlink,item.origSynopsis];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:item.origSynopsis];
	
	NSString * dateString=nil;
	
	if(item.date)
	{
		dateString=[self formatDate:item.date];
		
		if(item.origin && [item.origin length]>0)
		{
			dateString=[dateString stringByAppendingFormat:@" - %@ via Facebook",item.origin];
		}
	}
	else 
	{
		if(item.origin && [item.origin length]>0)
		{
			dateString=[NSString stringWithFormat:@"%@ via Facebook",item.origin];
		}
	}
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.date}}" withString:dateString];
	
	if(embedImageData && item.image)
	{
		NSData *imageData = UIImagePNGRepresentation(item.image);
		
		NSString * encoded=[Base64 encode:imageData];
		
		html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0\" src=\"data:image/png;base64,%@\">",encoded]];
	}
	else 
	{
		if(item.imageUrl)
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0\" width=\"48\" height=\"48\" src=\"%@\">",item.imageUrl]];
		}
		else 
		{
			// TODO: use default twitter profile image here...
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
		}
	}
	
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.screenname}}" withString:item.originUrl];
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.origin}}" withString:item.origin];
	
	if(includeSynopsis && [item.notes length]>0)
	{
		NSString * commentsSection=[self getTemplateSection:html sectionName:@"item.comments.section"];
		
		commentsSection=[commentsSection stringByReplacingOccurrencesOfStringIfExists:@"{{item.comments}}" withString:[item.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
		
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:commentsSection];
	}
	else
	{
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:@""];
	}
	
	return html;
}
- (NSString*) getFacebookPhotoHTML:(FeedItem*)item
{
	if(item==nil) return @"";
	
	NSString   *html = [self getTemplateContents:@"FacebookPhotoItem"];
	
	//NSString * userlink=[NSString stringWithFormat:@"<a style=\"text-decoration:none\" href=\"http://twitter.com/%@\">%@</a>",item.originUrl,item.originUrl];
	
	//NSString * tweet=[NSString stringWithFormat:@"%@ %@",userlink,item.origSynopsis];
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.headline}}" withString:item.headline];
	
	NSString * dateString=nil;
	
	if(item.date)
	{
		dateString=[self formatDate:item.date];
		
		if(item.origin && [item.origin length]>0)
		{
			dateString=[dateString stringByAppendingFormat:@" - %@ via Facebook",item.origin];
		}
	}
	else 
	{
		if(item.origin && [item.origin length]>0)
		{
			dateString=[NSString stringWithFormat:@"%@ via Facebook",item.origin];
		}
	}
	
	html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.date}}" withString:dateString];
	
	if(embedImageData && item.image)
	{
		NSData *imageData = UIImagePNGRepresentation(item.image);
		
		NSString * encoded=[Base64 encode:imageData];
		
		html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0\" src=\"data:image/png;base64,%@\">",encoded]];
	}
	else 
	{
		if(item.imageUrl)
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<img style=\"margin:0\" src=\"%@\">",item.imageUrl]];
		}
		else 
		{
			// TODO: use default twitter profile image here...
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
		}
	}
	
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.screenname}}" withString:item.originUrl];
	//html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.origin}}" withString:item.origin];
	
	if(includeSynopsis && [item.notes length]>0)
	{
		NSString * commentsSection=[self getTemplateSection:html sectionName:@"item.comments.section"];
		
		commentsSection=[commentsSection stringByReplacingOccurrencesOfStringIfExists:@"{{item.comments}}" withString:[item.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
		
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:commentsSection];
	}
	else
	{
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:@""];
	}
	
	return html;
}
- (NSString*) formatDate:(NSDate*)date
{
	//NSDateFormatter *format = [[NSDateFormatter alloc] init];
	//[format setDateFormat:@"MMM d, yyyy h:mm a"];
	NSString * dateString=[format stringFromDate:date];
	//[format release];
	return dateString;
}

- (NSString*) getTemplateContents:(NSString*)templateName
{
	NSString * html= [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource:templateName ofType:@"html"] 
							  encoding: NSUTF8StringEncoding 
								 error: nil];
	// replace styles...
	if(newsletter)
	{
		html=[self applyNewsletterStyles:newsletter toHtml:html];
	}
	else 
	{
		html=[self applyDefaultStyles:html];	
		
	}

	
	return html;
	
}

- (NSString*) getDefaultItemHTML:(FeedItem*)item
{
	if(item==nil) return @"";
	
	NSString   *html = [self getTemplateContents:@"DefaultItem"];
	
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
	
	if(includeSynopsis)
	{
		NSString * synopsis;
		
		if(useOriginalSynopsis)
		{
			synopsis=item.origSynopsis;
		}
		else 
		{
			//synopsis=item.synopsis;
		
			synopsis=[item.synopsis stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"];
			
		}

		if(maxSynopsisSize>0)
		{
			// when limiting synopsis size, never use original synopsis...
			if(useOriginalSynopsis)
			{
				synopsis=item.synopsis;
			}
			
			// limit synopsis length...
			if([synopsis length]>maxSynopsisSize)
			{
				synopsis=[[synopsis substringToIndex:maxSynopsisSize] stringByAppendingString:@"..."];
			}
		}
		
		html=[html stringByReplacingOccurrencesOfStringIfExists:@"{{item.synopsis}}" withString:synopsis];
	}
	else
	{
		html=[html stringByReplacingOccurrencesOfString:@"{{item.synopsis}}" withString:@""];
	}
	
	if(includeSynopsis && [item.notes length]>0)
	{
		NSString * commentsSection=[self getTemplateSection:html sectionName:@"item.comments.section"];
		
		commentsSection=[commentsSection stringByReplacingOccurrencesOfStringIfExists:@"{{item.comments}}" withString:[item.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR />"]];
		
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:commentsSection];
	}
	else
	{
		html=[self replaceTemplateSection:html sectionName:@"item.comments.section" withContent:@""];
	}
	
	if(includeSynopsis)
	{
		// only include images if NOT using original synopsis
		if(!useOriginalSynopsis)
		{
			if(item.image)
			{
				if(embedImageData)
				{
					NSData *imageData = UIImagePNGRepresentation(item.image);
					
					NSString * encoded=[Base64 encode:imageData];
					
					html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<b><img style=\"float:left;margin-right:4px\" src=\"data:image/png;base64,%@\"></b>",encoded]];
				}
				else 
				{
					if(item.imageUrl)
					{
						html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:[NSString stringWithFormat:@"<b><img style=\"float:left;margin-right:4px\" src=\"%@\"></b>",item.imageUrl]];
					}
					else 
					{
						html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
					}
				}
			}
			else 
			{
				html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
			}
		}
		else 
		{
			html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
		}
	}
	else 
	{
		html=[html stringByReplacingOccurrencesOfString:@"{{item.image}}" withString:@""];
	}
	
	return html;
}

- (NSString*) getTemplateSection:(NSString*)template  sectionName:(NSString*)sectionName
{
	NSString * startTag=[NSString stringWithFormat:@"{{%@}}",sectionName];
	NSString * endTag=[NSString stringWithFormat:@"{{/%@}}",sectionName];
	
	NSRange start=[template rangeOfString:startTag];
	
	if(start.location==NSNotFound) return nil;
	
	NSRange end=[template rangeOfString:endTag];
	
	NSRange range=NSMakeRange(start.location+start.length, (end.location-(start.location+start.length)));
	
	return [template substringWithRange:range];
}

- (NSString*) replaceTemplateSection:(NSString*)template sectionName:(NSString*)sectionName withContent:(NSString*)newContent
{
	NSString * startTag=[NSString stringWithFormat:@"{{%@}}",sectionName];
	NSString * endTag=[NSString stringWithFormat:@"{{/%@}}",sectionName];
	
	NSRange start=[template rangeOfString:startTag];
	
	if(start.location==NSNotFound) return template;
	
	NSRange end=[template rangeOfString:endTag];
	
	return [template stringByReplacingCharactersInRange:NSMakeRange(start.location, (end.location+end.length - (start.location))) withString:newContent];
}

@end
