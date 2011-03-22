//
//  FacebookClient.m
//  Untitled
//
//  Created by Robert Stewart on 11/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FacebookClient.h"
#import "FeedItem.h"
#import "JSON.h"
@implementation FacebookClient

+ (NSString *)sharerId
{
	return NSStringFromClass([SHKFacebook class]);
}

- (NSString *)sharerId
{
	return [[SHKFacebook class] sharerId];	
}

- (NSArray*) getMostRecentWall:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"FacebookClient.getMostRecentWall");
	
	return [self getMostRecentItems:maxItems sinceId:sinceId graphPath:@"me/feed"];
}

- (NSArray*) getMostRecentNewsFeed:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"FacebookClient.getMostRecentNewsFeed");
	
	return [self getMostRecentItems:maxItems sinceId:sinceId graphPath:@"me/home"];
}

- (NSArray*) getMostRecentFriends:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"FacebookClient.getMostRecentFriends");
	
	return [self getMostRecentItems:maxItems sinceId:sinceId graphPath:@"me/friends"];
}	

- (NSArray*) getMostRecentNotes:(int)maxItems sinceId:(NSString*)sinceId
{
	NSLog(@"FacebookClient.getMostRecentNotes");
	
	return [self getMostRecentItems:maxItems sinceId:sinceId graphPath:@"me/notes"];
}

- (NSArray*) getMoreOldItems:(int)maxItems minTimestamp:(NSString*)minTimestamp graphPath:(NSString*)graphPath
{
	NSLog(@"getMoreOldItems:graphPath:%@",graphPath);

	return [self getItems:maxItems since:nil until:minTimestamp graphPath:graphPath];
}

- (NSArray*) getMostRecentItems:(int)maxItems maxTimestamp:(NSString*)maxTimestamp graphPath:(NSString*)graphPath
{
	NSLog(@"getMostRecentItems:graphPath:%@",graphPath);
	
	return [self getItems:maxItems since:maxTimestamp until:nil graphPath:graphPath];
}


- (NSArray*) getLinkItems:(int)maxItems url:(NSString*)url
{
	if(![self isAuthorized])
	{
		return nil;
	}
	
	NSMutableArray * results=[[[NSMutableArray alloc] init] autorelease];
	
	NSArray * json=[facebook getJson:url params:[NSMutableDictionary dictionary] httpMethod:@"GET" delegate:self];
	
	NSLog(@"json=%@",[json description]);

	/*
	 (
	 {
	 "fql_result_set" =         (
	 {
	 "created_time" = 1292001744;
	 "image_urls" =                 {
	 };
	 "link_id" = 113474408723246;
	 owner = 100001527844873;
	 "owner_comment" = test;
	 summary = "";
	 title = "http://news.ycombinator.com/";
	 url = "http://news.ycombinator.com/";
	 },
	 {
	 "created_time" = 1292001715;
	 "image_urls" =                 (
	 "http://www.cnn.com/2010/images/12/08/siu.taliban.clip.cnn.416x234.jpg"
	 );
	 "link_id" = 160258364019387;
	 owner = 100001527844873;
	 "owner_comment" = "Just a test post of link";
	 summary = "CNN.com delivers the latest breaking news and information on the latest top stories, weather, business, entertainment, politics, and more. For in-depth coverage, CNN.com provides special reports, video, audio, photo galleries, and interactive guides.";
	 title = "CNN.com - Breaking News, U.S., World, Weather, Entertainment & Video News";
	 url = "http://www.cnn.com/";
	 }
	 );
	 name = links;
	 },
	 {
	 "fql_result_set" =         (
	 {
	 name = "Robert Stewart";
	 "pic_square" = "http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs466.snc4/49144_100001527844873_2388437_q.jpg";
	 uid = 100001527844873;
	 }
	 );
	 name = users;
	 }
	 )
	 */
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	[formatter setLocale:enUS];
	[enUS release];
	
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];//2010-11-30T21:05:41+0000
	
	NSArray * links_array;
	NSArray * users_array;
	
	
	for(NSDictionary * d in json)
	{
		if([[d objectForKey:@"name"] isEqualToString:@"users"])
		{
			users_array=[d objectForKey:@"fql_result_set"];
		}
		if([[d objectForKey:@"name"] isEqualToString:@"links"])
		{
			links_array=[d objectForKey:@"fql_result_set"];
		}	
	}
	
	NSMutableDictionary * user_map=[[[NSMutableDictionary alloc] init] autorelease];
	for(NSDictionary * user in users_array)
	{
		[user_map setObject:user forKey:[[user objectForKey:@"uid"] stringValue]];
	}
	
	
	for(NSDictionary * d in links_array)
	{
		NSString * owner=[[d objectForKey:@"owner"] stringValue];
		NSString * uid=[[d objectForKey:@"link_id"] stringValue];
		NSString * link=[d objectForKey:@"url"];
		NSString * subject=[d objectForKey:@"title"];
		NSString * synopsis=[d objectForKey:@"summary"];
		//NSArray * images=[d objectForKey:@"image_urls"];
		NSString * comment=[d objectForKey:@"owner_comment"];
		NSDate * created_date=[NSDate dateWithTimeIntervalSince1970:[[d objectForKey:@"created_time"] intValue]];
		//NSDate * created_date=[formatter dateFromString:[d objectForKey:@"created_time"]];
	
		NSString * name=nil;
		NSDictionary * user=[user_map objectForKey:owner];
		
		if(user)
		{
			name=[user objectForKey:@"name"];
		}
		
		
		TempFeedItem * tmp=[[TempFeedItem alloc] init];
		
		tmp.url=link;
		tmp.date=created_date;
		tmp.headline=subject;
		tmp.synopsis=synopsis;
		tmp.origSynopsis=synopsis;
		tmp.notes=comment;
	
		if(name)
			tmp.origin=name;
		else 
			tmp.origin=owner;
		
		tmp.originUrl=owner;
		tmp.originId=[NSString stringWithFormat:@"facebook.link"];
		
		tmp.uid=uid;
		
		[results addObject:tmp];
		
		[tmp release];
	
	}
	[self getProfilePictures:results];
	[formatter release];
	
	return results;
}

