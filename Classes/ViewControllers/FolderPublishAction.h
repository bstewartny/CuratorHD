//
//  FolderPublishAction.h
//  Untitled
//
//  Created by Robert Stewart on 6/21/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublishAction.h"

@class Folder;

@interface FolderPublishAction : PublishAction {
	Folder  * folder;
	int addItemsButtonIndex;
	int createNewItemButtonIndex;
	int showItemsButtonIndex;
	int addFavoritesButtonIndex;
	int deleteFolderButtonIndex;
	int addNewNoteButtonIndex;
}
@property(nonatomic,retain) Folder * folder;

@end
