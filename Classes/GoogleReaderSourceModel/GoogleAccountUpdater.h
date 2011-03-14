#import <Foundation/Foundation.h>
#import "AccountUpdater.h"
@class GoogleReaderClient;
@interface GoogleAccountUpdater : AccountUpdater {
	GoogleReaderClient * client;
	NSMutableDictionary * readingListFeedCache;
	BOOL useReadingListFeedCache;
}
@property(nonatomic,retain) GoogleReaderClient * client;
@property(nonatomic) BOOL useReadingListFeedCache; 

- (NSArray*) getMostRecentReaderItems:(RssFeed*)feed maxItems:(int)maxItems minDate:(NSDate*)minDate;

@end
