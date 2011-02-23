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
#import "FormViewController.h"
#import "Folder.h"
#import "Newsletter.h"

#define kAddFolderWithItemsTag 1001
#define kAddNewsletterWithItemsTag 1002

@implementation AddItemsViewController
@synthesize tableView,newslettersFetcher,foldersFetcher,itemDelegate;


- (void) formViewDidCancel:(NSInteger)tag
{
	
}

- (void) formViewDidFinish:(NSInteger)tag withValues:(NSArray*)values
{
	NSLog(@"formViewDidFinish tag: %d",tag);
	if(tag==kAddFolderWithItemsTag)
	{
		NSString * folderName=[values objectAtIndex:0];
		
		if([folderName length]>0)
		{
			NSLog(@"create folder with name: %@",folderName);
			Folder * newFolder=[[[UIApplication sharedApplication] delegate] createNewFolder:folderName];
			
			// add selected items to new folder...
			FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
			
			// add selected items to folder...
			for(FeedItem * item in selectedItems.items)
			{
				[newFolder addFeedItem:item];
				
			}
			[newFolder save];
			[self.foldersFetcher performFetch];
			[self.tableView reloadData];
			
			FeedViewController * feedView=[[[[UIApplication sharedApplication] delegate] detailNavController] topViewController];
			
			
			[feedView cancelOrganize];
		}
		return;
	}
	
	if(tag==kAddNewsletterWithItemsTag)
	{
		NSString * newsletterName=[values objectAtIndex:0];
		NSString * sectionName=[values objectAtIndex:1];
		
		if ([newsletterName length]>0) 
		{
			Newsletter * newNewsletter=[[[UIApplication sharedApplication] delegate] createNewNewsletter:newsletterName sectionName:sectionName];
			
			
			[newslettersFetcher performFetch];
			[tableView reloadData];
		}
	}
}



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
	
	self.tableView.separatorColor=[UIColor darkGrayColor];
	 
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	self.tableView.backgroundView.backgroundColor=[UIColor blackColor];
	self.tableView.backgroundView.alpha=0.5;
	
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
	ItemFetcher * fetcher=[self fetcherForSection:indexPath.section];
	
	
	
	cell.backgroundColor=[UIColor clearColor];
	
	cell.textLabel.font=[UIFont boldSystemFontOfSize:17];
	 
	cell.textLabel.textColor=[UIColor whiteColor];
	cell.textLabel.shadowColor=[UIColor blackColor];
	cell.textLabel.shadowOffset=CGSizeMake(0, 1);
	
	
	
	
	
	
	
	
	
	
	
	
	if([fetcher count]<=indexPath.row)
	{
		if(indexPath.section==0)
		{
			cell.accessoryType=UITableViewCellAccessoryNone;
			cell.textLabel.textColor=[UIColor lightGrayColor];
			cell.textLabel.text=@"Add Folder";
		}
		else 
		{
			cell.accessoryType=UITableViewCellAccessoryNone;
			cell.textLabel.textColor=[UIColor lightGrayColor];
			cell.textLabel.text=@"Add Newsletter";
		}
	}
	else 
	{
		
		Feed * feed=[fetcher itemAtIndex:indexPath.row];
		
		cell.accessoryType=UITableViewCellAccessoryNone;
		
		cell.textLabel.text=feed.name;
		
		if([feed isKindOfClass:[Folder class]])
		{
			cell.imageView.image=[UIImage imageNamed:@"32-folderopen.png"];
			int count=[feed itemCount];
			[cell setBadgeString:[NSString stringWithFormat:@"%d",count ]];
			//[cell setBadgeString:[NSString stringWithFormat:@"%d",[[feed currentUnreadCount] intValue]]];
			
		}
		if([feed isKindOfClass:[Newsletter class]])
		{
			cell.imageView.image=[UIImage imageNamed:@"32-newsletter.png"];
			
			int count=[feed itemCount];
			/*for(NewsletterSection * section in [feed sections])
			{
				count+=[[section items] count];
			}*/
			[cell setBadgeString:[NSString stringWithFormat:@"%d",count]];
			cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		}
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
	return [[self fetcherForSection:section] count]+1;
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

- (void) addFolder
{
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Add folder" tag:kAddFolderWithItemsTag delegate:self names:[NSArray arrayWithObject:@"Folder name"] andValues:nil];
	[self presentModalViewController:formView animated:YES];
	
	[formView release];
}

- (void) addNewsletter
{
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Add newsletter" tag:kAddNewsletterWithItemsTag delegate:self names:[NSArray arrayWithObjects:@"Newsletter name",@"Section name",nil] andValues:nil];
	[self presentModalViewController:formView animated:YES];

	[formView release];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	ItemFetcher * fetcher=[self fetcherForSection:indexPath.section];
	
	if([fetcher count]<=indexPath.row)
	{
		// add folder/newsletter row
		if(indexPath.section==0)
		{
			// add new folder
			[self addFolder];
			return;
			
		}
		else 
		{
			// add new newsletter
			[self addNewsletter];
			return;
		}
	}
	else 
	{
		Feed * feed=[fetcher itemAtIndex:indexPath.row];
		
		if(indexPath.section==0)
		{
			FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
			
			// add selected items to folder...
			for(FeedItem * item in selectedItems.items)
			{
				[feed addFeedItem:item];
				 
			}
			[feed save];
			[self.foldersFetcher performFetch];
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
