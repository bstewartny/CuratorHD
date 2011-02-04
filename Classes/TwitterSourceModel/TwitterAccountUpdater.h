//
//  TwitterAccountModel.h
//  Untitled
//
//  Created by Robert Stewart on 11/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountUpdater.h"
#import "TwitterClient.h"

@interface TwitterAccountUpdater : AccountUpdater {
	TwitterClient * client;
}

@end