- (NSArray*) getItems:(int)maxItems since:(NSString*)since until:(NSString*)until graphPath:(NSString*)graphPath
{
	if(![self isAuthorized])
	{
		return nil;
	}
	NSMutableArray * results=[[[NSMutableArray alloc] init] autorelease];
	
	NSString * query_seperator=@"?";
	
	if([graphPath rangeOfString:@"?"].location!=NSNotFound)
	{
		NSLog(@"graphPath already has ?, using & as seperator...");
		query_seperator=@"&";
	}
		
	if(since!=nil && until!=nil)
	{
		graphPath=[graphPath stringByAppendingFormat:@"%@since=%@&until=%@",query_seperator,since,until];
	}
	else	
	{
		if(since!=nil)
		{
			graphPath=[graphPath stringByAppendingFormat:@"%@since=%@",query_seperator,since];
		}
		else 
		{
			if(until!=nil)
			{
				graphPath=[graphPath stringByAppendingFormat:@"%@until=%@",query_seperator,until];
			}
		}
	}

	NSDictionary * json=[facebook getJsonWithGraphPath:graphPath andDelegate:self];

	NSLog(@"json=%@",[json description]);
	
	if(![json isKindOfClass:[NSDictionary class]])
	{
		NSLog(@"json is NOT NSDictionary!");
		
	}
	NSArray * items = [json objectForKey:@"data"];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	[formatter setLocale:enUS];
	[enUS release];
	
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];//2010-11-30T21:05:41+0000
	
	NSMutableDictionary * imageCache=[[[UIApplication sharedApplication] delegate] feedImageCache];
	NSMutableDictionary * unique_froms=[[[NSMutableDictionary alloc] init] autorelease];
	
	for(NSDictionary * i in items)
	{
		//NSString * origin=[i objectForKey:@"attribution"]; // the app used to post it
		NSString * from=[[i objectForKey:@"from"] objectForKey:@"name"]; // author/user/friend
		NSString * from_id=[[i objectForKey:@"from"] objectForKey:@"id"];
		NSString * uid=[i objectForKey:@"id"]; // id of message
		NSString * link=[i objectForKey:@"link"]; // the link if shared a link
		NSString * message=[i objectForKey:@"message"];
		NSString * name=[i objectForKey:@"name"]; // the headline if shared a link
		NSString * type=[i objectForKey:@"type"]; // link, etc.
		NSString * created_time=[i objectForKey:@"created_time"];//2010-11-30T21:05:41+0000
	
		NSDate * date=[NSDate date];
		
		if([created_time length]>0)
		{
			@try 
			{
				date=[formatter dateFromString:created_time];
				NSLog(@"Parsed date %@ to %@",created_time,[date description]);
			}
			@catch (NSException * e) {
				NSLog(@"Error parsing date: %@",[e description]);
			}
			@finally 
			{
				
			}
		}
		
		NSString * subject=[i objectForKey:@"subject"];
		NSString * description=[i objectForKey:@"description"];
		
		TempFeedItem * tmp=[[TempFeedItem alloc] init];
		
		tmp.date=date;
		
		if([type isEqualToString:@"link"])
		{
			if([name length]>0)
			{
				tmp.headline=name;
			}
			else 
			{
				tmp.headline=message;
			}
		}
		else 
		{
			if([subject length]>0)
			{
				tmp.headline=subject;
			}
			else 
			{
				tmp.headline=message;
			
				if([message length]==0)
				{
					tmp.headline=name;
				}
			}
		}
		
		if([type isEqualToString:@"status"])
		{
			
		}
		
		if([type isEqualToString:@"photo"])
		{
			if([tmp.headline length]==0)
			{
				tmp.headline=@"Photo";
			}
			
			NSString * picture=[i objectForKey:@"picture"];
			
			if([picture length]>0)
			{
				tmp.imageUrl=picture;
				// get image...
				// TODO: push these into a queue and process all items in parallel at the end of this function...
				NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:picture]];
				
				if(data)
				{
					tmp.image = [[[UIImage alloc] initWithData:data] autorelease];
				}
			}
		}
		
		if([description length]>0)
		{
			tmp.origSynopsis=description;
			tmp.notes=message;
		}
		else 
		{
			tmp.origSynopsis=message;
		}

		tmp.url=link;
		tmp.uid=uid;
		tmp.origin=from;
		tmp.originUrl=from_id;
		tmp.originId=[NSString stringWithFormat:@"facebook.%@",type];
	
		[results addObject:tmp];
		
		[tmp release];
	}

	[self getProfilePictures:results]; 
	
	[formatter release];
	return results;
}

