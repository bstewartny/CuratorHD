//
//  FacebookAccountUpdater.h
//  Untitled
//
//  Created by Robert Stewart on 11/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountUpdater.h"
#import "FacebookClient.h"

@interface FacebookAccountUpdater : AccountUpdater {
	FacebookClient * client;
	BOOL didUpdateFeedList;
}


@end
