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
@end
