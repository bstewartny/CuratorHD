#import "FeedViewController.h"
#import "FeedItem.h"
#import "Feed.h"
#import "RssFeed.h"
#import "FeedAccount.h"
#import "FeedItemDictionary.h"
#import "FeedItemCell.h"
#import "NewsletterHTMLPreviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ItemFetcher.h"
#import "AccountUpdater.h"
#import "FeedFetcher.h"
#import "MarkupStripper.h"
#import "TweetTableViewCell.h"
#import "RssFeedItem.h"
#import "CustomCellBackgroundView.h"
#import "BlankToolbar.h"
#import "FastFeedItemCell.h"
#import "FastTweetTableViewCell.h"
#import "AddItemsViewController.h"

@implementation FeedViewController
@synthesize folderMode,fetcher,itemDelegate,favoritesMode,editable;
@synthesize  origTitle, navPopoverController;
@synthesize twitter;

-(void)handleNotification:(NSNotification *)pNotification
{
	[self performSelectorOnMainThread:@selector(handleNotificationUI:) withObject:pNotification waitUntilDone:YES];
}

-(void)handleNotificationUI:(NSNotification *)pNotification
{
	if([pNotification.name isEqualToString:@"UpdateFeedView"])
	{
		[self.fetcher performFetch];
		[tableView reloadData];
	}
	if([pNotification.name isEqualToString:@"ReloadData"])
	{
		[tableView reloadData];
		return;
	}
	if([pNotification.name isEqualToString:@"SelectItem"])
	{
		[self selectItem:pNotification.object];
		return;
	}
	if([pNotification.name isEqualToString:@"AccountUpdated"])
	{
		NSString * accountName=[pNotification object];
		
		if([self.fetcher isKindOfClass:[AccountItemFetcher class]] || [self.fetcher isKindOfClass:[CategoryItemFetcher class]])
		{
			if([accountName isEqualToString:[self.fetcher accountName]])
			{
				NSLog(@"stop loading and update table...");
				[self stopLoading];
				[self.fetcher performFetch];
				[tableView reloadData];
			}
		}
	}
	if([pNotification.name isEqualToString:@"AccountUpdateFailed"])
	{
		NSArray * array=[pNotification object];
		NSString * accountName=[array objectAtIndex:0];
		NSString * message=[array objectAtIndex:1];
		
		if([self.fetcher isKindOfClass:[AccountItemFetcher class]] || [self.fetcher isKindOfClass:[CategoryItemFetcher class]])
		{
			if([accountName isEqualToString:[self.fetcher accountName]])
			{
				NSLog(@"stop loading and update table...");
				[self stopLoading];
				
				UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Update Failed" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
				
				[alert show];
				[alert release];
			}
		}
	}
	if([pNotification.name isEqualToString:@"FeedUpdateFailed"])
	{
		NSArray * array=[pNotification object];
		NSString * accountName=[array objectAtIndex:0];
		NSString * url=[array objectAtIndex:1];
		NSString * message=[array objectAtIndex:2];
		if([self.fetcher isKindOfClass:[FeedItemFetcher class]])
		{
			if([[[self.fetcher feed] url] isEqualToString:url])
			{
				[self stopLoading];
				UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Update Failed" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
				
				[alert show];
				[alert release];
			}
		}
	}
	if([pNotification.name isEqualToString:@"FeedUpdated"] ||
	   [pNotification.name isEqualToString:@"FeedUpdateFinished"])
	{
		NSArray * array=[pNotification object];
		NSString * accountName=[array objectAtIndex:0];
		NSString * url=[array objectAtIndex:1];

		if([self.fetcher isKindOfClass:[FeedItemFetcher class]])
		{
			if([[[self.fetcher feed] url] isEqualToString:url])
			{
				NSLog(@"stop loading and update table...");
				[self stopLoading];
				[self.fetcher performFetch];
				[tableView reloadData];
			}
		}
	}	
} 

