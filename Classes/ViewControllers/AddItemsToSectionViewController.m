#import "AddItemsToSectionViewController.h"
#import "Feed.h"
#import "FeedGroup.h"
//#import "AddFeedViewController.h"
#import "FeedViewController.h"
#import "Newsletter.h"
#import "ItemFetcher.h"
#import "FeedFetcher.h"
#import "FeedItemDictionary.h"
#import "NewsletterSection.h"
#import <QuartzCore/QuartzCore.h>
#import "BadgedTableViewCell.h"
#import "FeedsViewController.h"
#import "FolderViewController.h"

@implementation AddItemsToSectionViewController
@synthesize tableView,newsletter;

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

- (void) close
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.navigationItem.title=@"Add Selected Items";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (void)configureCell:(UITableViewCell*)cell 
          atIndexPath:(NSIndexPath*)indexPath
{
	NewsletterSection * section=[[newsletter sortedSections] objectAtIndex:indexPath.row];
	
	cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
	cell.accessoryType=UITableViewCellAccessoryNone;
	
	cell.textLabel.text=section.name;
	
	[cell setBadgeString:[NSString stringWithFormat:@"%d",[[section items]count]]];
	 
	cell.imageView.image=[UIImage imageNamed:@"32-folderopen.png"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BadgedTableViewCell * cell = [[[BadgedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [newsletter.sections count]; //  [[self fetcherForSection:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return newsletter.name;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NewsletterSection * section=[[newsletter sortedSections] objectAtIndex:indexPath.row];

	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	// add selected items to folder...
	for(FeedItem * item in selectedItems.items)
	{
		[section addFeedItem:item];
	}
	[section save]; 
	
	[self.tableView reloadData];
	
	FeedViewController * feedView=[[[[UIApplication sharedApplication] delegate] detailNavController] topViewController];
	
	[feedView cancelOrganize];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
	[newsletter release];
	[super dealloc];
}


@end
