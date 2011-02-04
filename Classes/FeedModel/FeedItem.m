//
//  SearchResult.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedItem.h"
#import "MarkupStripper.h"

@implementation NSString (InfoNgen_NSString)

- (NSString*) stringByReplacingOccurrencesOfStringIfExists:(NSString*)target withString:(NSString*)replacement
{
	NSRange range;
	if((range=[self rangeOfString:target]).location!=NSNotFound)
	{
		if(replacement)
		{
			return [self stringByReplacingOccurrencesOfString:target withString:replacement];
		}
		else 
		{
			return [self stringByReplacingOccurrencesOfString:target withString:@""];
		}
	}
	else 
	{
		return self;
	}
}

- (NSString *)flattenHTML 
{
	MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
	NSString * tmp=[stripper stripMarkup:self];
	return tmp;
	/*
	NSMutableString * tmp=[NSMutableString stringWithString:self];
	
	if(([tmp rangeOfString:@"<"]).location!=NSNotFound)
	{
		[tmp replaceOccurrencesOfString:@"<p>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"</p>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"<br />" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"</div>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"<ol>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"</ol>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"<ul>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"</ul>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"<li>" withString:@"* " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"</li>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		
		NSScanner *theScanner;
	
		NSString *text = nil;
	
		theScanner = [NSScanner scannerWithString:tmp];
		
		while ([theScanner isAtEnd] == NO) 
		{
			// find start of tag
			[theScanner scanUpToString:@"<" intoString:NULL] ; 
			if([theScanner isAtEnd]) break;
			
			// find end of tag         
			[theScanner scanUpToString:@">" intoString:&text] ;
			
			if([theScanner isAtEnd]) break;
			
			if(text)
			{
				[tmp replaceOccurrencesOfString:[ NSString stringWithFormat:@"%@>", text] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
			}
		}
	}
	
	if(([tmp rangeOfString:@"&"]).location!=NSNotFound)
	{
		[tmp replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&#39;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&#8217;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&#8220;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
		[tmp replaceOccurrencesOfString:@"&#8221;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
	}	
	
	while([tmp replaceOccurrencesOfString:@"  " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])]>0)
	{
		// compress double-whitespace...
	}
	while([tmp replaceOccurrencesOfString:@" \n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])]>0)
	{
		// compress whitespace before new line
	}
	while([tmp replaceOccurrencesOfString:@"\n\n\n" withString:@"\n\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])]>0)
	{
		// compress multiple new lines
	}
	
	return [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];*/
}




@end

@implementation FeedItem

@dynamic headline,url,uid,synopsis,origSynopsis,date,notes,image,imageUrl,origin,originId,originUrl,isRead,isStarred,isShared;//,metadata;

- (void) markAsRead
{
	NSLog(@"FeedItem.markAsRead");
	if(![self.isRead boolValue])
	{
		self.isRead=[NSNumber numberWithBool:YES];
		[self save];
	}
}

- (void) save
{
	NSLog(@"FeedItem.save");

	NSManagedObjectContext * moc=[self managedObjectContext];
	
	if(moc)
	{
		NSError * error=nil;
		if(![moc save:&error])
		{
			if(error)
			{
				NSLog(@"Error saving in FeedItem.save: %@",[error userInfo]);
			}
		}
	}
}

- (void) delete	
{
	[[self managedObjectContext] deleteObject:self];
}


- (NSString*) key
{
	return [NSString stringWithFormat:@"%@:%@",self.headline,self.url];
}

- (void) copyAttributes:(FeedItem*)item
{
	//NSLog(@"copyAttributes");
	
	//TODO: do we need to release/autorelease the copies here?  Not sure about copy memory semantics...
	self.headline=[[item.headline copy] autorelease];
	self.synopsis=[[item.synopsis copy] autorelease];
	self.origSynopsis=[[item.origSynopsis copy] autorelease];
	self.url=[[item.url copy] autorelease];
	self.date=[[item.date copy] autorelease];
	self.notes=[[item.notes copy] autorelease];
	self.image=[[item.image copy] autorelease];
	self.imageUrl=[[item.imageUrl copy] autorelease];
	self.origin=[[item.origin copy] autorelease];
	self.originId=[[item.originId copy] autorelease];
	self.originUrl=[[item.originUrl copy] autorelease];
	self.uid=[[item.uid copy] autorelease];
	self.isRead=[[item.isRead copy] autorelease];
	self.isStarred=[[item.isStarred copy] autorelease];
	self.isShared=[[item.isShared copy] autorelease];
	
	//self.isSelected=item.isSelected;
}

+ (NSString*) normalizeHeadline:(NSString*)s
{
	if(s==nil) return s;
	
	return [s flattenHTML];
	/*
	s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSRange range;
	
	while((range=[s rangeOfString:@"  "]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	}

	if((range=[s rangeOfString:@"&"]).location!=NSNotFound)
	{
	 	s=[s stringByReplacingOccurrencesOfStringIfExists:@"&lt;" withString:@"<"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&gt;" withString:@">"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&amp;" withString:@"&"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&nbsp;" withString:@" "];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&apos;" withString:@"'"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&quot;" withString:@"\""];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#39;" withString:@"'"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#8217;" withString:@"'"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#8220;" withString:@"\""];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#8221;" withString:@"\""];
	}
	
	return s;*/
}

 

