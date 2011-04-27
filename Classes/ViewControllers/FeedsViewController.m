#import "FeedsViewController.h"
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
#import "CustomCellBackgroundView.h"
#import "FeedsTableViewCell.h"

@implementation FeedsViewController
@synthesize fetcher,itemDelegate,editable,items;

- (void) viewWillAppear:(BOOL)animated
{
	NSLog(@"FeedsViewController.viewWillAppear");
	[super viewWillAppear:animated];
	
	[self reloadTableData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title=nil;
	
	self.tableView.showsVerticalScrollIndicator=NO;
	self.tableView.showsHorizontalScrollIndicator=NO;
	
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	self.tableView.backgroundView.backgroundColor=[UIColor blackColor];
	self.tableView.backgroundView.alpha=0.5;
	
	if(!editable)
	{
		if([fetcher isKindOfClass:[AccountFeedFetcher class]] ||
		   [fetcher isKindOfClass:[CategoryFeedFetcher class]])
		{
			self.updatable=YES;
			self.pullDownBackgroundColor=[UIColor viewFlipsideBackgroundColor];
			[self addPullToRefreshHeader];
		}
	}
	
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
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"FeedUpdateFailed"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"AccountUpdated"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"AccountUpdateFailed"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"UpdateFeedsView"
	 object:nil];
	
	if([self.items count]>0)
	{
		// already fetched...
	}
	else 
	{
		
		[self performFetch];
	}
}

- (void) performFetch
{
	self.items=[fetcher items];
}

- (void) addButtonTouched:(id)sender
{
	if([fetcher isKindOfClass:[NewsletterFetcher class]])
	{
		// create new newsletter
		[[[UIApplication sharedApplication] delegate] addNewsletter];
		return;
	}
	if([fetcher isKindOfClass:[NewsletterSectionFetcher class]])
	{
		// create new newsletter section
		[[[UIApplication sharedApplication] delegate] addNewsletterSection:[fetcher newsletter]];
		return;
	}
	if([fetcher isKindOfClass:[FolderFetcher class]])
	{
		// create new folder
		[[[UIApplication sharedApplication] delegate] addFolder];
		return;
	}
}

- (void) actionButtonTouched:(id)sender
{
	if([fetcher isKindOfClass:[AccountFeedFetcher class]] ||
	   [fetcher isKindOfClass:[CategoryFeedFetcher class]])
	{
		UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Feed Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mark All as Read",@"Delete Older Than 7 Days",@"Delete Older Than 30 Days",@"Delete Older Than 90 Days",@"Delete Read Items",nil];
		
		[actionSheet showFromBarButtonItem:sender animated:YES];
		
		[actionSheet release];
		return;
	}
}

- (void) markAllAsRead
{
	if([fetcher isKindOfClass:[AccountFeedFetcher class]] ||
	   [fetcher isKindOfClass:[CategoryFeedFetcher class]])
	{
		[fetcher markAllAsRead];
		[self performFetch];
		[self reloadTableData];
		return;
	}
}

- (void) deleteOlderThan:(int)days
{
	if([fetcher isKindOfClass:[AccountFeedFetcher class]] ||
	   [fetcher isKindOfClass:[CategoryFeedFetcher class]])
	{
		for(Feed * feed in [fetcher items])
		{
			[feed deleteOlderThan:days];
			[self performFetch];
			[self reloadTableData];
		}
		return;
	}
}

