//
//  GoogleReaderAtomFeed.h
//  Untitled
//
//  Created by Robert Stewart on 7/6/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecureFeed.h"

@interface GoogleReaderAtomFeed : SecureFeed {
	NSString * feedId;
	NSString * atomUrl;
	NSString * htmlUrl;
}
@property(nonatomic,retain) NSString * feedId;
@property(nonatomic,retain) NSString * atomUrl;
@property(nonatomic,retain) NSString * htmlUrl;



@end
