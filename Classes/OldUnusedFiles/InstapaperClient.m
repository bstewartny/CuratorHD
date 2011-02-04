//
//  InstapaperClient.m
//  Untitled
//
//  Created by Robert Stewart on 8/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "InstapaperClient.h"
#import "UrlParams.h"

@implementation InstapaperClient
@synthesize username,password;

- (id) initWithUsername:(NSString*)username password:(NSString*)password
{
	if ([super init]) {
		self.username=username;
		self.password=password;
	}
	return self;
}

- (BOOL) post:(NSString*)url title:(NSString*)title selection:(NSString*)selection
{
	BOOL success=NO;
	NSLog(@"post");
	
	UrlParams * p=[[UrlParams alloc] init];
	
	[p appendParam:@"username" value:username];
	[p appendParam:@"password" value:password];
	[p appendParam:@"url" value:url];
	if(title && [title length]>0)
	{
		[p appendParam:@"title" value:title];
	}
	if(selection && [selection length]>0)
	{
		[p appendParam:@"selection" value:selection];
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
									initWithURL:[NSURL URLWithString:@"https://www.instapaper.com/api/add"]
									];
	
	@try 
	{
		[request setHTTPMethod:@"POST"];
		
		NSString *request_body = [p getQueryString];
		
		NSLog(@"%@",request_body);
		
		[request setHTTPBody:[request_body dataUsingEncoding:NSUTF8StringEncoding]];
		
		NSHTTPURLResponse * response=NULL;
		
		NSData * data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
		
		NSLog(@"status=%d",[response statusCode]);
		
		success=([response statusCode]==201);
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception posting to tumblr: %@",[e description]);
		success=NO;
	}
	@finally 
	{
		[request release];
	}
	
	[p release];
	
	return success;
}

- (void)dealloc 
{
	[username release];
	[password release];
    [super dealloc];
}
@end
