//
//  NewsletterPublishAction.h
//  Untitled
//
//  Created by Robert Stewart on 6/21/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublishAction.h"

@class Newsletter;

@interface NewsletterPublishAction : PublishAction <UIActionSheetDelegate,UIAlertViewDelegate> {
	Newsletter * newsletter;
	int openNewsletterButtonIndex;
	int addItemsToSectionButtonIndex;
	int addItemsToNewSectionButtonIndex;
	int addFavoritesButtonIndex;
	int deleteNewsletterButtonIndex;
}

@property(nonatomic,retain) Newsletter * newsletter;


@end
