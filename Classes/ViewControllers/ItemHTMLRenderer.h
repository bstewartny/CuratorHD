//
//  ItemHTMLRenderer.h
//  Untitled
//
//  Created by Robert Stewart on 11/15/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedItem;
@class Newsletter;
@interface ItemHTMLRenderer : NSObject 
{
	Newsletter * newsletter;
	BOOL embedImageData;
	int maxSynopsisSize;
	BOOL includeSynopsis;
	BOOL useOriginalSynopsis;
	NSDateFormatter * format;
}
@property(nonatomic,retain) Newsletter * newsletter;
@property(nonatomic) BOOL embedImageData;
@property(nonatomic) int maxSynopsisSize;
@property(nonatomic) BOOL includeSynopsis;
@property(nonatomic) BOOL useOriginalSynopsis;

- (id)initWithMaxSynopsisSize:(int)maxSynopsisSize includeSynopsis:(BOOL)includeSynopsis useOriginalSynopsis:(BOOL)useOriginalSynopsis embedImageData:(BOOL)embedImageData;


- (NSString*) getItemHTML:(FeedItem*)item;

@end
