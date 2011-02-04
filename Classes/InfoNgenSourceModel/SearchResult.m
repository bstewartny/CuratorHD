//
//  SearchResult.m
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchResult.h"
#import "MetaTag.h"

@implementation SearchResult
@synthesize headline,url,synopsis,date,notes,image,imageUrl;//,metadata;

- (id) init
{
	return [self initWithHeadline:@"Unknown" withUrl:@"http://noplace.com" withSynopsis:nil withDate:[[NSDate alloc] init]];
}

- (id) initWithHeadline:(NSString *)theHeadline withUrl:(NSString *) theUrl withSynopsis:(NSString*)theSynopsis withDate:(NSDate*)theDate
{
	if(![super init])
	{
		return nil;
	}
	
	self.headline=theHeadline;
	self.synopsis=theSynopsis;
	self.url=theUrl;
	self.date=theDate;
	//self.itemSize=nil;
	
	//self.metadata=[[NSMutableArray alloc] init];
	
	
	return self;
}


+ (NSString*) normalizeHeadline:(NSString*)s
{
	if(s==nil) return s;
	
	s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSRange range;
	
	while((range=[s rangeOfString:@"  "]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	}
	
	if((range=[s rangeOfString:@"<"]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
		s=[s stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
	}
	
	if((range=[s rangeOfString:@"&"]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
		s=[s stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
		s=[s stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		s=[s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		s=[s stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
	}
	
	return s;
}

+ (NSString*) normalizeSynopsis:(NSString*)s
{
	if(s==nil) return s;
	
	
	s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
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
		s=[s stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
		s=[s stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
	}
	
	if((range=[s rangeOfString:@"&"]).location!=NSNotFound)
	{
		s=[s stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
		s=[s stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
		s=[s stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		s=[s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		s=[s stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
	}
	
	
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
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"too big";
    }   
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:headline forKey:@"headline"];
	[encoder encodeObject:synopsis forKey:@"synopsis"];
	[encoder encodeObject:url forKey:@"url"];
	[encoder encodeObject:date forKey:@"date"];	
	[encoder encodeObject:image forKey:@"image"];
	[encoder encodeObject:notes	forKey:@"notes"];
	[encoder encodeObject:imageUrl forKey:@"imageUrl"];
	//[encoder encodeObject:metadata forKey:@"metadata"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.headline=[decoder decodeObjectForKey:@"headline"];
		self.synopsis=[decoder decodeObjectForKey:@"synopsis"];
		self.url=[decoder decodeObjectForKey:@"url"];
		self.date=[decoder decodeObjectForKey:@"date"];
		self.image=[decoder decodeObjectForKey:@"image"];
		self.notes=[decoder decodeObjectForKey:@"notes"];
		self.imageUrl=[decoder decodeObjectForKey:@"imageUrl"];
		
		//self.metadata=[decoder decodeObjectForKey:@"metadata"];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	SearchResult * copy=[[[self class] allocWithZone:zone] init];
	copy.headline=[self.headline copy];
	copy.synopsis=[self.synopsis copy];
	copy.url=[self.url copy];
	copy.date=[self.date copy];
	copy.notes=[self.notes copy];
	copy.image=[self.image copy];
	copy.imageUrl=[self.imageUrl copy];
	
	//copy.metadata=[self.metadata copy];
	
	return copy;
}

- (void) setImage:(UIImage *)newImage
{
	if(imageUrl!=nil)
	{
		[imageUrl release];
		imageUrl=nil;
	}
	if(image!=nil)
	{
		[image release];
	}
	[newImage retain];
	image=newImage;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"%@",headline];
}

/*- (BOOL) hasMetaTag:(NSString*)fieldName withValue:(NSString*)fieldValue
{
	for(MetaTag * tag in metadata)
	{
		if([tag.fieldName isEqualToString:fieldName] && [tag.fieldValue isEqualToString:fieldValue])
		{
			return YES;
		}
	}
	return NO;
}*/


- (void)dealloc {
	[headline release];
	[synopsis release];
	[url release];
	[date release];
	[notes release];
	[image release];
	[imageUrl release];
	//[metadata release];
	
	[super dealloc];
}
@end
