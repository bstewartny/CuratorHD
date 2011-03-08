//
//  Page.h
//  Untitled
//
//  Created by Robert Stewart on 2/4/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemFetcher;
@class NewsletterSection;
@class Font;

@interface Newsletter  : NSManagedObject {
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) UIImage * logoImage;
@property(nonatomic,retain) NSDate * lastPublished;
@property(nonatomic,retain) NSString * logoImageUrl;
@property(nonatomic,retain) NSSet * sections;
@property(nonatomic,retain) NSString * summary;
@property(nonatomic,retain) NSNumber * displayOrder;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic,retain) NSNumber * isFavorite;

@property(nonatomic,retain) Font * titleFont;

@property(nonatomic,retain) Font * commentsFont;

@property(nonatomic,retain) Font * sectionFont;

@property(nonatomic,retain) Font * headlineFont;

@property(nonatomic,retain) Font * bodyFont;

@property(nonatomic,retain) Font * summaryFont;


/*@property(nonatomic,retain) NSNumber * clearOnPublish;
@property(nonatomic,retain) NSNumber * maxSynopsisSize;
@property(nonatomic,retain) NSString * templateName;
@property(nonatomic,retain) NSString * headlineColor;
@property(nonatomic,retain) NSString * sectionColor;
@property(nonatomic,retain) NSString * commentColor;
*/



- (void) clearAllItems;
- (BOOL) needsUploadImages;
- (void) uploadImages;
- (int) itemCount;
 
- (int) entityCount:(NSString*)entityName predicate:(NSPredicate*)predicate;

- (ItemFetcher*) feedFetcher;
- (NSArray*) sortedSections;

- (NewsletterSection*) addSection;

- (void) save;
- (void) delete;

+ (Newsletter*) createInContext:(NSManagedObjectContext*)moc;


@end
