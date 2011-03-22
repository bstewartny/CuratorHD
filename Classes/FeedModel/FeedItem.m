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
	MarkupStripper * stripper=[[MarkupStripper alloc] init];
	NSString * tmp=[stripper stripMarkup:self];
	[stripper release];
	return tmp;
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
	if([self.url length]>0)
	{
		return self.url;
	}
	else 
	{
		return self.headline;
	}
	// this is extra work, maybe just need URL if available, or headline if no url...
	//return [NSString stringWithFormat:@"%@:%@",self.headline,self.url];
}

- (void) copyAttributes:(FeedItem*)item
{
	//TODO: do we need to release/autorelease the copies here?  Not sure about copy memory semantics...
	// why do we need copy here? Cant we just set properties?  Not sure because this is managed object...
	/*self.headline=[[item.headline copy] autorelease];
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
	*/
	
	self.headline=item.headline;
	self.synopsis=item.synopsis;
	self.origSynopsis=item.origSynopsis;
	self.url=item.url;
	self.date=item.date;
	self.notes=item.notes;
	self.image=item.image;
	self.imageUrl=item.imageUrl;
	self.origin=item.origin;
	self.originId=item.originId;
	self.originUrl=item.originUrl;
	self.uid=item.uid;
	self.isRead=item.isRead;
	self.isStarred=item.isStarred;
	self.isShared=item.isShared;
	
	
}

+ (NSString*) normalizeHeadline:(NSString*)s
{
	if(s==nil) return s;
	
	return [s flattenHTML];
}

+ (NSString*) normalizeSynopsis:(NSString*)s
{
	if(s==nil) return s;
	
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
	if([self.url length]>0)
	{
		return self.url;
	}
	else 
	{
		return self.headline;
	}
	// this is extra work, maybe just need URL if available, or headline if no url...
	//return [NSString stringWithFormat:@"%@:%@",self.headline,self.url];
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
	//TODO: do we need to release/autorelease the copies here?  Not sure about copy memory semantics...
	/*self.headline=[[item.headline copy] autorelease];
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
	*/
	
	self.headline=item.headline;
	self.synopsis=item.synopsis;
	self.origSynopsis=item.origSynopsis;
	self.url=item.url;
	self.date=item.date;
	self.notes=item.notes;
	self.image=item.image;
	self.imageUrl=item.imageUrl;
	self.origin=item.origin;
	self.originId=item.originId;
	self.originUrl=item.originUrl;
	self.uid=item.uid;
	self.isRead=item.isRead;
	self.isStarred=item.isStarred;
	self.isShared=item.isShared;
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
					  
