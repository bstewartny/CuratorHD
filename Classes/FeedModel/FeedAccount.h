//
//  Account.h
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class ItemFetcher;
@class FeedItem;
@class AccountUpdater;

@interface FeedAccount : NSManagedObject
{
	 
}

@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;
@property(nonatomic,retain) NSSet * feeds;
@property(nonatomic,retain) UIImage * image;

- (ItemFetcher*) feedFetcher;

- (BOOL) editable;

- (void) markAsRead:(FeedItem *)item;
- (AccountUpdater*) accountUpdater;

- (BOOL) isValid;

- (void) authorize;


@end
