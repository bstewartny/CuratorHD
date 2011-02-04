//
//  AppSettingsViewController.h
//  Untitled
//
//  Created by Robert Stewart on 9/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppSettingsViewController : UIViewController {
	IBOutlet UITableView * tableView;
	
}
@property(nonatomic,retain) IBOutlet UITableView * tableView;

- (IBAction) save:(id)sender;
- (IBAction) cancel:(id)sender;

@end
