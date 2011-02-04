//
//  MetaNameResolver.h
//  Untitled
//
//  Created by Robert Stewart on 4/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetaNameValue;

@interface MetaNameResolver : NSObject<NSCoding> {
	NSDate * lastUpdated;
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property(nonatomic,retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void) update:(NSString*)url username:(NSString*)username password:(NSString*)password;

- (MetaNameValue*) resolveByName:(NSString*)name value:(NSString*)value;

- (NSArray*) lookupByName:(NSString*)name displayValue:(NSString*)displayValue;

- (BOOL) isExpired;

- (NSUInteger) countMetaNames;


@end
