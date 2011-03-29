//
//  Feed.h
//  Untitled
//
//  Created by Robert Stewart on 5/20/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class ItemFetcher;

@interface TempFeedCategory:NSObject
{
	NSString * name;
}
@property(nonatomic,retain) NSString * name;

@end



@interface TempFeed : NSObject {
	NSString * name;
	NSString * feedType;
	NSString * url;
	NSString * htmlUrl;
	NSString * feedId;
	UIImage	 * image;
	NSSet * feedCategory;
	NSString * imageName;
	NSString * highlightedImageName;
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * feedType;
@property(nonatomic,retain) NSString * url;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic,retain) NSSet * feedCategory;
@property(nonatomic,retain) NSString * htmlUrl;
@property(nonatomic,retain) NSString * feedId;
@property(nonatomic,retain) NSString * imageName;
@property(nonatomic,retain) NSString * highlightedImageName;

- (void) save;
- (void) delete;
- (void) markAllAsRead;
- (void) deleteOlderThan:(int)days;
- (void) deleteReadItems;
@end

@interface Feed : NSManagedObject {
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSDate * lastUpdated;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic,retain) NSString * imageName;
@property(nonatomic,retain) NSString * highlightedImageName;
@property(nonatomic,retain) NSString * summary;
@property(nonatomic,retain) NSString * feedType;
@property(nonatomic,retain) NSSet * feedCategory;
@property(nonatomic,retain) NSString * url;
@property(nonatomic,retain) NSString * htmlUrl;
@property(nonatomic,retain) NSString * feedId;
@property(nonatomic,retain) NSNumber * unreadCount;

- (void) save;
- (void) delete;
- (BOOL) editable;
- (void) markAllAsRead;
- (void) deleteOlderThan:(int)days;
- (void) deleteReadItems;
- (NSNumber*) currentUnreadCount;
- (int) itemCount;

- (ItemFetcher*) itemFetcher;
- (void) updateUnreadCount;
- (int) entityCount:(NSString*)entityName predicate:(NSPredicate*)predicate;
- (void) setFeedCategoryNames:(NSArray*)categoryNames;
- (BOOL) hasFeedCategory:(NSString*)categoryName;
- (BOOL) hasSameCategories:(NSArray*)categoryNames;

@end
