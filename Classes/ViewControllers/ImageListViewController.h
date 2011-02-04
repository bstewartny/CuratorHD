//
//  ImageListViewController.h
//  Untitled
//
//  Created by Robert Stewart on 8/13/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedItem;

@interface ImageListViewController : UIViewController {
	FeedItem * item;
	IBOutlet UIScrollView * scrollView;
	NSMutableArray * images;
	BOOL cancelDownloads;
	UIView * contentView;
	id delegate;
	UIActivityIndicatorView * activityView;
	
}
@property(nonatomic,retain) FeedItem * item;
@property(nonatomic,retain) IBOutlet UIScrollView * scrollView;
@property(nonatomic,retain) NSMutableArray * images;
@property(nonatomic,assign) id delegate;

- (void) touchImage:(id)sender;

@end
