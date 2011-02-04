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
