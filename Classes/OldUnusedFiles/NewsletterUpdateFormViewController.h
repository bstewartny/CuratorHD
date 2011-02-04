//
//  NewsletterUpdateFormViewController.h
//  Untitled
//
//  Created by Robert Stewart on 4/7/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsletterSection;

@interface NewsletterUpdateFormViewController : UIViewController {
	NSArray * sections;
	IBOutlet UITableView * tableView;
	IBOutlet UIBarButtonItem * cancelButton;
	NSArray * tableCells;
	NSArray * sectionStatus;
	BOOL cancelled;
}
@property(nonatomic,retain) NSArray * sections;
@property(nonatomic,retain) NSArray * tableCells;

@property(nonatomic,retain) IBOutlet UITableView * tableView;
@property(nonatomic,retain) IBOutlet UIBarButtonItem * cancelButton;
@property(nonatomic,retain) NSArray * sectionStatus;

- (IBAction) cancel:(id)sender;

- (UITableViewCell*) getCellForSection:(NewsletterSection*)section;

- (void) startProgressForSection:(NewsletterSection*)section;
- (void) endProgressForSection:(NewsletterSection*)section;
- (void) setStatusText:(NSString*)status forSection:(NewsletterSection*)section;
- (void) endUpdate;
- (BOOL) isCancelled;

@end
