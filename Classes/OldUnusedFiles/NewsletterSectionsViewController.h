//
//  NewsletterSectionsViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Newsletter ;

@interface NewsletterSectionsViewController : UIViewController {
	IBOutlet UITableView * sectionsTable;
	Newsletter * newsletter;
	IBOutlet UIBarButtonItem * editButton;
	IBOutlet UIBarButtonItem * addButton;
}
@property(nonatomic,retain) IBOutlet UITableView * sectionsTable;
@property(nonatomic,retain) Newsletter * newsletter;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * editButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * addButton;

- (IBAction) addSavedSearch;
-(IBAction) toggleEditMode;
@end
