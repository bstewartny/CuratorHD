#define kMinFeedItemKeyLength 10

#import <Foundation/Foundation.h>
@class FeedItem;

@interface ItemFilter : NSObject <NSCoding> {
	NSMutableDictionary * dict;
	NSDate * minDate;
}
@property(nonatomic,retain) NSMutableDictionary * dict;
@property(nonatomic,retain) NSDate * minDate;

- (BOOL) isNewItem:(FeedItem*) item;
- (BOOL) isUpdated:(FeedItem*) item;

- (BOOL) isOldDate:(NSDate*)date;

- (void) rememberItem:(FeedItem*) item;

- (void) setMinDate:(NSDate*)date;

- (FeedItem*) getItem:(FeedItem*) item;

- (void) clear;

@end
