#import "FoldersViewController.h"
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
#import "FeedAccount.h"
#import "UserSettings.h"
#import "CustomCellBackgroundView.h"
#import "FeedsTableViewCell.h"

@implementation FoldersViewController
@synthesize tableView,fetcher,delegate;

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

- (void) showHomeScreen:(id)sender
{
	[[[UIApplication sharedApplication] delegate] showHomeScreen];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.tableView.showsVerticalScrollIndicator=NO;
	self.tableView.showsHorizontalScrollIndicator=NO;
	self.tableView.allowsSelectionDuringEditing=YES;
	
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	self.tableView.backgroundView.backgroundColor=[UIColor blackColor];
	self.tableView.backgroundView.alpha=0.5;
	
	self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(showHomeScreen:)] autorelease];
	 
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
	
	[fetcher performFetch];
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
	if([pNotification.name isEqualToString:@"ReloadData"] || [pNotification.name isEqualToString:@"ReloadActionData"])
	{
		[fetcher performFetch];
		 		
		[tableView reloadData];
	}
} 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (CustomCellBackgroundViewPosition) cellPositionForIndexPath:(NSIndexPath*)indexPath
{
	int count=[self tableView:tableView numberOfRowsInSection:indexPath.section];
	
	if(count==1)
	{
		return CustomCellBackgroundViewPositionSingle;
	}
	else 
	{
		if(indexPath.row==0)
		{
			return CustomCellBackgroundViewPositionTop;
		}
		else 
		{
			if(indexPath.row==count-1)
			{
				return CustomCellBackgroundViewPositionBottom;
			}
			else 
			{
				return CustomCellBackgroundViewPositionMiddle;
			}
		}
	}
}

- (void)configureCell:(UITableViewCell*)cell 
          atIndexPath:(NSIndexPath*)indexPath
{
	Feed * feed=[fetcher itemAtIndex:indexPath.row];
	
	cell.backgroundColor=[UIColor clearColor];
	cell.textLabel.font=[UIFont boldSystemFontOfSize:17];
	cell.textLabel.backgroundColor=[UIColor clearColor];
	cell.textLabel.textColor=[UIColor whiteColor];
	cell.textLabel.shadowColor=[UIColor blackColor];
	cell.textLabel.shadowOffset=CGSizeMake(0, 1);
	
	if(indexPath.section==0)
	{
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	else 
	{
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
	[cell setBadgeString:[NSString stringWithFormat:@"%d",[feed itemCount]]];
		
	if([feed isKindOfClass:[Newsletter class]])
	{
		cell.imageView.image=[UIImage imageNamed:@"gray_newsletter.png"];
		cell.imageView.highlightedImage=[UIImage imageNamed:@"green_newsletter.png"];
	}
	else 
	{
		if([feed isKindOfClass:[Folder class]])
		{
			cell.imageView.image=[UIImage imageNamed:@"gray_folderclosed.png"];
			cell.imageView.highlightedImage=[UIImage imageNamed:@"green_folderopen.png"];
		}
	}
	
	cell.textLabel.text=feed.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FeedsTableViewCell * cell = [[[FeedsTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 23;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [fetcher count];
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
	
	
	if([fetcher isKindOfClass:[NewsletterFetcher class]])
	{
		label.text=@"Newsletters";
	}
	if([fetcher isKindOfClass:[FolderFetcher class]])
	{
		label.text=@"Folders";
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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Feed * feed=[fetcher itemAtIndex:indexPath.row];
	
	if([feed isKindOfClass:[Newsletter class]])
	{
		[[[UIApplication sharedApplication] delegate] showNewsletter:feed delegate:self.delegate editable:YES];
	}
	if([feed isKindOfClass:[Folder class]])
	{
		[[[UIApplication sharedApplication] delegate] showFolder:feed delegate:self.delegate editable:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES;
}

- (void)dealloc 
{
	[tableView release];
	[fetcher release];
	[super dealloc];
}

@end
