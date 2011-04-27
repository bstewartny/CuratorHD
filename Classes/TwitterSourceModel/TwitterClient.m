#import "TwitterClient.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OAServiceTicket.h"
#import "FeedItem.h"
#import "JSON.h"
#import "RegexKitLite.h"
#import "UserSettings.h"
#import "MarkupStripper.h"
#import "UIImage+RoundedCorner.h"
#import "ImageFetcher.h"

@implementation TwitterClient
@synthesize userId,screenName,username,password,verifyDelegate;

- (void)tokenAccessModifyRequest:(OAMutableURLRequest *)oRequest
{	
	if (xAuth)
	{
		NSLog(@"tokenAccessModifyRequest...");
		
		OARequestParameter *usernameParam = [[[OARequestParameter alloc] initWithName:@"x_auth_username"
																		   value:username] autorelease];
		
		OARequestParameter *passwordParam = [[[OARequestParameter alloc] initWithName:@"x_auth_password"
																		   value:password] autorelease];
		
		OARequestParameter *mode = [[[OARequestParameter alloc] initWithName:@"x_auth_mode"
																	   value:@"client_auth"] autorelease];
		
		[oRequest setParameters:[NSArray arrayWithObjects:usernameParam, passwordParam, mode, nil]];
	}
}

- (id) getJson:(NSString*)url
{
	@try {
		NSString * json=[self getString:url];	
		
		if(json)
		{
			return [json JSONValue];
		}
		else 
		{
			return nil;
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception in getJson for url: %@: %@",url,[e description]);
		return nil;
	}
	@finally 
	{
	}
}

- (NSString*) getString:(NSString*)url
{
	return [self getStringFromData:[self getData:url]];
}

- (NSString*) getStringFromData:(NSData*)data
{
	if(data)
	{
		@try 
		{
			return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		}
		@catch (NSException * e) 
		{
			return nil;
		}
		@finally 
		{
		}
	}
	else 
	{
		return nil;
	}
}

- (NSData*) getData:(NSString*)url
{
	return [self sendRequest:@"GET" url:url];
}

- (NSData*) sendRequest:(NSString*)httpMethod url:(NSString*)url
{
	NSLog(@"TwitterClient.sendRequest: %@ %@",httpMethod,url);
	
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
																consumer:consumer
																   token:accessToken
																   realm:nil
													   signatureProvider:nil];

	[oRequest setHTTPMethod:httpMethod];

	if(responseData!=nil)
	{
		[responseData release];
		responseData=nil;
	}
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init]; 

	[fetcher fetchDataWithRequest:oRequest delegate:self didFinishSelector:@selector(fetchDidFinish:data:) didFailSelector:@selector(fetchDidFail:error:)];
	
	[fetcher release];

	[oRequest release];
	
	return responseData;
}

- (void) fetchDidFinish:(OAServiceTicket*)ticket data:(NSData*)data
{
	NSLog(@"fetchDidFinish");
	responseData=[data retain];
}

- (void) fetchDidFail:(OAServiceTicket*)ticket error:(NSError*)error
{
	NSLog(@"fetchDidFail: %@",[error userInfo]);
	[responseData release];
	responseData=nil;
}

- (NSArray*) getListsFromJson:(NSArray*)json
{
	NSLog(@"getListsFromJson");
	NSLog(@"got %d items in json array",[json count]);
	
	NSMutableArray * items=[[[NSMutableArray alloc] init] autorelease];
	
	if([json isKindOfClass:[NSDictionary class]])
	{
		for(NSDictionary * t in [json objectForKey:@"lists"])
		{
			if(![t isKindOfClass:[NSDictionary class]]) continue;
			[items addObject:t];
		}
	}
	
	return items;
}

- (void)tokenRequestTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error
{
	NSLog(@"TwitterClient.tokenAccessTicket.didFailWithError");
	
	self.userId=nil;
	self.screenName=nil;
	
	[UserSettings saveSetting:@"twitter.userId" value:self.userId];
	[UserSettings saveSetting:@"twitter.screenName" value:self.screenName];
	
	[verifyDelegate didFail];
}

