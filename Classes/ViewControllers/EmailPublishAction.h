//
//  EmailPublishAction.h
//  Untitled
//
//  Created by Robert Stewart on 6/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublishAction.h"
#import <MessageUI/MessageUI.h>

typedef enum {
	EmailTypeLinks = 0,
	EmailTypeText,
	EmailTypeHTML
} EmailType;

@interface EmailPublishAction : PublishAction<MFMailComposeViewControllerDelegate> {
	UIActivityIndicatorView * activityIndicatorView;
	UIView * activityView;
	UILabel * activityTitleLabel;
	UILabel * activityStatusLabel;
	UIProgressView * activityProgressView;
	int emailLinksButtonIndex;
	int emailFullTextButtonIndex;
	int composeEmailButtonIndex;
	int addFavoritesButtonIndex;
}
@property(nonatomic,retain) UIActivityIndicatorView * activityIndicatorView;
@property(nonatomic,retain) UIView * activityView;
@property(nonatomic,retain) UILabel * activityTitleLabel;
@property(nonatomic,retain) UILabel * activityStatusLabel;
@property(nonatomic,retain) UIProgressView * activityProgressView;
@end
