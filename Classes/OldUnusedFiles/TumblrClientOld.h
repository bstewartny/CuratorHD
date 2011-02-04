//
//  TumblrClient.h
//  Untitled
//
//  Created by Robert Stewart on 6/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedAccount;

typedef enum {
	TumblrPostTypeRegular = 0,
	TumblrPostTypePhoto,
	TumblrPostTypeQuote,
	TumblrPostTypeLink,
	TumblrPostTypeConversation,
	TumblrPostTypeVideo,
	TumblrPostTypeAudio
} TumblrPostType;

typedef enum {
	TumblrStatePublished = 0,
	TumblrStateDraft,
	TumblrStateSubmission,
	TumblrStateQueue
} TumblrState;

@interface TumblrPost : NSObject
{
	BOOL private;
	NSArray * tags;
	NSString * slug;
	TumblrState state;
	TumblrPostType type;
	
	NSString * title;
	NSString * body;
	
	NSString * photo_source;
	NSString * photo_data;
	NSString * photo_caption;
	NSString * photo_click_through_url;
	
	NSString * quote;
	NSString * quote_source;
	
	NSString * link_name;
	NSString * link_url;
	NSString * link_description;
	
	NSString * video_embed;
	NSString * video_data;
	NSString * video_title;
	NSString * video_caption;
	
	NSString * audio_data;
	NSString * audio_externally_hosted_url;
	NSString * audio_caption;
} 
@property(nonatomic) BOOL private;
@property(nonatomic,retain) NSArray * tags;
@property(nonatomic,retain) NSString * slug;
@property(nonatomic) TumblrState state;
@property(nonatomic) TumblrPostType type ;

@property(nonatomic,retain) NSString * title;
@property(nonatomic,retain) NSString * body;
@property(nonatomic,retain) NSString * photo_source;
@property(nonatomic,retain) NSString * photo_data;
@property(nonatomic,retain) NSString * photo_caption;
@property(nonatomic,retain) NSString * photo_click_through_url;
@property(nonatomic,retain) NSString * quote;
@property(nonatomic,retain) NSString * quote_source;
@property(nonatomic,retain) NSString * link_name;
@property(nonatomic,retain) NSString * link_url;
@property(nonatomic,retain) NSString * link_description;
@property(nonatomic,retain) NSString * video_embed;
@property(nonatomic,retain) NSString * video_data;
@property(nonatomic,retain) NSString * video_title;
@property(nonatomic,retain) NSString * video_caption;
@property(nonatomic,retain) NSString * audio_data;
@property(nonatomic,retain) NSString * audio_externally_hosted_url;
@property(nonatomic,retain) NSString * audio_caption;

- (id) initWithType:(TumblrPostType)type;

@end
@interface TumblrClient : NSObject {
	NSString * username;
	NSString * password; 
}
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;

- (id) initWithUsername:(NSString*)username password:(NSString*)password;

@end
