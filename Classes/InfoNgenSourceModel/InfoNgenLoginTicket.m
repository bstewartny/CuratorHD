//
//  LoginTicket.m
//  Untitled
//
//  Created by Robert Stewart on 2/16/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "InfoNgenLoginTicket.h"
#import "FeedAccount.h"

#define kInfoNgenLoginTicketURL @"http://www.infongen.com/loginsm.aspx"
#define kInfoNgenLoginTicketCookieName @"iiAuth"

@implementation InfoNgenLoginTicket
@synthesize ticket;

- (NSString *)urlEncodeValue:(NSString *)str
{
	return str;
	//NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	//NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
	//NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
	//return result;
	
	//return [result autorelease];
}



- (NSString*) getAuthCookie
{
	NSHTTPCookieStorage * cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
	
	NSArray * cookies=[cookieStorage cookiesForURL:[NSURL URLWithString:kInfoNgenLoginTicketURL]];
	
	for(int i=0;i<[cookies count];i++)
	{
		NSHTTPCookie * cookie=[cookies objectAtIndex:i];
		if([cookie.name isEqualToString:kInfoNgenLoginTicketCookieName])
		{
			NSLog(@"Got login ticket from cookie...");
			return cookie.value;
		}
	}
	NSLog(@"Did not find login ticket cookie...");
	return nil;
}

- (id) initWithAccount:(FeedAccount *)account useCachedCookie:(BOOL)useCachedCookie
{
	return [self initWithUsername:account.username password:account.password useCachedCookie:useCachedCookie];
}
- (id) initWithUsername:(NSString *)username password:(NSString*)password useCachedCookie:(BOOL)useCachedCookie
{
	if(![super init])
	{
		return nil;
	}
	
	if (useCachedCookie) 
	{
		self.ticket=[self getAuthCookie];
		
		if(self.ticket)
		{
			return self;
		}			
	}
	
	//self.ticket=[self getAuthCookie];
	
	//if(!self.ticket)
	//{
	@try {
		 
		NSURL * URL=[NSURL URLWithString:kInfoNgenLoginTicketURL];
	
		NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
		[request setHTTPMethod:@"POST"];
	
		[request addValue:@"www.infongen.com" forHTTPHeaderField:@"Host"];
		[request addValue:@"Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.9.0.17) Gecko/2009122116 Firefox/3.0.17 (.NET CLR 3.5.30729)" forHTTPHeaderField:@"User-Agent"];
		[request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
		[request addValue:kInfoNgenLoginTicketURL forHTTPHeaderField:@"Referer"];
		[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
		NSString *post = [NSString stringWithFormat:@"AuthenticationErrorGuid=18fa53a074934c938c49e35dbcf62324&__VIEWSTATE=%@&btn=SignIn&userLogin=%@&userPassword=%@", 
					  [self urlEncodeValue:@"/wEPDwUJMTQ2OTM0MDA0ZGTK/OdHxdKPVviHT6StBiN8J/jusQ=="],
					  [self urlEncodeValue:username],					  
					  [self urlEncodeValue:password]
					  ];
	
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
		[request addValue:postLength forHTTPHeaderField:@"Content-Length"];
	
		[request setHTTPBody:postData];
	
		NSHTTPURLResponse * response=NULL;
	
		NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	
		NSInteger statusCode=[response statusCode];
		
		NSLog(@"Got status %d from ticket request",statusCode);
		
		self.ticket=[self getAuthCookie];
		
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception getting InfoNgen auth ticket: %@",[e description]);
	}
	@finally {
		
	}
	
	//}
	return self;	
}

- (void)dealloc {
	[ticket release]; 
	[super dealloc];
}
@end
