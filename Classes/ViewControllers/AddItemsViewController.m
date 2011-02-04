#import "AddItemsViewController.h"
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
#import "AddItemsToSectionViewController.h"

@implementation AddItemsViewController
@synthesize tableView,newslettersFetcher,foldersFetcher,itemDelegate;

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
	
	[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[UIView new] autorelease]] autorelease]];
	
	[newslettersFetcher performFetch];
	[foldersFetcher performFetch];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (void)configureCell:(UITableViewCell*)cell 
          atIndexPath:(NSIndexPath*)indexPath
{
	Feed * feed=[[self fetcherForSection:indexPath.section] itemAtIndex:indexPath.row];
	
	cell.accessoryType=UITableViewCellAccessoryNone;
	
	cell.textLabel.text=feed.name;
	
	if([feed isKindOfClass:[Folder class]])
	{
		cell.imageView.image=[UIImage imageNamed:@"32-folderopen.png"];
		
		[cell setBadgeString:[NSString stringWithFormat:@"%d",[[feed currentUnreadCount] intValue]]];
		
	}
	if([feed isKindOfClass:[Newsletter class]])
	{
		cell.imageView.image=[UIImage imageNamed:@"32-newsletter.png"];
		
		int count=0;
		for(NewsletterSection * section in [feed sections])
		{
			count+=[[section items] count];
		}
		[cell setBadgeString:[NSString stringWithFormat:@"%d",count]];
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
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
	return [[self fetcherForSection:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case 0:
			return @"Folders";
		case 1:
			return @"Newsletters";
	}
}

- (ItemFetcher*) fetcherForSection:(NSInteger)section
{
	switch (section) 
	{
		case 0:
			return foldersFetcher;
		case 1:
			return newslettersFetcher;
	}
	return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Feed * feed=[[self fetcherForSection:indexPath.section] itemAtIndex:indexPath.row];
	
	if(indexPath.section==0)
	{
		FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
		
		// add selected items to folder...
		for(FeedItem * item in selectedItems.items)
		{
			[feed addFeedItem:item];
			 
		}
		[feed save];
		[self.tableView reloadData];
		
		FeedViewController * feedView=[[[[UIApplication sharedApplication] delegate] detailNavController] topViewController];
		
		
		[feedView cancelOrganize];
		
		return;
	}
	if(indexPath.section==1)
	{
		AddItemsToSectionViewController * sectionsView=[[AddItemsToSectionViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
		
		sectionsView.newsletter=feed;
		[self.navigationController pushViewController:sectionsView animated:YES];
		
		[sectionsView release];
		
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
	[tableView release];
	[newslettersFetcher release];
	[foldersFetcher release];
	[super dealloc];
}


@end
