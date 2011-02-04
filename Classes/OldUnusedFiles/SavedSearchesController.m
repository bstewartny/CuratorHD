    //
//   SavedSearchesController.m
//  Untitled
//
//  Created by Robert Stewart on 2/3/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SavedSearchesController.h"
#import "SavedSearchController.h"
#import "AppDelegate.h"
#import "SavedSearchesViewController.h"
#import "SavedSearch.h"

@implementation SavedSearchesController
@synthesize controllers;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	NSLog(@"SavedSearchesController.viewDidLoad");
	self.title=@"Saved Searches";
	
	NSMutableArray *array=[[NSMutableArray alloc] init];
	
	// get saved searches from delegate...
	AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	for (int i=0; i<[delegate.savedSearches count]; i++) 
	{
		SavedSearchController *ss=[[SavedSearchController alloc] initWithStyle:UITableViewStylePlain];
					
		SavedSearch * savedSearch=[delegate.savedSearches objectAtIndex:i];
		
		ss.savedSearch=savedSearch;
		ss.title=savedSearch.name;
		
		[array addObject:ss];
		
		[ss release];
	}
	
	self.controllers=array;
	[array release];
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[controllers release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section{
	
	return [self.controllers count];
}

- (UITableViewCell * )tableView:(UITableView*)tableView
		  cellForRowAtIndexPath:(NSIndexPath*)indexPath{
	static NSString * rootViewControllerCell=@"RootViewControllerCell";
	UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:rootViewControllerCell];
	if(cell==nil){
		cell=[[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:rootViewControllerCell] autorelease];
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	SavedSearchController * controller = [controllers objectAtIndex:indexPath.row];
	cell.textLabel.text=controller.savedSearch.name;
	return cell;
}

/*- (UITableViewCellAccessoryType)tableView:(UITableView*)tableView
accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}*/

-(void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	SavedSearchController *nextController=[self.controllers objectAtIndex:indexPath.row];
	AppDelegate * delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	SavedSearchesViewController * savedSearchesViewController=delegate.savedSearchesViewController;
	UINavigationController * nav = savedSearchesViewController.savedSearchNavController;
	[nav pushViewController:nextController animated:YES];
}

@end
