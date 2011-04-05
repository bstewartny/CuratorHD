#import "AddItemsViewController.h"
#import "Feed.h"
#import "FeedGroup.h"
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
#import "FeedsTableViewCell.h"

#define kAddFolderWithItemsTag 1001
#define kAddNewsletterWithItemsTag 1002

@implementation AddItemsViewController
@synthesize tableView,newslettersFetcher,foldersFetcher,delegate;

- (void) formViewDidCancel:(NSInteger)tag
{
}

- (void) formViewDidFinish:(NSInteger)tag withValues:(NSArray*)values
{
	if(tag==kAddFolderWithItemsTag)
	{
		NSString * folderName=[values objectAtIndex:0];
		 
		if([folderName length]>0)
		{
			Folder * newFolder=[[[UIApplication sharedApplication] delegate] createNewFolder:folderName];
			
			/*if([self selectedItemCount]>10)
			{
				// The hud will dispable all input on the view
				HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
				
				// Add HUD to screen
				[self.view.window addSubview:HUD];
				
				// Regisete for HUD callbacks so we can remove it from the window at the right time
				HUD.delegate = self;
				
				HUD.labelText=@"Adding selected items...";
				
				// Show the HUD while the provided method executes in a new thread
				[HUD showWhileExecuting:@selector(addToFolder:) onTarget:delegate withObject:newFolder animated:YES];
			}
			else 
			{*/
				//[delegate addToFolder:newFolder];
				[self.foldersFetcher performFetch];
				[self.tableView reloadData];
				//[self performSelector:@selector(cancelOrganize) withObject:nil afterDelay:0.5];
			//}
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

- (int) selectedItemCount
{
	return [[[[UIApplication sharedApplication] delegate] selectedItems] count];
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
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	self.tableView.backgroundView.backgroundColor=[UIColor blackColor];
	self.tableView.backgroundView.alpha=0.5;
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
		cell.accessoryType=UITableViewCellAccessoryNone;
		cell.textLabel.textColor=[UIColor lightGrayColor];
		if(indexPath.section==0)
		{
			cell.textLabel.text=@"Add New Folder";
		}
		else 
		{
			cell.textLabel.text=@"Add New Newsletter";
		}
	}
	else 
	{
		Feed * feed=[fetcher itemAtIndex:indexPath.row];
		
		cell.accessoryType=UITableViewCellAccessoryNone;
		
		cell.textLabel.text=feed.name;
		
		[cell setBadgeString:[NSString stringWithFormat:@"%d",[feed itemCount]]];
		
		if([feed isKindOfClass:[Folder class]])
		{
			cell.imageView.image=[UIImage imageNamed:@"green_folderopen.png"];
			cell.imageView.highlightedImage=[UIImage imageNamed:@"green_folderdoc.png"];
			
			// total hack, but dont know any other way to keep selection state when reloading a cell...
			if(selectedIndexPath)
			{
				if(indexPath.section==selectedIndexPath.section &&
				   indexPath.row==selectedIndexPath.row)
				{
					cell.imageView.image=[UIImage imageNamed:@"green_folderdoc.png"];
				}
			}
		}
		else 
		{
			if([feed isKindOfClass:[Newsletter class]])
			{
				cell.imageView.image=[UIImage imageNamed:@"green_newsletter.png"];
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			}
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FeedsTableViewCell * cell = [[[FeedsTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self fetcherForSection:section] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 23;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView * v=[[UIView alloc] initWithFrame:CGRectZero];
	v.backgroundColor=[UIColor clearColor];
	v.frame=CGRectMake(0,0,320,44);
	return [v autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView * v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self tableView:tableView heightForHeaderInSection:section])];
	v.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	v.alpha=0.8;
	
	UILabel * label=[[UILabel alloc] init];
	
	label.textColor=[UIColor whiteColor];
	label.font=[UIFont boldSystemFontOfSize:17];
	label.shadowColor=[UIColor blackColor];
	label.shadowOffset=CGSizeMake(0, 1);
	
	switch (section) 
	{
		case 0:
			label.text= @"Folders";
			break;
		case 1:
			label.text= @"Newsletters";
			break;
	}
	label.backgroundColor=[UIColor clearColor];
	
	[label sizeToFit];
	
	CGRect f=label.frame;
	f.origin.x=5;
	f.origin.y=v.frame.size.height-(f.size.height+2);
	label.frame=f;
	
	[v addSubview:label];
	
	[label release];
	
	return [v autorelease];
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
	[selectedIndexPath release];
	selectedIndexPath=nil;
	
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
			selectedIndexPath=[indexPath retain];
			
			if([self selectedItemCount]>10)
			{
				// The hud will dispable all input on the view
				HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
				
				// Add HUD to screen
				[self.view.window addSubview:HUD];
				
				// Regisete for HUD callbacks so we can remove it from the window at the right time
				HUD.delegate = self;
				
				HUD.labelText=@"Adding selected items...";
				
				// Show the HUD while the provided method executes in a new thread
				[HUD showWhileExecuting:@selector(addToFolder:) onTarget:delegate withObject:feed animated:YES];
			}
			else 
			{
				[delegate addToFolder:feed];
				[self.foldersFetcher performFetch];
				[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				[self performSelector:@selector(cancelOrganize) withObject:nil afterDelay:0.5];
			}
			return;
		}
		
		if(indexPath.section==1)
		{
			AddItemsToSectionViewController * sectionsView=[[AddItemsToSectionViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
			sectionsView.navigationItem.title=self.navigationItem.title;
			sectionsView.delegate=self.delegate;
			sectionsView.newsletter=feed;
			[self.navigationController pushViewController:sectionsView animated:YES];
			[sectionsView release];
		}
	}
}
 
- (void)hudWasHidden:(MBProgressHUD *)hud 
{
	NSLog(@"Hud: %@", hud);
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	
	[self.foldersFetcher performFetch];
	
	if(selectedIndexPath)
	{
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	else 
	{
		[self.tableView reloadData];
	}

	[self performSelector:@selector(cancelOrganize) withObject:nil afterDelay:0.5];
}

- (void) cancelOrganize
{
	[delegate cancelOrganize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)dealloc {
	[selectedIndexPath release];
	[tableView release];
	[newslettersFetcher release];
	[foldersFetcher release];
	[super dealloc];
}

@end
