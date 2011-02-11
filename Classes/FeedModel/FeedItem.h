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

