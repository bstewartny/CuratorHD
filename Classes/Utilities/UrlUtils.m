//
//  UrlUtils.m
//  Untitled
//
//  Created by Robert Stewart on 8/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "UrlUtils.h"


@implementation UrlUtils

+ (NSString*) hostFromUrl:(NSString*)url
{
	if(url==nil || [url length]==0)
	{
		return nil;
	}
	
	@try 
	{
		NSString * host=[[NSURL URLWithString:url] host];
		
		if(host && [host length]>0)
		{
			if([host hasPrefix:@"http://"])
			{
				host=[host substringFromIndex:7];
			}
			if([host hasPrefix:@"https://"])
			{
				host=[host substringFromIndex:8];
			}
			if([host hasPrefix:@"www."] || [host hasPrefix:@"rss."])
			{
				host=[host substringFromIndex:4];
			}
			else 
			{
				if([host hasPrefix:@"feeds."])
				{
					host=[host substringFromIndex:6];
				}
			}
		}
		
		return host;
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error parsing url: %@",url);
		return url;
	}
	@finally 
	{
	
	}
}

+ (UIImage*) faviconFromUrl:(NSString*)url imageCache:(NSMutableDictionary*)imageCache
{
	if(url==nil || [url length]==0)
	{
		return nil;
	}
	
	NSString * host=[self hostFromUrl:url];
	
	if(host && [host length]>0)
	{
		UIImage * img=nil;
		if(imageCache)
		{
			@synchronized(imageCache)
			{
				img=[imageCache objectForKey:host];
			}
		}
		
		if(img!=nil)
		{
			return img;
		}
		else 
		{
			NSLog(@"Get favicon for host: %@",host);
		
			NSString * faviconUrl=[NSString stringWithFormat:@"http://s2.googleusercontent.com/s2/favicons?domain=%@&alt=feed",host];
			
			NSLog(@"%@",faviconUrl);
			
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:faviconUrl]];
			
			if(data)
			{
				img = [[[UIImage alloc] initWithData:data] autorelease];
				
				if(img)
				{
					//NSLog(@"Got image for feed...");
					if(imageCache)
					{
						@synchronized(imageCache)
						{
							[imageCache setObject:img forKey:host];
						}
					}
					return img;
				}
			}
		}
	}
	else 
	{
		//NSLog(@"Failed to get host for: %@",url);
	}
	return nil;
}

@end