- (void)selectItem:(FeedItem*)item
{
	NSIndexPath * selectedPath=[self.tableView indexPathForSelectedRow];

	NSArray * items=[fetcher items];
	
	if(selectedPath)
	{
		if(selectedPath.row < [items count])
		{
			FeedItem * selectedItem=[items objectAtIndex:selectedPath.row];
		
			if([selectedItem isEqual:item])
			{
				// do nothing
				return;
			}
			else 
			{
				[self.tableView deselectRowAtIndexPath:selectedPath animated:YES];
			}
		}
	}
	
	// find new item to select
	for(int i=0;i<[items count];i++)
	{
		if ([[items objectAtIndex:i] isEqual:item]) 
		{
			[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
			break;
		}
	}
}

- (void) cancelOrganize
{
	if(editButton)
	{
		editButton.enabled=YES;
	}
	
	[[[[UIApplication sharedApplication] delegate] selectedItems] removeAllItems];
	
	
	//self.navigationItem.title=self.origTitle;
	
	[self setOrganizeRightBarButtonItem];
	
	[[[UIApplication sharedApplication] delegate] hideSelectedView];
	
	[self.tableView setEditing:NO animated:NO];
	[self.tableView reloadData];
}

- (void) addToFolder:(Folder*)folder
{
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	for(FeedItem * item in selectedItems.items)
	{
		// get original synopsis because we need to override the short version we used to optimize scrolling...
		item.synopsis=[item.origSynopsis flattenHTML];
		[folder addFeedItem:item];
	}
	
	[folder save];
}

- (void) addToSection:(NewsletterSection*)section
{
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	// add selected items to folder...
	for(FeedItem * item in selectedItems.items)
	{
		// get original synopsis because we need to override the short version we used to optimize scrolling...
		item.synopsis=[item.origSynopsis flattenHTML];
		[section addFeedItem:item];
	}
	[section save]; 
}

- (void) organize:(id)sender
{
	if([fetcher count]==0) return;
	
	editButton.enabled=NO;
	
	// enter edit mode and show message
	//self.origTitle=self.navigationItem.title;
	
	//self.navigationItem.title=@"Tap a folder or newsletter to add selected items.";
	
	
	BlankToolbar * tools=[[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
	tools.opaque=NO;
	tools.backgroundColor=[UIColor clearColor];
	
	NSMutableArray * buttons=[[NSMutableArray alloc] init];
	
	UIBarButtonItem * bi=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
	
	[bi release];
	
	bi=[[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStyleBordered target:self action:@selector(selectAll:)];
	
	[buttons addObject:bi];
	
	[bi release];
	
	bi=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOrganize)];
	
	[buttons addObject:bi];
	
	[bi release];
	
	[tools setItems:buttons];
	
	[buttons release];
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithCustomView:tools] autorelease];
	
	[tools release];
	
	[[[[UIApplication sharedApplication] delegate] selectedItems] removeAllItems];
	
	FolderFetcher * foldersFetcher=[[FolderFetcher alloc] init];
	
	NewsletterFetcher * newslettersFetcher=[[NewsletterFetcher alloc] init];
	
	AddItemsViewController * feedsView=[[AddItemsViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
	feedsView.navigationItem.title=@"Add Selected Items";
	
	[feedsView setFoldersFetcher:foldersFetcher];
	[feedsView setNewslettersFetcher:newslettersFetcher];
	
	feedsView.delegate=self;

	[[[UIApplication sharedApplication] delegate] pushMasterViewController:feedsView];
	
	[feedsView release];
	
	[foldersFetcher release];
	[newslettersFetcher release];

	[self.tableView setEditing:YES animated:YES];
	
	[self.tableView reloadData];
}

- (void) selectAll:(id)sender
{
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
			
	for (int i = 0; i < [tableView numberOfSections]; i++) 
	{
		for (int j = 0; j < [tableView numberOfRowsInSection:i]; j++) 
		{
			[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]		animated:YES scrollPosition:UITableViewScrollPositionNone];
			
			FeedItem * item=[fetcher itemAtIndex:j];
			
			if(![selectedItems containsItem:item])
			{
				[selectedItems addItem:item];
			}
		}
	}
}

- (void) setOrganizeRightBarButtonItem
{
	BlankToolbar * tools=[[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
	
	tools.opaque=NO;
	tools.backgroundColor=[UIColor clearColor];
	
	NSMutableArray * toolBarItems=[[NSMutableArray alloc] init];
	
	[toolBarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	
	[organizeButton release];
	organizeButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(organize:)];
	
	[toolBarItems addObject:organizeButton];
	
	UIBarButtonItem * space=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	space.width=20;
	
	[toolBarItems addObject:space];
	
	if(editable)
	{
		[editButton release];
		editButton=[[UIBarButtonItem alloc] init];
		editButton.title=@"Edit";
		editButton.target=self;
		editButton.action=@selector(toggleEditMode:) ;
		editButton.style = UIBarButtonItemStyleBordered;
		[toolBarItems addObject:editButton];
	}
	else 
	{
		UIBarButtonItem * actionButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
		[toolBarItems addObject:actionButton];
		[actionButton release];
	}
	
	[tools setItems:toolBarItems];
	[toolBarItems release];
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithCustomView:tools] autorelease];
	
	[tools release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.tableView.backgroundColor=[UIColor colorWithRed:(247.0/255.0) green:(247.0/255.0) blue:(247.0/255.0) alpha:1.0];
	
	[self setOrganizeRightBarButtonItem];
	
	stripper=[[MarkupStripper alloc] init];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"ReloadData"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"SelectItem"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"FeedUpdated"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"FeedUpdateFinished"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"FeedUpdateFailed"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"AccountUpdated"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"AccountUpdateFailed"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"UpdateFeedView"
	 object:nil];
	
	 
	
	[fetcher performFetch];
	
    [super viewDidLoad];
	
	if(!folderMode)
	{
		self.updatable=YES;
		if(fetcher)
		{
			[self addPullToRefreshHeader];
			[self addPullToRefreshFooter];
		}
	}
	
	[tableView reloadData];
}

- (void)addPullToRefreshFooter
{
	// TODO
}

- (void) actionButtonTouched:(id)sender
{
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Feed Actions" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Mark All as Read",@"Delete Older Than 7 Days",@"Delete Older Than 30 Days",@"Delete Older Than 90 Days",@"Delete All Read Items",nil];
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
	
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	// The hud will dispable all input on the view
	HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
	
	// Add HUD to screen
	[self.view.window addSubview:HUD];
	
	// Regisete for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	switch(buttonIndex)
	{
		case 0:
			HUD.labelText=@"Marking as read...";
			break;
			
		case 1: // delete older than 7 days
			HUD.labelText=@"Deleting older items...";
			break;
			
		case 2: // delete older than 30 days
			HUD.labelText=@"Deleting older items...";
			break;
			
		case 3: // delete older than 90 days
			HUD.labelText=@"Deleting older items...";
			break;
			
		case 4: // delete older than 90 days
			HUD.labelText=@"Deleting read items...";
			break;
	}
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(performFeedUpdates:) onTarget:self withObject:[NSNumber numberWithInt:buttonIndex] animated:YES];
}	
	
