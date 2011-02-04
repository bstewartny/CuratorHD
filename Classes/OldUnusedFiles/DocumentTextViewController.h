//
//  DocumentTextViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchResult;

@interface DocumentTextViewController : UIViewController {
	SearchResult * searchResult;
	NSString * text;
	IBOutlet UITextView * textView;
}

@property(nonatomic,retain) SearchResult * searchResult;
@property(nonatomic,retain) NSString * text;
@property(nonatomic,retain) IBOutlet UITextView * textView;

- (IBAction) select;
- (IBAction) cancel;

@end
