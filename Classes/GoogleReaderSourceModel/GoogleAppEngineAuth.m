//
//  GoogleAppEngineAuth.m
//  whaleops
//
//  Created by cameron ring on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleAppEngineAuth.h"
//#import "GTMNSString+URLArguments.h"
//#import <CommonCrypto/CommonDigest.h>
#import "GoogleClientLogin.h"

@implementation GoogleAppEngineAuth

+ (NSString*)getAuthCookieWithAppURL:(NSString*)appURL andUsername:(NSString *)username andPassword:(NSString *)password withSource:(NSString *)source
{
    //NSString * error=nil;
	
	NSString * authKey=[GoogleClientLogin getAuthKeyWithUsername:username andPassword:password forService:@"ah"
													  withSource:source];
	
	if(authKey)
	{
		return [self getAuthCookieWithAppURL:appURL authKey:authKey];
	}
	else
	{
		return nil;
	}
}

+ (NSString*)getAuthCookieWithAppURL:(NSString*)appURL authKey:(NSString *)authKey
{
	NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				   NULL,
																				   (CFStringRef)authKey,
																				   NULL,
																				   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				   kCFStringEncodingUTF8 );
    // request correct cookie
    NSURL *cookieURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/_ah/login?continue=%@/&auth=%@", 
                                             appURL,
                                             appURL,
                                             encodedString
                                             ]
                        ];
	
	[encodedString release];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:cookieURL];
    
	[request setHTTPMethod:@"GET"];
	
	NSHTTPURLResponse * response=NULL;
	
	NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	
	//NSInteger statusCode=[response statusCode];
	
	if(response)
	{
		NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[response URL]];
		
		// iterate over cookies looking for ACSID
		for (NSHTTPCookie *cookie in cookies) 
		{
			if ([[cookie name] isEqualToString:@"ACSID"])
			{
				return [cookie value];
			}
		}
	}
	
	return nil;
}
/*
// only used when generating a cookie for authing against the dev server
+ (NSString *)userIdForUsername:(NSString *)username {
	const char *cStr = [username UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
    
	CC_MD5(cStr, strlen(cStr), result);
	return [NSString 
			stringWithFormat: @"1%02d%02d%02d%02d%02d%02d%02d%02d",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
    
}

// if we're authing against the dev server, just set the right cookie
+ (BOOL)authForDevServerWith:(NSString *)username {

    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSString *value = [NSString stringWithFormat:@"%@:False:%@", username, [self userIdForUsername:username]];
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"dev_appserver_login", NSHTTPCookieName,
                                value, NSHTTPCookieValue,
                                @"/", NSHTTPCookiePath,
                                @"localhost", NSHTTPCookieDomain,
                                nil];
    
    [cookieJar setCookie:[NSHTTPCookie cookieWithProperties:properties]];
	
	self.authCookie=value;
	
	return YES;
}
*/
@end
