//
//  MasterViewController.h
//  Untitled
//
//  Created by Robert Stewart on 2/2/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface SavedSearchesViewController : UIViewController {
	IBOutlet UINavigationController *savedSearchNavController;
}
@property (nonatomic,retain) IBOutlet UINavigationController *savedSearchNavController;

@end
