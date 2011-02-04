//
//  PagesViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/2/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewslettersViewController : UIViewController {
	NSMutableArray * newsletters;
	IBOutlet UITableView * newslettersTable;
	IBOutlet UIBarButtonItem * editButton;
	IBOutlet UIBarButtonItem * addButton;
}
@property(nonatomic,retain) NSMutableArray * newsletters;
@property(nonatomic,retain) IBOutlet UITableView * newslettersTable;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * editButton;

@property(nonatomic,retain) IBOutlet UIBarButtonItem * addButton;

- (IBAction) newNewsletter;

-(IBAction) toggleEditMode;

@end