- (void) getProfilePictures:(NSArray*)items
{
	NSLog(@"getProfilePictures");
	
	if([items count]==0) 
	{
		return;
	}
	
	NSMutableDictionary * map=[[[NSMutableDictionary alloc] init] autorelease];
	// get items that dont have images...
	
	NSMutableDictionary * imageCache=[[[UIApplication sharedApplication] delegate] feedImageCache];
	
	@synchronized(imageCache)
	{
		for(FeedItem * item in items)
		{
			if(item.image==nil)
			{
				if(item.originUrl)
				{
					// lookup image in cache first...
					UIImage * img=[imageCache objectForKey:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",item.originUrl]];
					if(img)
					{
						item.image=img;
					}
					else 
					{
						NSMutableArray * a=[map objectForKey:item.originUrl];
						if(a==nil)
						{
							a=[[[NSMutableArray alloc] init] autorelease];
							[map setObject:a forKey:item.originUrl];
						}
						[a addObject:item];
					}
				}
			}
		}
	}
	
	// get distinct ids
	NSMutableString * ids=[[[NSMutableString alloc] init] autorelease];
	
	for(NSString *from_id in [map allKeys])
	{
		if([ids length]>0)
		{
			[ids appendString:@","];
		}
		[ids appendString:from_id];
	}
	
	if([ids length]==0)
	{
		return;
	}
	
	NSString * graphPath=[NSString stringWithFormat:@"?ids=%@&fields=id,picture",ids];
	
	NSDictionary * json=[facebook getJsonWithGraphPath:graphPath andDelegate:self];
	
	// lookup each id in results...
	for(NSString *from_id in [map allKeys])
	{
		NSDictionary * result=[json objectForKey:from_id];
		if(result)
		{
			NSString * picture_url=[result objectForKey:@"picture"];
			
			//NSString * name=[result objectForKey:@"name"];
			
			NSLog(@"Got %@ for %@",from_id);
			
			// get image from url
			UIImage * img=[[[UIApplication sharedApplication] delegate] getImageFromCache:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",from_id] usingUrl:picture_url];
			
			if(img)
			{
				// assign image to items for this key
				for (FeedItem * item in [map objectForKey:from_id])
				{
					item.image=img;
					/*if (name) 
					{
						item.origin=name;
					}*/
				}
			}
			else 
			{
				NSLog(@"Failed to get image for url %@",picture_url);
			}

		}
		else 
		{
			NSLog(@"Failed to find results for: %@",from_id);
		}
	}
}

- (void)fbDidLogin
{
	NSLog(@"fbDidLogin");
	if (pendingFacebookAction == SHKFacebookPendingLogin)
	{
		[[[UIApplication sharedApplication] delegate] updateSingleAccount:@"Facebook" forCategory:nil];
	}
	[super fbDidLogin];
}

@end