- (void) performFeedUpdates:(NSNumber*)buttonIndexObj
{
	NSInteger buttonIndex=[buttonIndexObj intValue];
	 
	Feed * feed=nil;
	if([fetcher isKindOfClass:[FeedItemFetcher class]])
	{
		feed=[fetcher feed];
	}
	else 
	{
		if([fetcher isKindOfClass:[CategoryItemFetcher class]])
		{
			if(buttonIndex==0)
			{
				CategoryFeedFetcher * categoryFeedFetcher=[[CategoryFeedFetcher alloc] init];
				categoryFeedFetcher.accountName=[fetcher accountName];
				categoryFeedFetcher.feedCategory=[fetcher feedCategory];
				[categoryFeedFetcher markAllAsRead];
				[categoryFeedFetcher release];
			}
			else 
			{
				// get all feeds in account to process...
				CategoryFeedFetcher * categoryFeedFetcher=[[CategoryFeedFetcher alloc] init];
				categoryFeedFetcher.accountName=[fetcher accountName];
				categoryFeedFetcher.feedCategory=[fetcher feedCategory];
				for(Feed * categoryFeed in [categoryFeedFetcher items])
				{
					switch(buttonIndex)
					{
						case 1: // delete older than 7 days
							[categoryFeed deleteOlderThan:7];
							break;
							
						case 2: // delete older than 30 days
							[categoryFeed deleteOlderThan:30];
							break;
							
						case 3: // delete older than 90 days
							[categoryFeed deleteOlderThan:90];
							break;
							
						case 4: // delete older than 90 days
							[categoryFeed deleteReadItems];
							break;
							
					}
				}
				[categoryFeedFetcher release];
			}
		}
		else 
		{
			if([fetcher isKindOfClass:[AccountItemFetcher class]])
			{
				if(buttonIndex==0)
				{
					AccountFeedFetcher * accountFeedFetcher=[[AccountFeedFetcher alloc] init];
					accountFeedFetcher.accountName=[fetcher accountName];
					[accountFeedFetcher markAllAsRead];
					[accountFeedFetcher release];
				}
				else 
				{
					// get all feeds in account to process...
					AccountUpdatableFeedFetcher * feedFetcher=[[AccountUpdatableFeedFetcher alloc] init];
					feedFetcher.accountName=[fetcher accountName];
					for(Feed * accountFeed in [feedFetcher items])
					{
						switch(buttonIndex)
						{
							case 1: // delete older than 7 days
								[accountFeed deleteOlderThan:7];
								break;
								
							case 2: // delete older than 30 days
								[accountFeed deleteOlderThan:30];
								break;
								
							case 3: // delete older than 90 days
								[accountFeed deleteOlderThan:90];
								break;
								
							case 4: // delete older than 90 days
								[accountFeed deleteReadItems];
								break;
								
						}
					}
					[feedFetcher release];
				}
			}
		}
		return;
	}

	if(feed==nil) return;
	
	switch(buttonIndex)
	{
		case 0: // mark all as read
			[feed markAllAsRead];
			break;
			
		case 1: // delete older than 7 days
			[feed deleteOlderThan:7];
			break;
			
		case 2: // delete older than 30 days
			[feed deleteOlderThan:30];
			break;
			
		case 3: // delete older than 90 days
			[feed deleteOlderThan:90];
			break;
			
		case 4: // delete older than 90 days
			[feed deleteReadItems];
			break;
	}
}