- (void)tokenAccessTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{
	NSLog(@"TwitterClient.tokenAccessTicket.didFinishWithData");
	
	self.userId=nil;
	self.screenName=nil;
	
	// parse user id and screen name
	if(ticket.didSucceed)
	{
		[verifyDelegate didSucceed];
		
		if(data)
		{
			NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
			if([responseBody length]>0)
			{
				NSArray *pairs = [responseBody componentsSeparatedByString:@"&"];
				
				for (NSString *pair in pairs) 
				{
					NSArray *elements = [pair componentsSeparatedByString:@"="];
					if ([[elements objectAtIndex:0] isEqualToString:@"user_id"]) 
					{
						self.userId = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					} 
					else
					{
						if ([[elements objectAtIndex:0] isEqualToString:@"screen_name"]) 
						{
							self.screenName = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						}
					}
				}
			}
			[responseBody release];
		}
	}
	else 
	{
		[verifyDelegate didFail];
		NSLog(@"ticket.didSucceed=NO");
	}
	
	NSLog(@"saving userId: %@",self.userId);
	
	NSLog(@"saving screenName: %@",self.screenName);
	
	[UserSettings saveSetting:@"twitter.userId" value:self.userId];
	[UserSettings saveSetting:@"twitter.screenName" value:self.screenName];
	if(ticket.didSucceed)
	{
		[super tokenAccessTicket:ticket didFinishWithData:data];	
	}
}

- (NSString*) screenName
{
	if(screenName==nil)
	{
		self.screenName=[UserSettings getSetting:@"twitter.screenName"];
	}
	return screenName;
}

- (NSString*) userId
{
	if(userId==nil)
	{
		self.userId=[UserSettings getSetting:@"twitter.userId"];
	}
	return userId;
}

- (NSArray*) getItemsFromJson:(NSArray*)json
{
	NSLog(@"getItemsFromJson");
	if(![json isKindOfClass:[NSArray class]])
	{
		NSLog(@"json is not an NSArray!!!");
		return nil;
	}
	
	NSLog(@"got %d items in json array",[json count]);
	
	NSMutableArray * items=[[[NSMutableArray alloc] init] autorelease];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	[formatter setLocale:enUS];
	[enUS release];
	
	[formatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZ yyyy"];
	NSMutableDictionary * profile_image_urls=[[NSMutableDictionary alloc] init];
	
	MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
	
	for(NSDictionary * t in json)
	{
		if(![t isKindOfClass:[NSDictionary class]]) continue;
		
		NSString * text=[t objectForKey:@"text"];
		NSString * item_id=[t objectForKey:@"id_str"];
		NSString * created_at=[t objectForKey:@"created_at"];
		
		NSDate * date=[formatter dateFromString:created_at];
		
		NSDictionary * user=[t objectForKey:@"user"];
		
		if(user==nil)
		{
			user=[t objectForKey:@"sender"]; // for direct messages
		}
		
		TempFeedItem *tmp=[[TempFeedItem alloc] init];
		
		NSString * user_name=[user objectForKey:@"name"];
		NSString * user_id=[user objectForKey:@"id_str"];
		NSString * user_screenname=[user objectForKey:@"screen_name"];
		NSString * profile_image_url=[user objectForKey:@"profile_image_url"];
		
		tmp.origin=user_name;
		tmp.imageUrl=profile_image_url;
		
		
		// see if image is already cached, if not download it and add to the cache...
		if([profile_image_url length]>0)
		{
			if([profile_image_urls objectForKey:profile_image_url]==nil)
			{
				[profile_image_urls setObject:profile_image_url forKey:profile_image_url];
			}
		}
		
		tmp.uid=item_id;
		tmp.originId=@"twitter";
		tmp.originUrl=user_screenname;
		tmp.date=date; 		
		tmp.url=[NSString stringWithFormat:@"http://twitter.com/%@/status/%@",user_id,item_id];
		
		tmp.headline=[[stripper stripMarkup:text] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		
		tmp.origSynopsis=[self getTweetHtml:text];
		
		tmp.synopsis=tmp.headline;
			
		[items addObject:tmp];
		
		[tmp release];
	}
	
	[formatter release];
	
	// get profile images
	if([profile_image_urls count]>0)
	{
		// fetch images from web (from local disk cache if exists)
		NSArray * urls=[profile_image_urls allKeys];
		
		ImageFetcher * imageFetcher=[[ImageFetcher alloc] init];
		
		NSDictionary * dict=[imageFetcher fetchImages:urls];
		
		// attach images to items
		for(FeedItem * item in items)
		{
			NSString * profile_image_url=item.imageUrl;
			if([profile_image_url length]>0)
			{
				UIImage * img=[dict objectForKey:profile_image_url];
				if (img) 
				{
					item.image=img;
				}
			}
		}
		[imageFetcher release];
	}
	[profile_image_urls release];
	
	return items;
}

- (NSArray*) getItems:(NSString*)url
{
	return [self getItemsFromJson:[self getJson:url]];
}

- (void) retweet:(NSString*)tweetId
{
	
	NSLog(@"retweet: %@",tweetId);
	
	if(tweetId==nil) return;
	
	NSString * url=[NSString stringWithFormat:@"http://api.twitter.com/1/statuses/retweet/%@.json",tweetId];
	
	NSLog(@"retweet: doing async POST to %@",url);
	
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
																	consumer:consumer
																	   token:accessToken
																	   realm:nil
														   signatureProvider:nil];
	
	[oRequest setHTTPMethod:@"POST"];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																						  delegate:self
										  										 didFinishSelector:@selector(sendStatusTicket:didFinishWithData:)
																				   didFailSelector:@selector(sendStatusTicket:didFailWithError:)];
	[fetcher start];
	[oRequest release];
	
	[self sendDidStart];
}

