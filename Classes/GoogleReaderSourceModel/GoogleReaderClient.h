#define kGoogleReaderClientName @"InfoNgen-iPad/0.1"
#define kGoogleReaderMaxNumberOfItems 50

#import <Foundation/Foundation.h>
@class ItemFilter;
@class FeedItem;
typedef enum {
	GoogleReaderFeedTypeAllItems = 0,
	GoogleReaderFeedTypeSharedItems,
	GoogleReaderFeedTypeStarredItems,
	GoogleReaderFeedTypeTaggedItems,
	GoogleReaderFeedTypeFriendsSharedItems,
	GoogleReaderFeedTypeFollowingItems,
	GoogleReaderFeedTypeNotes
} GoogleReaderFeedType;

@interface GoogleReaderClient : NSObject {
	
	NSString * username;
	NSString * password;
}
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;

- (BOOL) isValid;

- (id) initWithUsername:(NSString*)username password:(NSString*)password;

- (id) initWithUsername:(NSString*)username password:(NSString*)password useCachedAuth:(BOOL)useCachedAuth;

- (NSArray*) getSubscriptionList:(NSMutableDictionary*)imageCache;

- (NSArray*) getTags;

- (NSArray*) getItems:(GoogleReaderFeedType)feedType tag:(NSString*)tag filter:(ItemFilter*)filter;

- (NSArray*) getFollowingItems:(ItemFilter*)filter;

- (NSArray*) getSharedItems:(ItemFilter*)filter;

- (NSArray*) getStarredItems:(ItemFilter*)filter;
- (NSArray*) getNotes:(ItemFilter*)filter;

- (NSArray*) getAllItems:(ItemFilter*)filter;

- (NSArray*) getTaggedItems:(NSString*)tag filter:(ItemFilter*)filter;

- (void) markAsRead:(FeedItem*)item;

@end
