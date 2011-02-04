//
//  SearchViewController.h
//  Untitled
//
//  Created by Robert Stewart on 4/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSearchScopeHeadlines 0
#define kSearchScopeCompanies 1
#define kSearchScopeTopics 2
#define kSearchScopeTrends 3


@class InfoNgenSearchClient;
@class SearchResults;
@class AutocompleteTextField;

@interface SearchViewController : UIViewController <UIActionSheetDelegate,UITextFieldDelegate> {
	//IBOutlet UISearchBar * searchBar;
	IBOutlet UITableView * resultsTable;
	IBOutlet UISegmentedControl * segmentedControl;
	BOOL updating;
	NSDateFormatter * dateFormatter;
	UIView * activityView;
	UIActivityIndicatorView * activityIndicatorView;
	NSArray * results;
	SearchResults * searchResults;
	InfoNgenSearchClient * searchClient;
	NSInteger searchScope;
	NSArray * searchScopeFacetNames;
	IBOutlet AutocompleteTextField * autocompleteTextField;
	//IBOutlet UITextField * searchTextField;
}
//@property(nonatomic,retain) IBOutlet UISearchBar * searchBar;
@property(nonatomic,retain) IBOutlet UITableView * resultsTable;
@property(nonatomic,retain) UIActivityIndicatorView * activityIndicatorView;
@property(nonatomic,retain) UIView * activityView;
@property(nonatomic,retain) NSDateFormatter * dateFormatter;
@property(nonatomic,retain) NSArray * results;
@property(nonatomic,retain) InfoNgenSearchClient * searchClient;
@property(nonatomic,retain) SearchResults * searchResults;
@property(nonatomic,retain) IBOutlet AutocompleteTextField * autocompleteTextField;
//@property(nonatomic,retain) IBOutlet UITextField * searchTextField;

@property(nonatomic,retain) IBOutlet UISegmentedControl * segmentedControl;

- (IBAction) search:(id)sender;

@end