- (BOOL)shouldAutoShare
{
	if([item customBoolForSwitchKey:@"retweet"] || [item customBoolForSwitchKey:@"favorite"])
	{
		// dont need popup form in these cases...
		return YES;
	}
	
	
	return [super shouldAutoShare];
}
- (void)show
{
	// if we just logged in from sources update - then continue to update the twitter source...
	NSLog(@"TwitterClient.show");

	[super show];
}	

- (BOOL)send
{	
	NSLog(@"TwitterClient.send");
	
	// Check if we should send follow request too
	if (xAuth && [item customBoolForSwitchKey:@"followMe"])
		[self followMe];	
	
	
	if([item customBoolForSwitchKey:@"retweet"])
	{
		NSLog(@"its a retweet");
		//[item setCustomValue:nil forKey:@"retweet"];
		NSString * tweetId=[item customValueForKey:@"id"];
		NSLog(@"tweetid is %@",tweetId);
		
		[self retweet:tweetId];
	}
	else 
	{
		if([item customBoolForSwitchKey:@"favorite"])
		{
			NSLog(@"its a favorite");
			NSString * tweetId=[item customValueForKey:@"id"];
			NSLog(@"tweetid is %@",tweetId);
			
			[self addToFavorites:tweetId];
		}
		else 
		{
			if (![self validate])
			{
				NSLog(@"failed to validate");
				[self show];
				return NO;
			}
			else 
			{
				if (item.shareType == SHKShareTypeImage) 
				{
					[self sendImage];
				} 
				else 
				{
					[self sendStatus];
				}
			}
		}
	}
	
	// Notify delegate
	[self sendDidStart];	
	
	return YES;
	 
}

- (void) addToFavorites:(NSString*)tweetId
{
	NSLog(@"addToFavorites: %@",tweetId);
	
	if(tweetId==nil) return;
	
	NSString * url=[NSString stringWithFormat:@"http://api.twitter.com/1/favorites/create/%@.json",tweetId];
	
	NSLog(@"addToFavorites: doing async POST to %@",url);
	
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
																	consumer:consumer
																	   token:accessToken
																	   realm:nil
														   signatureProvider:nil];
	
	[oRequest setHTTPMethod:@"POST"];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																						  delegate:self
										  										 didFinishSelector:@selector(sendStatusTicket:didFinishWithData:)
																				   didFailSelector:@selector(sendStatusTicket:didFailWithError:)];
	
	[fetcher start];
	[oRequest release];
	
	[self sendDidStart];
}

- (NSArray*) getLists
{
	NSLog(@"TwitterClient.getLists");
	if(![self isAuthorized])
	{
		return nil;
	}

	return  [self getListsFromJson:[self getJson:[NSString stringWithFormat:@"http://api.twitter.com/1/%@/lists.json",self.userId]]];
}

- (NSArray*) getMostRecentMentions:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"TwitterClient.getMostRecentMentions");
	if(![self isAuthorized])
	{
		return nil;
	}
	return [self getItems:@"http://api.twitter.com/1/statuses/mentions.json"];
}

- (NSArray*) getMostRecentListItemsByUrl:(NSString*)url maxItems:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"TwitterClient.getMostRecentListItems");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if(sinceId)
	{
		url=[NSString stringWithFormat:@"%@?since_id=%@",url,sinceId];
	}
	
	return [self getItems:url];
}

- (NSArray*) getMostRecentListItems:(NSString*)list_id maxItems:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"TwitterClient.getMostRecentListItems");
	if(![self isAuthorized])
	{
		return nil;
	}
	 
	if(sinceId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://api.twitter.com/1/%@/lists/%@/statuses.json?since_id=%@",self.userId,list_id,sinceId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://api.twitter.com/1/%@/lists/%@/statuses.json",self.userId,list_id]];
	}
}

