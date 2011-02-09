//
//  SearchResult.h
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSString (InfoNgen_NSString)

- (NSString*) stringByReplacingOccurrencesOfStringIfExists:(NSString*)target withString:(NSString*)replacement;

- (NSString *)flattenHTML;

@end;




@interface ImageToDataTransformer : NSValueTransformer 
{
}
@end
@class FeedItem;

@interface TempFeedItem : NSObject 
{
	NSString * headline;
	NSString * synopsis;
	NSString * origSynopsis;
	NSString * url;
	NSDate * date;
	NSString * notes;
	UIImage * image;
	NSString * imageUrl;
	NSString * origin;
	NSString * originId;
	NSString * originUrl;
	NSString * uid;
	NSNumber * isRead;
	//BOOL isSelected;
}
@property(nonatomic,retain) NSString * headline;
@property(nonatomic,retain) NSString * synopsis;
@property(nonatomic,retain) NSString * origSynopsis;
@property(nonatomic,retain) NSString * url;
@property(nonatomic,retain) NSDate * date;
@property(nonatomic,retain) NSString * notes;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic,retain) NSString * imageUrl;
@property(nonatomic,retain) NSString * origin;
@property(nonatomic,retain) NSString * originId;
@property(nonatomic,retain) NSString * originUrl;
@property(nonatomic,retain) NSString * uid;
@property(nonatomic,retain) NSNumber * isRead;
@property(nonatomic,retain) NSNumber * isStarred;
@property(nonatomic,retain) NSNumber * isShared;
//@property(nonatomic) BOOL isSelected;
- (NSString*) key;

- (void) save;
- (void) delete;

+ (TempFeedItem*) copyItem:(FeedItem*)item;

@end





@interface FeedItem : NSManagedObject 
{
}
@property(nonatomic,retain) NSString * headline;
@property(nonatomic,retain) NSString * synopsis;
@property(nonatomic,retain) NSString * origSynopsis;
@property(nonatomic,retain) NSString * url;
@property(nonatomic,retain) NSDate * date;
@property(nonatomic,retain) NSString * notes;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic,retain) NSString * imageUrl;
@property(nonatomic,retain) NSString * origin;
@property(nonatomic,retain) NSString * originId;
@property(nonatomic,retain) NSString * originUrl;
@property(nonatomic,retain) NSString * uid;
@property(nonatomic,retain) NSNumber * isRead;
@property(nonatomic,retain) NSNumber * isStarred;
@property(nonatomic,retain) NSNumber * isShared;
//@property(nonatomic) BOOL isSelected;

//- (id) initWithHeadline:(NSString *)theHeadline withUrl:(NSString *) theUrl withSynopsis:(NSString*)theSynopsis withDate:(NSDate*)theDate;

- (NSString*) relativeDateOffset;
+ (NSString*) normalizeSynopsis:(NSString*)s;
+ (NSString*) normalizeHeadline:(NSString*)s;
- (NSString*) shortDisplayDate;
- (void) save;
- (void) delete;
- (NSString*) key;
- (void) markAsRead;
- (void) copyAttributes:(FeedItem*)item;

@end