- (void) deleteReadItems
{
	if([fetcher isKindOfClass:[AccountFeedFetcher class]] ||
	   [fetcher isKindOfClass:[CategoryFeedFetcher class]])
	{
		for(Feed * feed in [fetcher items])
		{
			[feed deleteReadItems];
			[self performFetch];
			[self reloadTableData];
		}
		return;
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
	
	switch(buttonIndex)
	{
		case 0: // mark all as read
			[self markAllAsRead];
			break;
			
		case 1: // delete older than 7 days
			[self deleteOlderThan:7];
			break;
			
		case 2: // delete older than 30 days
			[self deleteOlderThan:30];
			break;
			
		case 3: // delete older than 90 days
			[self deleteOlderThan:90];
			break;
			
		case 4: // delete all read items
			[self deleteReadItems];
			break;
	}
}

- (IBAction) toggleEditMode:(id)sender
{
	UIBarButtonItem * buttonItem=(UIBarButtonItem*)sender;
	
	if(tableView.editing)
	{
		[tableView setEditing:NO animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleBordered;
		buttonItem.title=@"Edit";
		
		[self reloadTableData];
	}
	else
	{
		[tableView setEditing:YES animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleDone;
		buttonItem.title=@"Done";
	}
}

-(void)handleReloadData:(NSNotification *)pNotification
{
	[self performSelectorOnMainThread:@selector(handleReloadDataUI:) withObject:pNotification waitUntilDone:YES];
}

-(void)handleReloadDataUI:(NSNotification *)pNotification
{
	//NSLog(@"handleReloadDataUI: %@",pNotification.name);
	
	if([pNotification.name isEqualToString:@"UpdateFeedsView"])
	{
		//NSLog(@"FeedsViewControler: UpdateFeedsView revd, perform fetch and reload data...");
		[self performFetch];
		[self reloadTableData];
		return;
	}
	if([pNotification.name isEqualToString:@"ReloadData"])
	{
		//NSLog(@"FeedsViewControler: ReloadData revd, perform fetch and reload data...");
		[self performFetch];
		[self reloadTableData];
		return;
	}
	if([pNotification.name isEqualToString:@"ReloadActionData"])
	{
		if([self.fetcher isKindOfClass:[NewsletterFetcher class]] ||
		   [self.fetcher isKindOfClass:[NewsletterSectionFetcher class]] ||
		   [self.fetcher isKindOfClass:[FolderFetcher class]])
		{
			//NSLog(@"FeedsViewControler: ReloadActionData revd, perform fetch and reload data...");
			[self performFetch];
			[self reloadTableData];
		}
		return;
	}
	if([pNotification.name isEqualToString:@"FeedsUpdated"])
	{
		//NSLog(@"FeedsViewControler: FeedsUpdated revd, perform fetch and reload data...");
		[self performFetch];
		[self reloadTableData];
		return;
	}
	if([pNotification.name isEqualToString:@"FeedUpdated"])
	{
		NSArray * array=(NSArray*)pNotification.object;
		NSString * accountName=[array objectAtIndex:0];
		NSString * url=[array objectAtIndex:1];
		
		NSArray * feeds=self.items;
		for(int i=0;i<[feeds count];i++)
		{
			id * feed=[feeds objectAtIndex:i];
			
			if([feed respondsToSelector:@selector(url)])
			{
				if([[feed url] isEqualToString:url])
				{
					// refresh object so latest changes (such as unreadCount are displayed when row is reloaded...)
					@try
					{
						[[feed managedObjectContext] refreshObject:feed mergeChanges:YES];
						
						[self reloadTableRow:i];
					}
					@catch (NSException * e) 
					{
						NSLog(@"Error reloading row: %@",[e userInfo]);
					}
					@finally 
					{
					}
				}
			}
		}
		
		if([self.fetcher isKindOfClass:[AccountFeedFetcher class]])
		{
			if([[self.fetcher accountName] isEqualToString:accountName])
			{
				for(int i=0;i<[feeds count];i++)
				{
					Feed  * feed=[feeds objectAtIndex:i];
					
					if([feed isCategory] || [feed isAllItems])
					{
						[self reloadTableRow:i];
					}
				}
			}
		}
		return;
	}
	
	if([pNotification.name isEqualToString:@"AccountUpdated"])
	{
		NSString * accountName=[pNotification object];
		
		if([self.fetcher isKindOfClass:[AccountFeedFetcher class]] ||
		   [self.fetcher isKindOfClass:[CategoryFeedFetcher class]])
		{
			if([accountName isEqualToString:[self.fetcher accountName]])
			{
				[self stopLoading];
				[self.fetcher performFetch];
				[self reloadTableData];
			}
		}
		return;
	}
	
	if([pNotification.name isEqualToString:@"AccountUpdateFailed"])
	{
		NSArray * array=[pNotification object];
		NSString * accountName=[array objectAtIndex:0];
		NSString * message=[array objectAtIndex:1];
		
		if([self.fetcher isKindOfClass:[AccountFeedFetcher class]]||
		   [self.fetcher isKindOfClass:[CategoryFeedFetcher class]])
		{
			if([accountName isEqualToString:[self.fetcher accountName]])
			{
				[self stopLoading];
				
				UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Update Failed" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
				
				[alert show];
				[alert release];
			}
		}
		return;
	}
} 

- (IBAction) toggleEdit:(id)sender
{
	// TODO: change button lable/color
	if(tableView.editing)
	{
		[tableView setEditing:NO animated:YES];
	}
	else 
	{
		[tableView setEditing:YES animated:YES];
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
	else {
		if(indexPath.row==0)
		{
			return CustomCellBackgroundViewPositionTop;
		}
		else {
			
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
	Feed * feed=[self.items objectAtIndex:indexPath.row];
	
	cell.textLabel.textColor=[UIColor lightGrayColor];
	cell.backgroundColor=[UIColor clearColor];
	cell.textLabel.backgroundColor=[UIColor clearColor];
	 
	cell.textLabel.font=[UIFont boldSystemFontOfSize:17];
	cell.textLabel.textColor=[UIColor whiteColor];
	cell.textLabel.shadowColor=[UIColor blackColor];
	cell.textLabel.shadowOffset=CGSizeMake(0, 1);
	
	
	if([feed respondsToSelector:@selector(isCategory)] && [feed isCategory])
	{
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	else 
	{
		cell.accessoryType=UITableViewCellAccessoryNone;
	}

	if([feed isKindOfClass:[RssFeed class]])
	{
		int unreadCount=[[feed currentUnreadCount] intValue]; 
	
		if(unreadCount>0)
		{
			[cell setBadgeString:[NSString stringWithFormat:@"%d",unreadCount]];
			cell.textLabel.textColor=[UIColor whiteColor];
		}
		else 
		{
			[cell setBadgeString:nil];
		}
	}
	
	cell.textLabel.text=feed.name;
	
	if(feed.imageName)
	{
		cell.imageView.image=[UIImage imageNamed:feed.imageName];
		
		if(feed.highlightedImageName)
		{
			cell.imageView.highlightedImage=[UIImage imageNamed:feed.highlightedImageName];
		}
	}
	else 
	{
		if(feed.image)
		{
			cell.imageView.image=feed.image;
		}
	}
}

- (void) reloadTableRow:(NSInteger)row
{
	NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];
	NSIndexPath *pathToReload=[NSIndexPath indexPathForRow:row inSection:0];
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:pathToReload] withRowAnimation:UITableViewRowAnimationNone];
	
	if(ipath)
	{
		if(pathToReload.section==ipath.section && pathToReload.row==ipath.row)
		{
			[self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
		}
	}
}

- (void) reloadTableData
{
	NSLog(@"FeedsViewController.reloadTableData");
	NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];
	if(ipath==nil)
	{
		//hack to select first value when view is first opened
		if([items count]>0)
		{
			ipath=[NSIndexPath indexPathForRow:0 inSection:0];
		}
	}
	[self.tableView reloadData];
	if(ipath)
	{
		[self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FeedsTableViewCell * cell = [[[FeedsTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
	
	cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;

	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.items count];
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
	
	label.text=self.title;
	
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	Feed * feed=[self.items objectAtIndex:indexPath.row];
	
	// prompt for name
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Change Name" 
													 message:@"\n\n" // IMPORTANT
													delegate:self 
										   cancelButtonTitle:@"Cancel" 
										   otherButtonTitles:@"Ok", nil];
	
	prompt.tag=indexPath.row;
	
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 50.0, 250.0, 25.0)]; 
	[textField setBackgroundColor:[UIColor whiteColor]];
	textField.text=feed.name;
	[prompt addSubview:textField];
	
	// set place
	[prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
	[prompt show];
    [prompt release];
	
	[textField release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if(buttonIndex==1)
	{
		UITextField * textField=nil;
		for(UIView * subview in actionSheet.subviews)
		{
			if([subview isKindOfClass:[UITextField class]])
			{
				textField=subview;
				break;
			}
		}
		if(textField)
		{
			if (textField.text != nil && [textField.text length]>0) 
			{
				Feed * feed=[self.items objectAtIndex:actionSheet.tag];
				
				feed.name=textField.text;
				
				[feed save];
				
				[self reloadTableData];
				
				[[NSNotificationCenter defaultCenter] 
				 postNotificationName:@"ReloadActionData"
				 object:nil];
			}
		}
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(!aTableView.editing)
	{
		Feed * feed=[self.items objectAtIndex:indexPath.row];
		
		if([feed respondsToSelector:@selector(feedFetcher)])
		{
			ItemFetcher * feedFetcher=[feed feedFetcher];
		
			if(feedFetcher!=nil)
			{
				NSArray * feeds=[feedFetcher items];
				
				Feed * firstFeed=nil;
				
				if([feeds count]>0)
				{
					firstFeed=[feeds objectAtIndex:0];
				}
				
				FeedsViewController * feedsView=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
				
				feedsView.items=feeds;
				feedsView.editable=(self.editable || [feed editable]);
				feedsView.fetcher=feedFetcher;
				feedsView.title=feed.name;
				feedsView.itemDelegate=self.itemDelegate;
				
				[self.navigationController pushViewController:feedsView animated:YES];
				 
				if(firstFeed)
				{
					[feedsView.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]   animated:NO scrollPosition:UITableViewScrollPositionNone];
				
					[[[UIApplication sharedApplication] delegate] showFeed:firstFeed delegate:self.itemDelegate editable:self.editable];
				}
				[feedsView release];
			}
			else 
			{
				[[[UIApplication sharedApplication] delegate] showFeed:feed delegate:self.itemDelegate editable:self.editable];
			}
		}
		else 
		{
			[[[UIApplication sharedApplication] delegate] showFeed:feed delegate:self.itemDelegate editable:self.editable];
		}
	}
}

- (void)refresh 
{
    if([[[UIApplication sharedApplication] delegate] isUpdating])
	{
		[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.3];
		return;
	}
	
	if(![[[UIApplication sharedApplication] delegate] hasInternetConnection])
	{
		[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.3];
		return;
	}
	
	if([fetcher isKindOfClass:[FeedItemFetcher class]])
	{
		[[[UIApplication sharedApplication] delegate] updateSingleFromScroll:[fetcher feed]];
	}
	else 
	{
		if ([fetcher isKindOfClass:[CategoryFeedFetcher class]]) 
		{
			[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName] forCategory:[fetcher feedCategory]];
		}
		else 
		{
			if([fetcher isKindOfClass:[AccountFeedFetcher class]])
			{
				[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName] forCategory:nil];
			}
			else 
			{
				[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.3];
			}
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}
	 
- (void)dealloc 
{
	[items release];
	[fetcher release];
	[super dealloc];
}

@end
