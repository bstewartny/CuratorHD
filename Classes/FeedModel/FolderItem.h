//
//  FolderItem.h
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@class Folder;

@interface FolderItem : FeedItem {
	
}
@property(nonatomic,retain) Folder * folder;
@property(nonatomic,retain) NSNumber * displayOrder;

@end
