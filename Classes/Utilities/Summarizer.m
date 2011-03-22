//
//  Summarizer.m
//  Untitled
//
//  Created by Robert Stewart on 5/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "Summarizer.h"

@implementation TextSegment
@synthesize text,weight;

- (id) initWithText:(NSString*)s
{
	if([super init])
	{
		self.text=s;
		self.weight=0;
	}
	return self;
}

- (void) dealloc
{
	[text release];
	[super dealloc];
}
	

@end

@implementation Summarizer

+ (NSString*) shortenToMaxWords:(int)maxWords text:(NSString*)text 
{
	
	if([text length]==0) return text;
	
	if(maxWords==0) return nil;
	
	@try 
	{
		CFStringRef string=text;
		
		CFLocaleRef locale = CFLocaleCopyCurrent();
		
		CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, CFRangeMake(0, CFStringGetLength(string)), kCFStringTokenizerUnitWord, locale);
		
		CFStringTokenizerTokenType tokenType = kCFStringTokenizerTokenNone;
		
		unsigned tokensFound = 0, desiredTokens = maxWords; 
		
		long index=0;
		
		while(kCFStringTokenizerTokenNone != (tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)) && tokensFound < desiredTokens) 
		{
			CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
			
			index=tokenRange.location+tokenRange.length;
			
			++tokensFound;
		}
		
		// Clean up
		CFRelease(tokenizer);
		CFRelease(locale);
		
		if(tokensFound>=maxWords)
		{
			if(index>0)
			{
				NSString * shortened=[text substringToIndex:index];
				
				shortened=[shortened stringByTrimmingCharactersInSet:
									 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
						   
				if([shortened length]>0)
				{
				   if(![shortened hasSuffix:@"."])
				   {
					   shortened=[NSString stringWithFormat:@"%@...",shortened];
				   }
				}
				
				return shortened;
			}
		}
	}
	@catch (NSException * e) 
	{
		
	}
	@finally 
	{
		
	}
	
	return text;
}

- (NSString*) summarizeBody:(NSString*)body withHeadline:(NSString*)headline
{
	NSArray * keyWords=[[headline lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	return [self summarizeText:body keyWords:keyWords];
}


- (NSString*) summarizeText:(NSString*)text keyWords:(NSArray*)keyWords
{
	
	NSMutableArray * tmp=[[[NSMutableArray alloc] init] autorelease];
	
	// get lines and/or paragraphs...
	NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	for(NSString * line in lines)
	{
		NSLog(line);
		
		TextSegment * segment=[[TextSegment alloc] initWithText:line];
		
		CGFloat match_count=0;
		
		NSString * lowerCaseLine=[line lowercaseString];
		
		NSArray * words=[lowerCaseLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		CGFloat numWords=[words count];
		 
		for(NSString * word in words)
		{
			for(NSString * keyWord in keyWords)
			{
				if([word isEqualToString:keyWord])
				{
					NSLog(@"Found keyword match: %@",word);
					match_count+=1.0;
				}
			}
		}
		
		if(numWords>3)
		{
			segment.weight=match_count / numWords;
		}
		
		NSLog(@"Segment.weight=%f",segment.weight);
		
		[tmp addObject:segment];
		
		[segment release];
	}
	
	// sort by weight
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weight" ascending:NO];
	
	[tmp sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[sortDescriptor release];
	
	if ([tmp count]>1)
	{
		// take top 2...
		NSMutableString * result=[[[NSMutableString alloc] init] autorelease];
		[result appendString:[[tmp objectAtIndex:0] text]];
		[result appendFormat:@"%@\n\n",[[tmp objectAtIndex:1] text]];

		return result;
	}
	else 
	{
		if([tmp count]>0)
		{
			return [[tmp objectAtIndex:0] text];
		}
		else 
		{
			return text;
		}
	}
}
@end
