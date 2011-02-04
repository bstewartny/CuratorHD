//
//  FeedFetcher.h
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemFetcher.h"
#import <CoreData/CoreData.h>

@interface AccountFetcher : ItemFetcher
{
	
}

@end


@interface AccountFeedFetcher : ItemFetcher {
	NSString * accountName;
}
@property(nonatomic,retain) NSString * accountName;

@end

 
@interface AccountUpdatableFeedFetcher: AccountFeedFetcher  {
	 
}
 
@end

@interface CategoryFeedFetcher : AccountFeedFetcher {
	NSString * feedCategory;
}
@property(nonatomic,retain) NSString * feedCategory;


@end

@interface FolderFetcher:ItemFetcher
{
	
}

@end

@interface NewsletterFetcher : ItemFetcher
{
	
}
@end

@interface NewsletterSectionFetcher: ItemFetcher
{
	Newsletter * newsletter;
}
@property(nonatomic,retain) Newsletter * newsletter;

@end





