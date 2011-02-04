//
//  ImageRepositoryClient.m
//  Untitled
//
//  Created by Robert Stewart on 5/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ImageRepositoryClient.h"
#import "Base64.h"

@implementation ImageRepositoryClient


+ (NSString*) putImage:(UIImage*) image
{
	// generate name from encoded image data
	
	NSString * path;
	
	NSData *imageData = UIImagePNGRepresentation(image);
	
	NSString * encoded=[Base64 encode:imageData];
	
	encoded=[encoded stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	encoded=[encoded stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	encoded=[encoded stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	encoded=[encoded stringByReplacingOccurrencesOfString:@"\\" withString:@"_"];
	encoded=[encoded stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	encoded=[encoded stringByReplacingOccurrencesOfString:@"=" withString:@""];
	
	if([encoded length]>60)
	{
		// take first 20 chars of encoded for first part of path
		NSString * first_part=[encoded substringToIndex:20];
	
		// take middle 20 chars of ecoded for middle part of path
		NSString * middle_part=[encoded substringWithRange:NSMakeRange([encoded length]/2, 20)];
	
		// take last 20 chars of encoded for last part of path
		NSString * last_part=[encoded substringFromIndex:[encoded length]-20];
		
		path=[NSString stringWithFormat:@"%@/%@/%@.png",first_part,middle_part,last_part];
	
	}
	else 
	{
		path=[NSString stringWithFormat:@"%@.png",encoded];
	}

	return [ImageRepositoryClient putImage2:image withPath:path];

}

+ (NSString*) putImage2:(UIImage*)image withPath:(NSString*)path
{
	NSString * putUri=[kImageRepositoryURL stringByAppendingString:path];
	
	NSLog(@"putImage: %@",putUri);
	
	NSURL * url=[NSURL URLWithString:putUri];

	// see if image already exists at uri...
	// do http HEAD to get XML including md5
	
	// do http PUT to upload image...
	NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
	[request setHTTPMethod:@"PUT"];
	
	NSData *imageData = UIImagePNGRepresentation(image);
	
	NSString *postLength = [NSString stringWithFormat:@"%d", [imageData length]];
	
	[request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
	
	[request addValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	[request setHTTPBody:imageData];
	
	//[request addValue:@"ipad" forHTTPHeaderField:@"client"];
	
	NSURLResponse * response=NULL;
	
	NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];	
	
	// return URL to the image
	
	return putUri;
}

@end
