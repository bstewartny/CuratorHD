//
//  TumblrClient.m
//  Untitled
//
//  Created by Robert Stewart on 6/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TumblrClient.h"
#import "UrlParams.h"
#import "FeedAccount.h"



@implementation TumblrPost
@synthesize private,tags,slug,state,type,title,body,photo_source,photo_data,photo_caption,photo_click_through_url,quote,quote_source,link_name,link_url,link_description,
video_embed,video_data,video_title,video_caption,audio_data,audio_externally_hosted_url,audio_caption;


- (id) initWithType:(TumblrPostType)type 
{
	if([super init])
	{
		self.type=type;
	}
	return self;
}

- (void) dealloc
{
	[tags release];
	[slug release];
	[title release];
	[body release];
	[photo_source release];
	[photo_data release];
	[photo_caption release];
	[photo_click_through_url release];
	[quote,quote_source release];
	[link_name release];
	[link_url release];
	[link_description release];
	[video_embed release];
	[video_data release];
	[video_title release];
	[video_caption release];
	[audio_data release];
	[audio_externally_hosted_url release];
	[audio_caption release];
	[super dealloc];
}

@end

@implementation TumblrClient
@synthesize username,password;
 
- (id) initWithUsername:(NSString*)username password:(NSString*)password
{
	if ([super init]) {
		self.username=username;
		self.password=password;
	}
	return self;
}

- (void) post:(TumblrPost*)post
{
	NSLog(@"post");
	
	NSURL * url=[NSURL URLWithString:@"http://www.tumblr.com/api/write"];
	
	UrlParams * p=[[UrlParams alloc] init];
	
	[p appendParam:@"email" value:username];
	[p appendParam:@"password" value:password];
	
	switch(post.type)
	{
		case TumblrPostTypeRegular:
			[p appendParam:@"type" value:@"regular"];
			[p appendParam:@"title" value:post.title];
			[p appendParam:@"body" value:post.body];
			break;
			
		case TumblrPostTypePhoto:
			[p appendParam:@"type" value:@"photo"];
			[p appendParam:@"source" value:post.photo_source];
			[p appendParam:@"data" value:post.photo_data];
			[p appendParam:@"caption" value:post.photo_caption];
			[p appendParam:@"click-through-url" value:post.photo_click_through_url];
			break;

		case TumblrPostTypeQuote:
			[p appendParam:@"type" value:@"quote"];
			[p appendParam:@"quote" value:post.quote];
			[p appendParam:@"source" value:post.quote_source];
			break;

		case TumblrPostTypeLink:
			[p appendParam:@"type" value:@"link"];
			[p appendParam:@"name" value:post.link_name];
			[p appendParam:@"url" value:post.link_url];
			[p appendParam:@"description" value:post.link_description];
			break;

		case TumblrPostTypeConversation:
			// not supported yet
			break;

		case TumblrPostTypeVideo:
			[p appendParam:@"type" value:@"video"];
			[p appendParam:@"embed" value:post.video_embed];
			[p appendParam:@"data" value:post.video_data];
			[p appendParam:@"title" value:post.video_title];
			[p appendParam:@"caption" value:post.video_caption];
			break;

		case TumblrPostTypeAudio:
			[p appendParam:@"type" value:@"audio"];
			[p appendParam:@"data" value:post.audio_data];
			[p appendParam:@"externally-hosted-url" value:post.audio_externally_hosted_url];
			[p appendParam:@"caption" value:post.audio_caption];
			break;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
									initWithURL:url
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
		
		NSString * dataString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
		NSLog(@"%@",dataString);
		
		[dataString release];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception posting to tumblr: %@",[e description]);
	}
	@finally 
	{
		[request release];
	}
	
	[p release];
}

- (void)dealloc 
{
	[username release];
	[password release];
    [super dealloc];
}

@end
