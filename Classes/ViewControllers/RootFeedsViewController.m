#import "RootFeedsViewController.h"
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
#import "FeedAccount.h"
#import "UserSettings.h"

@implementation RootFeedsViewController
@synthesize tableView,sourcesFetcher,newslettersFetcher,foldersFetcher,itemDelegate;

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.tableView.allowsSelectionDuringEditing=YES;
	
	self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditMode:)] autorelease];
				[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"ReloadData"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"FeedsUpdated"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"FeedUpdated"
	 object:nil];
	
	[sourcesFetcher performFetch];
	[newslettersFetcher performFetch];
	[foldersFetcher performFetch];
}

- (IBAction) toggleEditMode:(id)sender
{
	UIBarButtonItem * buttonItem=(UIBarButtonItem*)sender;
	
	if(tableView.editing)
	{
		[tableView setEditing:NO animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleBordered;
		buttonItem.title=@"Edit";
		
		[tableView reloadData];
	}
	else
	{
		[tableView setEditing:YES animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleDone;
		buttonItem.title=@"Done";
		
		[tableView reloadData];
	}
}

-(void)handleReloadData:(NSNotification *)pNotification
{
	[self performSelectorOnMainThread:@selector(handleReloadDataUI:) withObject:pNotification waitUntilDone:YES];
}

-(void)handleReloadDataUI:(NSNotification *)pNotification
{
	if([pNotification.name isEqualToString:@"ReloadData"])
	{
		[sourcesFetcher performFetch];
		[newslettersFetcher performFetch];
		[foldersFetcher performFetch];
		
		[tableView reloadData];
	}
	if([pNotification.name isEqualToString:@"ReloadActionData"])
	{
		[newslettersFetcher performFetch];
		[foldersFetcher performFetch];
		[tableView reloadData];
	}
	/*if([pNotification.name isEqualToString:@"FeedsUpdated"])
	{
		[sourcesFetcher performFetch];
		[newslettersFetcher performFetch];
		[foldersFetcher performFetch];
		[tableView reloadData];
	}*/
} 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	// cant rearrage sources
	if(sourceIndexPath.section==0 || proposedDestinationIndexPath.section==0)
	{
		return sourceIndexPath;
	}
	
	// do NOT allow to move items between sections
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
		// cant move item below the add items button...
		if(proposedDestinationIndexPath.row < [[self fetcherForSection:sourceIndexPath.section] count])
		{
			return proposedDestinationIndexPath;
		}
		else 
		{
			return sourceIndexPath;
		}	
	}
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row >=[[self fetcherForSection:indexPath.section] count])
	{
		switch (indexPath.section) {
			case 0:
				// add source
				[[[UIApplication sharedApplication] delegate] showAccountSettingsForm];
				break;
			case 1:
				// add folder
				[[[UIApplication sharedApplication] delegate] addFolder];
				break;
			case 2:
				// add newsletter
				[[[UIApplication sharedApplication] delegate] addNewsletter];
				
				break;
		}
		return;
	}
	
	switch (indexPath.section) {
		case 0:
		{
			FeedAccount * account=[sourcesFetcher itemAtIndex:indexPath.row];
			
			if([account.name isEqualToString:@"Google Reader"])
			{
				[UserSettings saveSetting:@"googlereader.username" value:nil];
				[UserSettings saveSetting:@"googlereader.password" value:nil];
			}
			
			if([account.name isEqualToString:@"Twitter"])
			{
				[UserSettings saveSetting:@"twitter.username" value:nil];
				[UserSettings saveSetting:@"twitter.password" value:nil];
			}
			
			if([account.name isEqualToString:@"InfoNgen"])
			{
				[UserSettings saveSetting:@"infongen.username" value:nil];
				[UserSettings saveSetting:@"infongen.password" value:nil];
			}
			
			[[[UIApplication sharedApplication] delegate] deleteAccount:account.name];
			
			[sourcesFetcher deleteItemAtIndex:indexPath.row];
		}
			break;
		case 1:
			[foldersFetcher deleteItemAtIndex:indexPath.row];
			break;
		case 2:
			[newslettersFetcher deleteItemAtIndex:indexPath.row];
			break;
	}
	
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadActionData"
	 object:nil];
}

- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return indexPath.section>0 && (indexPath.row < [[self fetcherForSection:indexPath.section] count]);
}

- (void)tableView:(UITableView*)tableView 
moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
	  toIndexPath:(NSIndexPath*)toIndexPath
{
	if(fromIndexPath.section!=toIndexPath.section) return;
	
	ItemFetcher * fetcher=nil;
	if(fromIndexPath.section==1) fetcher=foldersFetcher;
	if(fromIndexPath.section==2) fetcher=newslettersFetcher;
	if(fetcher)
	{
		int fromRow=[fromIndexPath row];
		int toRow=[toIndexPath row];
	
		[fetcher moveItemFromIndex:fromRow toIndex:toRow];
	
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"ReloadActionData"
		 object:nil];
	}
}

