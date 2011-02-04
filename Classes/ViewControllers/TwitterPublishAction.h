//
//  TwitterPublishAction.h
//  Untitled
//
//  Created by Robert Stewart on 8/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublishAction.h"

@interface TwitterPublishAction : PublishAction {
	int sendTweetButtonIndex;
	int newTweetButtonIndex;
	int retweetButtonIndex;
	int replyButtonIndex;
	int addTweetToFavoritesButtonIndex;
	int addFavoritesButtonIndex;
	int addSourcesButtonIndex;
}

@end
