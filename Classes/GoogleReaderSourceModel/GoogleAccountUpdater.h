//
//  GoogleAccountUpdater.h
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

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