- (void)configureCell:(UITableViewCell*)cell 
          atIndexPath:(NSIndexPath*)indexPath
{
	Feed * feed=[[self fetcherForSection:indexPath.section] itemAtIndex:indexPath.row];
	
	if(indexPath.section==0)
	{
		cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	else 
	{
		cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
	if(feed.image)
	{
		cell.imageView.image=feed.image;
	}

	if([feed isKindOfClass:[RssFeed class]])
	{
		int unreadCount=[[feed currentUnreadCount] intValue]; 
		
		if(unreadCount>0)
		{
			[cell setBadgeString:[NSString stringWithFormat:@"%d",unreadCount]];
			cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
		}
		else 
		{
			[cell setBadgeString:nil];
			cell.textLabel.font=[UIFont systemFontOfSize:16];
		}
	}
	else 
	{	
		if([feed isKindOfClass:[Newsletter class]])
		{
			int count=0;
			for(NewsletterSection * section in [feed sections])
			{
				count+=[[section items] count];
			}
			[cell setBadgeString:[NSString stringWithFormat:@"%d",count]];
			cell.imageView.image=[UIImage imageNamed:@"32-newsletter.png"];
		}
		else 
		{
			if([feed isKindOfClass:[Folder class]])
			{
				[cell setBadgeString:[NSString stringWithFormat:@"%d",[[feed items] count] ]];
				cell.imageView.image=[UIImage imageNamed:@"32-folderclosed.png"];
			}
		}
		
		cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
	}
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;
	cell.textLabel.text=feed.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if((tableView.editing && (indexPath.row >= [[self fetcherForSection:indexPath.section] count])) ||
	   ([[self fetcherForSection:indexPath.section] count]==0 ))
	{
		UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
		cell.textLabel.textColor=[UIColor lightGrayColor];
		switch(indexPath.section)
		{
			case 0:
				cell.textLabel.text=@"Add Source";
				break;
			case 1:
				cell.textLabel.text=@"Add Folder";
				break;
			case 2:
				cell.textLabel.text=@"Add Newsletter";
				break;
		}
		cell.selectionStyle=UITableViewCellSelectionStyleGray;
		return cell;
	}

	BadgedTableViewCell * cell = [[[BadgedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
		
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(tableView.editing)
	{
		return [[self fetcherForSection:section] count]+1;
	}
	else 
	{
		int count=[[self fetcherForSection:section] count];
		
		if(count>0)
		{	
			return count;
		}
		else 
		{
			return 1;
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Sources";
		case 1:
			return @"Folders";
		case 2:
			return @"Newsletters";
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	//if(indexPath.section==0) return;
	Feed * feed=nil;
	NSString * promptTitle=nil;
	if(indexPath.section==0)
	{
		[[[UIApplication sharedApplication] delegate] showAccountSettingsForm];
		return;
	}
	if(indexPath.section==1)
	{
		[[[UIApplication sharedApplication] delegate] editFolderName:[foldersFetcher itemAtIndex:indexPath.row]];
		return;
	}
	if(indexPath.section==2)
	{
		[[[UIApplication sharedApplication] delegate] editNewsletterName:[newslettersFetcher itemAtIndex:indexPath.row]];
		return;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row >=[[self fetcherForSection:indexPath.section] count]) 
	{
		return UITableViewCellEditingStyleInsert;
	}
	else 
	{
		return UITableViewCellEditingStyleDelete;
	}
}

- (ItemFetcher*) fetcherForSection:(NSInteger)section
{
	switch (section) 
	{
		case 0:
			return sourcesFetcher;
		case 1:
			return foldersFetcher;
		case 2:
			return newslettersFetcher;
	}
	return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	if(aTableView.editing)
	{
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		
		ItemFetcher * fetcher=[self fetcherForSection:indexPath.section];
		
		if(indexPath.row >=[fetcher count])
		{
			// add new item...
			switch(indexPath.section)
			{
				case 0:
					// add source - show sources form
					[[[UIApplication sharedApplication] delegate] showAccountSettingsForm];
					break;
				case 1:
					// add folder
					[[[UIApplication sharedApplication] delegate] addFolder];
					break;
				case 2:
					// add newsleter
					[[[UIApplication sharedApplication] delegate] addNewsletter];
					break;
			}
			
			return;
		}
	}
	else 
	{
		if(indexPath.row==0)
		{
			if ([[self fetcherForSection:indexPath.section] count]==0) 
			{
				[aTableView deselectRowAtIndexPath:indexPath animated:YES];
				switch(indexPath.section)
				{
					case 0:
						// add source - show sources form
						[[[UIApplication sharedApplication] delegate] showAccountSettingsForm];
						break;
					case 1:
						// add folder
						[[[UIApplication sharedApplication] delegate] addFolder];
						break;
					case 2:
						// add newsleter
						[[[UIApplication sharedApplication] delegate] addNewsletter];
						break;
				}
				
				return;
			}
		}
	}

	
	///if(!aTableView.editing)
	//{
		Feed * feed=[[self fetcherForSection:indexPath.section] itemAtIndex:indexPath.row];
		if(indexPath.section==1)
		{
			[[[UIApplication sharedApplication] delegate] showFolder:feed delegate:self.itemDelegate editable:YES];
			return;
		}
		if(indexPath.section==2)
		{
			[[[UIApplication sharedApplication] delegate] showNewsletter:feed delegate:self.itemDelegate editable:YES];
			return;
		}
		if(indexPath.section==0)
		{
			if([feed respondsToSelector:@selector(feedFetcher)])
			{
				ItemFetcher * feedFetcher=[feed feedFetcher];
				
				if(feedFetcher!=nil)
				{
					FeedsViewController * feedsView=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
					
					feedsView.editable=(indexPath.section>0); //[feed editable];
					feedsView.fetcher=feedFetcher;
					feedsView.title=feed.name;
					feedsView.itemDelegate=self.itemDelegate;
					//feedsView.navigationItem.title=feed.name;
					
					[self.navigationController pushViewController:feedsView animated:YES];
					
					[feedsView release];
				}
				else 
				{
					[[[UIApplication sharedApplication] delegate] showFeed:feed delegate:self.itemDelegate editable:NO];
				}
			}
			else 
			{
				[[[UIApplication sharedApplication] delegate] showFeed:feed delegate:self.itemDelegate editable:NO];
			}
		}
	//}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
	[tableView release];
	[sourcesFetcher release];
	[newslettersFetcher release];
	[foldersFetcher release];
	[super dealloc];
}


@end