+ (NSString*) normalizeSynopsis:(NSString*)s
{
	if(s==nil) return s;
	
	// TODO: if s is long unbroken string break it up (dont allow super long strings with no whitespace)
	
	/*s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSRange range;
	
	while((range=[s rangeOfString:@"  "]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	}
	
	if((range=[s rangeOfString:@"\n"]).location!=NSNotFound)
	{
		while((range=[s rangeOfString:@" \n"]).location!=NSNotFound)
		{
			s=[s stringByReplacingOccurrencesOfString:@" \n" withString:@"\n"];
		}
		
		while((range=[s rangeOfString:@"\n\n\n"]).location!=NSNotFound)
		{
			s=[s stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
		}
	}
	
	if((range=[s rangeOfString:@"<"]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"<b>" withString:@""];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"</b>" withString:@""];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"<p>" withString:@"\n"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"</p>" withString:@"\n"];
		
	}
	
	if((range=[s rangeOfString:@"&"]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&lt;" withString:@"<"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&gt;" withString:@">"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&amp;" withString:@"&"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&nbsp;" withString:@" "];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&apos;" withString:@"'"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&quot;" withString:@"\""];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#39;" withString:@"'"];
		
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#8217;" withString:@"'"];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#8220;" withString:@"\""];
		s=[s stringByReplacingOccurrencesOfStringIfExists:@"&#8221;" withString:@"\""];
		
	}
	
	s=[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	*/
	
	s=[s flattenHTML];
	
	unichar ellipsisChar = 0x2026;
	NSString *ellipsis = [NSString stringWithFormat:@"%C", ellipsisChar];
	
	if(!([s hasSuffix:@"."] || [s hasSuffix:@"[...]"] || [s hasSuffix:ellipsis]))
	{
		s=[s stringByAppendingString:@"..."];
	}
	else 
	{
		if([s hasSuffix:@". ..."])
		{
			s=[s substringToIndex:[s length]-4];
		}
		else {
			if ([s hasSuffix:[NSString stringWithFormat:@". %C",ellipsisChar]]) {
				s=[s substringToIndex:[s length]-2];
			}
		}
	}
	return s;
}

-(NSString *)relativeDateOffset 
{
    NSDate *todayDate = [NSDate date];
    double ti = [self.date timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 0) {
        return @"too small";
    } else      if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2592001) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"";//@"too big";
    }   
}

+ (NSString*) createUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString *)string autorelease];
}

- (NSString*) shortDisplayDate
{
	NSDate *todayDate = [NSDate date];
	NSCalendar * gregorian=[[NSCalendar alloc]
							initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents * today_components=[gregorian components:(NSDayCalendarUnit|NSWeekCalendarUnit) fromDate:todayDate];
	
	
	NSDateComponents * item_components=[gregorian components:(NSDayCalendarUnit|NSWeekCalendarUnit) fromDate:self.date];
	
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	//[format setTimeZone:[NSTimeZone localTimeZone]];
	NSString * display;
	
	if([today_components day] == [item_components day] &&
	    [today_components month] == [item_components month] &&
	   [today_components year] == [item_components year])
	{
		// return just time HH:MM AM|PM
		[format setDateFormat:@"h:mm a"];
		display = [format stringFromDate:self.date];
	}
	else 
	{
		// return just date Mmm dd
		[format setDateFormat:@"MMM d"];
		display = [format stringFromDate:self.date];
	}

	[format release];
	
	[gregorian release];
	
	return display;
}
@end
			
@implementation TempFeedItem
@synthesize headline,url,uid,synopsis,origSynopsis,date,notes,image,imageUrl,origin,originId,originUrl,isRead,isStarred,isShared;//,metadata;

- (void) save
{
}
- (void) delete
{
}

- (NSString*) key
{
	return [NSString stringWithFormat:@"%@:%@",self.headline,self.url];
}

- (id) init
{
	if([super init])
	{
		isRead=[[NSNumber alloc] initWithInt:0];
	}
	return self;
}

+ (TempFeedItem*) copyItem:(FeedItem*)item
{
	TempFeedItem * cp=[[TempFeedItem alloc] init];
	
	[cp copyAttributes:item];
	
	return [cp autorelease];
}

- (void) copyAttributes:(FeedItem*)item
{
	//NSLog(@"copyAttributes");
	
	//TODO: do we need to release/autorelease the copies here?  Not sure about copy memory semantics...
	self.headline=[[item.headline copy] autorelease];
	self.synopsis=[[item.synopsis copy] autorelease];
	self.origSynopsis=[[item.origSynopsis copy] autorelease];
	self.url=[[item.url copy] autorelease];
	self.date=[[item.date copy] autorelease];
	self.notes=[[item.notes copy] autorelease];
	self.image=[[item.image copy] autorelease];
	self.imageUrl=[[item.imageUrl copy] autorelease];
	self.origin=[[item.origin copy] autorelease];
	self.originId=[[item.originId copy] autorelease];
	self.originUrl=[[item.originUrl copy] autorelease];
	self.uid=[[item.uid copy] autorelease];
	self.isRead=[[item.isRead copy] autorelease];
	self.isStarred=[[item.isStarred copy] autorelease];
	self.isShared=[[item.isShared copy] autorelease];
	
	//self.isSelected=item.isSelected;
}




- (void) dealloc
{
	[headline release];
	[url release];
	[uid release];
	[synopsis release];
	[origSynopsis release];
	[date release];
	[notes release];
	[image release];
	[imageUrl release];
	[origin release];
	[originId release];
	[originUrl release];
	[isRead release];
	[isStarred release];
	[isShared release];
	[super dealloc];
}



@end
					  
@implementation ImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
  return YES;
}

+ (Class)transformedValueClass {
  return [NSData class];
}


- (id)transformedValue:(id)value {
  NSData *data = UIImagePNGRepresentation(value);
  return data;
}


- (id)reverseTransformedValue:(id)value {
  UIImage *uiImage = [[UIImage alloc] initWithData:value];
  return [uiImage autorelease];
}					  
					  