- (void)hudWasHidden:(MBProgressHUD *)hud {
	NSLog(@"Hud: %@", hud);
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	
	[self.tableView reloadData];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateFeedsView"
	 object:nil];	
}






- (IBAction) toggleEditMode:(id)sender
{
	UIBarButtonItem * buttonItem=(UIBarButtonItem*)sender;
	
	if(self.tableView.editing)
	{
		[self.tableView setEditing:NO animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleBordered;
		buttonItem.title=@"Edit";
		editMode=NO;
		
		organizeButton.enabled=YES;
		
		[self.tableView reloadData];
	}
	else
	{	
		if([fetcher count]>0)
		{
			editMode=YES;
			
			organizeButton.enabled=NO;
			
			[self.tableView setEditing:YES animated:YES];
		
			buttonItem.style=UIBarButtonItemStyleDone;
			buttonItem.title=@"Done";
		}
	}
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(!editable) return;
	if (editingStyle != UITableViewCellEditingStyleDelete) return;
	if([fetcher count]==0) return;
	[fetcher deleteItemAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void)tableView:(UITableView*)tableView 
moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
	  toIndexPath:(NSIndexPath*)toIndexPath
{
	if(!self.editable) return;
	
	int fromRow=[fromIndexPath row];
	int toRow=[toIndexPath row];
	
	[fetcher moveItemFromIndex:fromRow toIndex:toRow];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		FeedItem * item=[fetcher itemAtIndex:indexPath.row];
		
		FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
		
		if([selectedItems containsItem:item])
		{
			[selectedItems removeItem:item];
		}
	}
}

- (void) redraw
{
	[self.tableView reloadData];
}

- (void) redraw:(FeedItem*)item
{
	[self redraw];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		FeedItem * item=[fetcher itemAtIndex:indexPath.row];
		FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
		
		if(![selectedItems containsItem:item])
		{
			[selectedItems addItem:item];
		}
	}
	else
	{
		if([fetcher count]>0)
		{
			[itemDelegate showItemHtml:indexPath.row itemFetcher:fetcher allowComments:self.folderMode];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(tableView.editing)
	{
		if(!editMode)
		{
			return @"Select items and then tap folder or newsletter to add items.";
		}
		else 
		{
			return nil;
		}
	}
	else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	//if(twitter)
	//{
	//	return 76;
	//}
	//else 
	//{
		return 84; 
		//return tableView.rowHeight;
	//}
}

- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return self.editable;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get item
	
	if([fetcher count]==0)
	{
		return [self pullDownCell];
	}
	else 
	{
		FeedItem * item=[fetcher itemAtIndex:indexPath.row];
	
		// get cell for item based on item type...
		if([item.originId isEqualToString:@"twitter"] ||
		   [item.originId hasPrefix:@"facebook"])
		{
			// display tweet
			return [self tweetCellForRowAtIndexPath:tableView indexPath:indexPath item:item];
		}
		else 
		{
			// display headline
			return [self headlineCellForRowAtIndexPath:tableView indexPath:indexPath item:item];
		}
	}
}

- (UITableViewCell *) pullDownCell
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	cell.backgroundColor=[UIColor clearColor];
	
	cell.textLabel.textColor=[UIColor lightGrayColor];
	
	cell.textLabel.textAlignment=UITextAlignmentCenter;

	if(fetcher)
	{
		if(folderMode)
		{
			cell.textLabel.text=@"Add items from source feeds.";
		}
		else 
		{
			cell.textLabel.text=@"Pull down to load the latest feed items.";
		}
	}
	else 
	{
		//cell.textLabel.text=@"Select a feed from the sources menu.";
	}

	return cell;
}