- (NSArray*) getMostRecentHomeTimeline:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"TwitterClient.getMostRecentHomeTimeline");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if (maxItems==0) 
	{
		maxItems=20;
	}
	
	if(sinceId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/home_timeline.json?count=%d&since_id=%@",maxItems,sinceId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/home_timeline.json?count=%d",maxItems]];
	} 
}

- (NSArray*) getMostRecentFriendsTimeline:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"TwitterClient.getMostRecentFriendsTimeline");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if (maxItems==0) 
	{
		maxItems=20;
	}
	
	if(sinceId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/friends_timeline.json?count=%d&since_id=%@",maxItems,sinceId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/friends_timeline.json?count=%d",maxItems]];
	} 
}

- (NSArray*) getMostRecentDirectMessages:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"TwitterClient.getMostRecentDirectMessages");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if (maxItems==0) 
	{
		maxItems=20;
	}
	
	if(sinceId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/direct_messages.json?count=%d&since_id=%@",maxItems,sinceId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/direct_messages.json?count=%d",maxItems]];
	} 
}

- (NSArray*) getMostRecentFavorites:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"TwitterClient.getMostRecentFavorites");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	return [self getItems:@"http://twitter.com/favorites.json"];
}

- (NSArray*) getMoreOldMentions:(int)maxItems maxId:(NSString*)maxId
{
	NSLog(@"TwitterClient.getMoreOldMentions");
	if(![self isAuthorized])
	{
		return nil;
	}
	return [self getItems:@"http://api.twitter.com/1/statuses/mentions.json"];
}

- (NSArray*) getMoreOldListItemsByUrl:(NSString*)url maxItems:(int)maxItems maxId:(NSString*)maxId
{
	NSLog(@"TwitterClient.getMoreOldListItemsByUrl");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if(maxId)
	{
		url=[NSString stringWithFormat:@"%@?max_id=%@",url,maxId];
	}
	
	return [self getItems:url];
}

- (NSArray*) getMoreOldListItems:(NSString*)list_id maxItems:(int)maxItems maxId:(NSString*)maxId
{
	NSLog(@"TwitterClient.getMoreOldListItems");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if(maxId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://api.twitter.com/1/%@/lists/%@/statuses.json?max_id=%@",self.userId,list_id,maxId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://api.twitter.com/1/%@/lists/%@/statuses.json",self.userId,list_id]];
	}
}

- (NSArray*) getMoreOldHomeTimeline:(int)maxItems maxId:(NSString*)maxId
{
	NSLog(@"TwitterClient.getMoreOldHomeTimeline");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if (maxItems==0) 
	{
		maxItems=20;
	}
	
	if(maxId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/home_timeline.json?count=%d&max_id=%@",maxItems,maxId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/home_timeline.json?count=%d",maxItems]];
	} 
}

- (NSArray*) getMoreOldFriendsTimeline:(int)maxItems maxId:(NSString*)maxId
{
	NSLog(@"TwitterClient.getMoreOldFriendsTimeline");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if (maxItems==0) 
	{
		maxItems=20;
	}
	
	if(maxId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/friends_timeline.json?count=%d&max_id=%@",maxItems,maxId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/statuses/friends_timeline.json?count=%d",maxItems]];
	} 
}

- (NSArray*) getMoreOldDirectMessages:(int)maxItems maxId:(NSString*)maxId
{
	NSLog(@"TwitterClient.getMoreOldDirectMessages");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	if (maxItems==0) 
	{
		maxItems=20;
	}
	
	if(maxId)
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/direct_messages.json?count=%d&max_id=%@",maxItems,maxId]];
	}
	else 
	{
		return [self getItems:[NSString stringWithFormat:@"http://twitter.com/direct_messages.json?count=%d",maxItems]];
	} 
}

- (NSArray*) getMoreOldFavorites:(int)maxItems maxId:(NSString*)maxId
{
	NSLog(@"TwitterClient.getMoreOldFavorites");
	if(![self isAuthorized])
	{
		return nil;
	}
	
	return [self getItems:@"http://twitter.com/favorites.json"];
}

- (void)tokenAccess:(BOOL)refresh
{
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:accessURL
																	consumer:consumer
																	   token:(refresh ? accessToken : requestToken)
																	   realm:nil   // our service provider doesn't specify a realm
														   signatureProvider:signatureProvider]; // use the default method, HMAC-SHA1
	
    [oRequest setHTTPMethod:@"POST"];
	
	[self tokenAccessModifyRequest:oRequest];
	
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																						  delegate:self
																				 didFinishSelector:@selector(tokenAccessTicket:didFinishWithData:)
																				   didFailSelector:@selector(tokenAccessTicket:didFailWithError:)];
	[fetcher start];
	[oRequest release];
}

