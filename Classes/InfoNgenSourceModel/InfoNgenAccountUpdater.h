//
//  InfoNgenAccountUpdater.h
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountUpdater.h"
#import <CoreData/CoreData.h>
@interface InfoNgenAccountUpdater : AccountUpdater {
	BOOL _isAccountValid;
}

@end