- (UITableViewCell *) tweetCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"TweetItemCellIdentifier";
	
	FastTweetTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[FastTweetTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
	}
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;
	
	if(item.image)
	{
		cell.userImage=item.image;
	}
	else 
	{
		cell.userImage=[UIImage imageNamed:@"profileplaceholder.png"];
	}
	cell.tweet=item.headline;
	cell.date=[item shortDisplayDate];
	cell.username=item.origin;

	return cell;
}

- (void)refresh 
{
    if([[[UIApplication sharedApplication] delegate] isUpdating])
	{
		NSLog(@"delegate is already updating");
		[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.3];
		return;
	}
	
	if(![[[UIApplication sharedApplication] delegate] hasInternetConnection])
	{
		NSLog(@"no internet connection");
		[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.3];
		return;
	}
	
	if([fetcher isKindOfClass:[FeedItemFetcher class]])
	{
		NSLog(@"updating singlefeed");
		[[[UIApplication sharedApplication] delegate] updateSingleFromScroll:[fetcher feed]];
		return;
	}
	else 
	{
		if([fetcher isKindOfClass:[CategoryItemFetcher class]])
		{
			NSLog(@"updating single category");
			// for now update entire account because it is simpler (we still may need to implement per-category at some point)
			[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName] forCategory:[fetcher feedCategory]];
			
			return;
		}
		
		if([fetcher isKindOfClass:[AccountItemFetcher class]])
		{
			NSLog(@"updating single account");
			[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName] forCategory:nil];
			return;
		}
		else 
		{
			[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.3];
		}
	}
}

- (void) backfill
{
	[self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
	
	if([[[UIApplication sharedApplication] delegate] isUpdating])
	{
		return;
	}
	
	if([fetcher isKindOfClass:[FeedItemFetcher class]])
	{
		[[[UIApplication sharedApplication] delegate] backFillSingleFromScroll:[fetcher feed]];
	}
	else 
	{
		if([fetcher isKindOfClass:[CategoryItemFetcher class]])
		{
			[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName] forCategory:[fetcher feedCategory]];
		}
		else 
		{
			if([fetcher isKindOfClass:[AccountItemFetcher class]])
			{
				[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName] forCategory:nil];
			}
		}
	}
}
/*
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc 
{
    barButtonItem.title = @"Sources";
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.navPopoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.navPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
{
}*/

- (UITableViewCell *) headlineCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"FeedItemCellIdentifier";
	
	FastFeedItemCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[FastFeedItemCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
	}
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;
	
	if([item.isRead boolValue])
	{
		cell.readHeadlineColor=[UIColor darkGrayColor];
	}
	else 
	{
		cell.readHeadlineColor=[UIColor blackColor];
	}

	if([[item origSynopsis] length]>0)
	{
		if([[item synopsis] length]==0)
		{
			// faster to just strip up to what we need to display...
			item.synopsis=[stripper stripMarkupSummary:[item origSynopsis] maxLength: 300];
		}
	}
	
	cell.synopsis=item.synopsis;
	
	cell.headline=item.headline;
	
	cell.origin=item.origin;
	
	cell.date=[item shortDisplayDate];

	[cell setNeedsDisplay];
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count= [fetcher count];
	
	if(!folderMode)
	{
		if(count==0) return 1; //show pull down cell
	}
	
	return count;
}

-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath 
{
	if(editable && editMode)
	{
		return UITableViewCellEditingStyleDelete;
	}
	else 
	{
		return 3;
	}
}
- (void)dealloc {
	[origTitle release];
	[fetcher release];
	[organizeButton release];
	[editButton release];
	[navPopoverController release];
	[stripper release];
    [super dealloc];
}

@end




