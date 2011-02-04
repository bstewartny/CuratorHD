//
//  NewsletterDistributionListViewController.h
//  Untitled
//
//  Created by Robert Stewart on 3/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define kAddressesSection 0

#define kAddAddressSection 1

@class Newsletter;


@interface NewsletterDistributionListViewController : UIViewController {
	IBOutlet UITableView * addressTable;
	Newsletter * newsletter;
}

@property(nonatomic,retain) IBOutlet UITableView * addressTable;
@property(nonatomic,retain) Newsletter * newsletter;

- (void) edit:(id)sender;
- (void)editDone:(id)sender;


@end
