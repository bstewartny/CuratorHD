//
//  FeedGroup.h
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ItemFetcher;

@interface FeedGroup : NSObject  {
	NSString * name;
	UIImage * image;
	BOOL editable;
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic) BOOL editable;

- (ItemFetcher*) feedFetcher;



@end


@interface NewsletterFeedGroup : FeedGroup
{
	
}
@end
@interface FolderFeedGroup:FeedGroup
{
	
}

@end