- (BOOL) isAuthorized
{
	if(![super isAuthorized])
	{
		NSLog(@"User is not currenlty authorized for twitter");
		
		return NO;
	}
	else 
	{
		return YES;
	}
}

- (NSString*) getTweetHtml:(NSString*)text
{
	return [self wrap_user_mention_with_link:
			[self wrap_hashtag_with_link:
			 [self wrap_http_with_link:[text stringByReplacingOccurrencesOfString:@"\n" withString:@" "]]]];
}

- (NSString*) wrap_user_mention_with_link:(NSString*)text
{
	//Replace @user with <a href="http://twitter.com/user">@user</a>"""
	
	NSString * searchString=@"(^|[^\\w])@(\\w+)\\b";
	NSString * replaceString=@"$1<a href=\"http://twitter.com/$2\">@$2</a>";
	
	return [text stringByReplacingOccurrencesOfRegex:searchString withString:replaceString];
	
}

- (NSString*) wrap_hashtag_with_link:(NSString*)text
{
	//Replace #hashtag with <a href="http://twitter.com/search?q=hashtag">#hashtag</a>"""
	NSString * searchString=@"(^|[^\\w])#(\\w+)\\b";
	NSString * replaceString=@"$1<a href=\"http://twitter.com/search?q=$2\">#$2</a>";
	
	return [text stringByReplacingOccurrencesOfRegex:searchString withString:replaceString];
}

- (NSString*) wrap_http_with_link:(NSString*)text
{
	//Replace http://foo with <a href="http://foo">http://foo</a>"""
	NSString * searchString=@"(^|[^\\w])(http://[^\\s]+)";
	NSString * replaceString=@"$1<a href=\"$2\">$2</a>";
	
	return [text stringByReplacingOccurrencesOfRegex:searchString withString:replaceString];
}						  
					/*
- (NSString*) embed_tweet_html:(tweet_url, extra_css=None):
//Generate embedded HTML for a tweet, given its Twitter URL.  The
//						  result is formatted in the style of Robin Sloan's Blackbird Pie.
//						  See: http://media.twitter.com/blackbird-pie
//						  
//						  The optional extra_css argument is a dictionary of CSS class names
//						  to CSS style text.  If provided, the extra style text will be
//						  included in the embedded HTML CSS.  Currently only the bbpBox
//						  class name is used by this feature.
//						  """
						  tweet_id = tweet_id_from_tweet_url(tweet_url)
						  api_url = 'http://api.twitter.com/1/statuses/show.json?id=' + tweet_id
						  api_handle = urllib2.urlopen(api_url)
						  api_data = api_handle.read()
						  api_handle.close()
						  tweet_json = json.loads(api_data)
						  
						  tweet_text = wrap_user_mention_with_link(
										wrap_hashtag_with_link(
										wrap_http_with_link(
										tweet_json['text'].replace('\n', ' ')
										)
										)
										)
						  
						  //tweet_created_datetime = timestamp_string_to_datetime(tweet_json["created_at"])
						  //tweet_local_datetime = tweet_created_datetime + (datetime.datetime.now() - datetime.datetime.utcnow())
						  //tweet_easy_timestamp = easy_to_read_timestamp_string(tweet_local_datetime)
						  
						  if extra_css is None:
						  extra_css = {}
						  
						  html = TWEET_EMBED_HTML.format(
														 id=tweet_id,
														 tweetURL=tweet_url,
														 screenName=tweet_json['user']['screen_name'],
														 realName=tweet_json['user']['name'],
														 tweetText=tweet_text,
														 source=tweet_json['source'],
														 profilePic=tweet_json['user']['profile_image_url'],
														 profileBackgroundColor=tweet_json['user']['profile_background_color'],
														 profileBackgroundImage=tweet_json['user']['profile_background_image_url'],
														 profileTextColor=tweet_json['user']['profile_text_color'],
														 profileLinkColor=tweet_json['user']['profile_link_color'],
														 timeStamp=tweet_json['created_at'],
														 easyTimeStamp=tweet_easy_timestamp,
														 utcOffset=tweet_json['user']['utc_offset'],
														 bbpBoxCss=extra_css.get('bbpBox', ''),
														 )
						  return html

}*/
- (void) dealloc
{
	[username release];
	[password release];
	username=nil;
	password=nil;
	[responseData release];
	responseData=nil;
	[userId release];
	[screenName release];
	userId=nil;
	screenName=nil;
	[super dealloc];
}



@end
