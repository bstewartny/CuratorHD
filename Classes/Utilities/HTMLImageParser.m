//
//  HTMLImageParser.m
//  Untitled
//
//  Created by Robert Stewart on 6/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "HTMLImageParser.h"


@implementation HTMLImageParser


+ (NSArray*) getImageUrlsFromUrl:(NSString*)url
{
	// get data from url as string of html

	NSString * html=[HTMLImageParser getString:url];
	
	if(html)
	{
		// parse for images...
		return [HTMLImageParser getImageUrls:html];
	}
	else 
	{
		return nil;
	}
}

+ (NSData*) getData:(NSString*)url
{
	//NSLog(url);
	
	@try 
	{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		
		NSHTTPURLResponse * response=NULL;
		
		NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
		
		return data;
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception in getData for url: %@: %@",url,[e description]);
		return nil;	
	}
	@finally 
	{
	}
}

+ (NSString*) getString:(NSString*)url
{
	@try {
		NSData * data=[self getData:url];	
		
		if(data)
		{
			return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		}
		else 
		{
			return nil;
		}
	}
	@catch (NSException * e) {
		NSLog(@"Exception in getJson for getString: %@: %@",url,[e description]);
		return nil;
	}
	@finally 
	{
	}
}
+ (NSArray*) getImageUrls:(NSString*)html
{
	NSMutableArray * tmp=[[[NSMutableArray alloc] init] autorelease];
	
	if(([html rangeOfString:@"<img "]).location!=NSNotFound)
	{
		NSScanner * imgScanner=[NSScanner scannerWithString:html];
		
		while ([imgScanner isAtEnd] == NO) 
		{
			NSString * img=nil;
			// find start of tag
			[imgScanner scanUpToString:@"<img " intoString:NULL] ;                 
			
			// find end of tag         
			[imgScanner scanUpToString:@">" intoString:&img] ;
			
			if(img!=nil)
			{
				//NSLog(@"Found img:%@",img);
				
				NSString * src=nil;
			
				NSScanner *srcScanner=[NSScanner scannerWithString:img];
				[srcScanner scanUpToString:@"src=\"" intoString:NULL] ;  
				
				if(![srcScanner isAtEnd])
				{
					//NSLog(@"scanLocation=%d",[srcScanner scanLocation]);
					[srcScanner setScanLocation:([srcScanner scanLocation]+5)];
					[srcScanner scanUpToString:@"\"" intoString:&src] ;                 
				}
				if(src!=nil)
				{
					//NSLog(@"Found src:%@",src);
					[tmp addObject:src];
				}
			}
		}
	}
	return tmp;

}
@end
