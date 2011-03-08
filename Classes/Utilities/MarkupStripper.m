#import "MarkupStripper.h"

@implementation MarkupStripper

- (id) init
{
	if(self=[super init])
	{
	// note we dont include last characters in these keys because they way scanner is working below...
	tags=[[NSDictionary dictionaryWithObjectsAndKeys:
		  @"",@"",
		  @"\n",@"<p",
		  @"\n",@"</p",
		  @"\n",@"<br",
		  @"\n",@"<br /",
		  @"\n",@"<br/",
		  @"\n",@"</div",
		  @"\n",@"<ol",
		  @"\n",@"</ol",
		  @"\n",@"<ul",
		  @"\n",@"</ul",
		  @"*",@"<li",
		  @"\n",@"</li",
		   nil] retain];
	
	codes=[[NSDictionary dictionaryWithObjectsAndKeys:
		   @"<",@"&lt",
		   @">",@"&gt",
		   @"&",@"&amp",
		   @" ",@"&nbsp",
		   @"'",@"&apos",
		   @"\"",@"&quot",
		   @"'",@"&#39",
		   @"'",@"&#8217",
		   @"\"",@"&#8220",
		   @"\"",@"&#8220",
			nil] retain];
	}
	return self;
}

- (void) dealloc
{
	[tags release];
	[codes release];
	[super dealloc];
}

- (void) replaceTags:(NSMutableString*)s startChar:(NSString*)startChar endChar:(NSString*)endChar replacements:(NSDictionary*)replacements
{
	NSScanner *theScanner;
	
	NSString *text = nil;
	
	theScanner = [NSScanner scannerWithString:s];
	
	// strip HTML tags
	while ([theScanner isAtEnd] == NO) 
	{
		// find start of tag
		[theScanner scanUpToString:startChar intoString:NULL] ; 
		if([theScanner isAtEnd]) break;
		
		[theScanner scanUpToString:endChar intoString:&text] ;
		if([theScanner isAtEnd]) break;
		
		if(text)
		{
			NSString * replacement=[replacements objectForKey:text];
			
			if(replacement==nil)
			{
				replacement=@"";
				
			}
			[s replaceOccurrencesOfString:[NSString stringWithFormat:@"%@%@",text,endChar] withString:replacement options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
		}
	}
}

- (NSString*) stripMarkupSummary:(NSString*)s maxLength:(int)maxLength
{
	if([s length]<=maxLength)
	{
		return [self stripMarkup:s];
	}
	else 
	{
		NSString * m;
		
		if([s length] > (maxLength * 2))
		{
			m=[self stripMarkup:[s substringToIndex:(maxLength*2)]];
		}
		else 
		{
			m=[self stripMarkup:s];
		}
		
		if([m length]>maxLength)
		{
			return [m substringToIndex:maxLength];
		}
		else 
		{
			return m;
		}
	}
}

- (NSString*) stripMarkup:(NSString*)s
{
	if([s length]==0) return s;
	
	NSMutableString * tmp=[NSMutableString stringWithString:s];
	
	[self replaceTags:tmp startChar:@"<" endChar:@">" replacements:tags];
	
	[self replaceTags:tmp startChar:@"&" endChar:@";" replacements:codes];
	
	while([tmp replaceOccurrencesOfString:@"  " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])]>0)
	{
		
	}
	while([tmp replaceOccurrencesOfString:@" \n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])]>0)
	{
		
	}
	while([tmp replaceOccurrencesOfString:@"\n\n\n" withString:@"\n\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])]>0)
	{
		
	}
	
	return [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
