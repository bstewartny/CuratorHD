//
//  GoogleClientLogin.m
//  whaleops
//
//  Created by cameron ring on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleClientLogin.h"
//#import "GTMNSString+URLArguments.h"


//#define CAPTCHA_PREFIX          @"http://www.google.com/accounts/"
//#define UNKNOWN_CLIENT_ERROR    @"UnknownClientError"
//#define CONNECTION_ERROR        @"ConnetionError"

@implementation GoogleClientLogin


+ (NSString*) encodeString:(NSString*)s
{
	NSString * tmp = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																			   NULL,
																			   (CFStringRef)s,
																			   NULL,
																			   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																			   kCFStringEncodingUTF8 );
	return [tmp autorelease];
}

+ (NSString*)getAuthKeyWithUsername:(NSString *)username andPassword:(NSString *)password forService:(NSString *)service withSource:(NSString *)source
{
	NSLog(@"getAuthKeyWithUsername:%@ andPassword:%@ forService:%@ withSource:%@",username,password,service,source);
	
	@try 
	{
		
		NSString *content = [NSString stringWithFormat:@"accountType=HOSTED_OR_GOOGLE&Email=%@&Passwd=%@&service=%@&source=%@",
							 [self encodeString:username], 
							 [self encodeString:password],
							 [self encodeString:service],
							 [self encodeString:source]];

		NSURL *authURL = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authURL];
		[request setHTTPMethod:@"POST"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
		[request setHTTPBody:[content dataUsingEncoding:NSASCIIStringEncoding]];
		
		NSHTTPURLResponse * response=NULL;
		
		NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
		
		NSInteger statusCode=[response statusCode];
		
		if(data)
		{
			// process the body
			NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			NSDictionary * keys = [GoogleClientLogin parseResponseBody:body];
			
			[body release];
			
			if (statusCode == 200) 
			{
				NSString * auth = [keys objectForKey:@"Auth"];
				
				if ([auth length]) 
				{
					return auth;
				}
			}
			else 
			{
				NSLog(@"Got status code: %d",statusCode);
			}

			NSString * err=[keys objectForKey:@"Error"];
			
			
			
			//*error = [keys objectForKey:@"Error"];
			
			if(err) //or)
			{
				NSLog(@"Got error: %@",err);
			}
			
			/*if ((statusCode != 403) || ![error length]) 
			{
				
			}
			
			if (![error isEqualToString:@"CaptchaRequired"]) 
			{
				// a regular error
				
			}*/
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error: %@",[e userInfo]);
		//*error=[e description];
	}
	@finally 
	{
	}
	return nil;
}
/*
+ (NSString *)descriptionForError:(NSString *)error {
    
    if ([error isEqualToString:CONNECTION_ERROR]) {
        return @"There was an error communication with the server";
    } else if ([error isEqualToString:@"BadAuthentication"]) {
        return @"Invalid username or password";
    } else if ([error isEqualToString:@"NotVerified"]) {
        return @"That email address has not been validated. You must verify that address with your Google account before continuing";
    } else if ([error isEqualToString:@"TermsNotAgreed"]) {
        return @"You have not agreed to the terms yet. You must sign in to your Google account on the web before continuing";
    } else if ([error isEqualToString:@"CaptchaRequired"]) {
        return @"A CAPTCHA is required.";
    } else if ([error isEqualToString:@"Unknown"]) {
        return @"There was an unknown error";
    } else if ([error isEqualToString:@"AccountDeleted"]) {
        return @"That account has been deleted";
    } else if ([error isEqualToString:@"AccountDisabled"]) {
        return @"That account has been disabled";
    } else if ([error isEqualToString:@"ServiceDisabled"]) {
        return @"Your access to that service has been disabled";
    } else if ([error isEqualToString:@"ServiceUnavailable"]) {
        return @"That service is currently unavailable. Please try again later";
    }
        
    return @"There was an unknown error (client)";
}*/

+ (NSDictionary *)parseResponseBody:(NSString *)body {
    
	NSLog(@"parseResponseBody");
	
    NSMutableDictionary * tmp = [NSMutableDictionary dictionary];
    NSArray *lines = [body componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) 
	{
        NSRange separatorRange = [line rangeOfString:@"="];
        
        if (separatorRange.location == NSNotFound)
            break;
        
        NSString *key = [line substringToIndex:separatorRange.location];
        NSString *value = [line substringFromIndex:separatorRange.location + separatorRange.length];
        [tmp setObject:value forKey:key];
    }
    
    return tmp;
}


@end
