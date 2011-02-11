#import "FeedsViewController.h"
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
@implementation FeedsViewController
@synthesize tableView,fetcher,itemDelegate,editable,items;

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	/*UIButton * favoritesbuttonview=[UIButton buttonWithType:UIButtonTypeCustom];
	[favoritesbuttonview setImage:[UIImage imageNamed:@"accept.png"] forState:UIControlStateNormal];
	
	[favoritesbuttonview addTarget:self action:@selector(showFavorites) forControlEvents:UIControlEventTouchUpInside];
	favoritesbuttonview.frame=CGRectMake(0,0,25,25);
	
	UIBarButtonItem * favoritesbutton=[[UIBarButtonItem alloc] initWithCustomView:favoritesbuttonview];
	self.navigationItem.rightBarButtonItem=favoritesbutton;
	
	[favoritesbutton release];
	*/
	NSMutableArray * toolbaritems=[[NSMutableArray alloc] init];
	
	refreshButton=[[UIBarButtonItem	alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTouch:)];

	[toolbaritems addObject:refreshButton];
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
	
	UIBarButtonItem * activityIndicatorItem=[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
	
	[toolbaritems addObject:activityIndicatorItem];
	
	[activityIndicatorItem release];
	
	UIBarButtonItem * spacer;
	
	statusLabel=[[UILabel alloc] init];
	statusLabel.backgroundColor=[UIColor clearColor];
	statusLabel.font=[UIFont systemFontOfSize:11];
	statusLabel.textColor=[UIColor grayColor];
	
	if(editable)
	{
		statusLabel.frame=CGRectMake(0, 0, 110, 20);
	}
	else 
	{
		statusLabel.frame=CGRectMake(0, 0, 180, 20);
	}

	UIBarButtonItem * statusLabelItem=[[UIBarButtonItem alloc] initWithCustomView:statusLabel];
	
	[toolbaritems addObject:statusLabelItem];
	
	[statusLabelItem release];
	
	spacer= [[UIBarButtonItem alloc]
			 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbaritems addObject:spacer];
	[spacer release];
	
	if(editable)
	{
		UIBarButtonItem * addButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouched:)];
		addButton.style = UIBarButtonItemStyleBordered;
		[toolbaritems addObject:addButton];
		[addButton release];
		
		
		UIBarButtonItem * editButton=[[UIBarButtonItem alloc] init];
		editButton.title=@"Edit";
		editButton.target=self;
		editButton.action=@selector(toggleEditMode:) ;
		editButton.style = UIBarButtonItemStyleBordered;
		[toolbaritems addObject:editButton];
		[editButton release];
	}
	else 
	{
		if([fetcher isKindOfClass:[AccountFeedFetcher class]] ||
		   [fetcher isKindOfClass:[CategoryFeedFetcher class]])
		{
			UIBarButtonItem * actionButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
			[toolbaritems addObject:actionButton];
			[actionButton release];
		}
	}
	
	[self.toolbar setItems:toolbaritems];
	
	[toolbaritems release];
	
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
	
	 
	
	[self performFetch];
	//[fetcher performFetch];
}

- (void) performFetch
{
	//[fetcher performFetch];
	
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
		[self.tableView reloadData];
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
			[self.tableView reloadData];
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
			[self.tableView reloadData];
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
}

- (void) appSettings:(id)sender
{
	// show app settings modal form...
	
	//InAppSettingsModalViewController *settings = [[InAppSettingsModalViewController alloc] init];
    //[self presentModalViewController:settings animated:YES];
    //[settings release];
	
	/*InAppSettingsViewController *settings = [[InAppSettingsViewController alloc] init];
	
	[[[[UIApplication sharedApplication] delegate] masterNavController] pushViewController:settings animated:YES];
	
    //[self presentModalViewController:settings animated:YES];
    [settings release];
	*/
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
		NSLog(@"FeedsViewControler: ReloadData revd, perform fetch and reload data...");
		[self performFetch];
		[tableView reloadData];
	}
	if([pNotification.name isEqualToString:@"ReloadActionData"])
	{
		if([self.fetcher isKindOfClass:[NewsletterFetcher class]] ||
		   [self.fetcher isKindOfClass:[NewsletterSectionFetcher class]] ||
		   [self.fetcher isKindOfClass:[FolderFetcher class]])
		{
			NSLog(@"FeedsViewControler: ReloadActionData revd, perform fetch and reload data...");
			[self performFetch];
			[tableView reloadData];
		}
	}
	if([pNotification.name isEqualToString:@"FeedsUpdated"])
	{
		NSLog(@"FeedsViewControler: FeedsUpdated revd, perform fetch and reload data...");
		[self performFetch];
		[tableView reloadData];
	}
	if([pNotification.name isEqualToString:@"FeedUpdated"])
	{
		NSArray * array=(NSArray*)pNotification.object;
		NSString * accountName=[array objectAtIndex:0];
		NSString * url=[array objectAtIndex:1];
		
		NSLog(@"FeedsViewControler: FeedUpdated revd, looking for url match: %@",url);
		
		NSArray * feeds=self.items;
		for(int i=0;i<[feeds count];i++)
		{
			id * feed=[feeds objectAtIndex:i];
			
			if([feed respondsToSelector:@selector(url)])
			{
				if([[feed url] isEqualToString:url])
				{
					NSLog(@"FeedsViewControler: FeedUpdated revd, update table row...%@",url);
					// refresh object so latest changes (such as unreadCount are displayed when row is reloaded...)
					@try
					{
						[[feed managedObjectContext] refreshObject:feed mergeChanges:YES];
						[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
					
					if([feed.feedCategory isEqualToString:@"_all"] ||
					   [feed.feedCategory isEqualToString:@"_category"])
					{
						NSLog(@"FeedsViewControler: FeedUpdated revd, accountfeed, update table row...%@",url);
						
						[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
					}
				}
			}
		}
	}
} 

- (IBAction) toggleEdit:(id)sender
{
	// TODO: change button lable/color
	if(tableView.editing)
	{
		[tableView setEditing:NO animated:YES];
	}
	else {
		[tableView setEditing:YES animated:YES];
	}

	
	//tableView.editing=!tableView.editing;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	[fetcher deleteItemAtIndex:indexPath.row];
	[self performFetch];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadActionData"
	 object:nil];
}

- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return self.editable;
}

- (void)tableView:(UITableView*)tableView 
moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
	  toIndexPath:(NSIndexPath*)toIndexPath
{
	if(!self.editable) return;
	
	int fromRow=[fromIndexPath row];
	int toRow=[toIndexPath row];
	
	[fetcher moveItemFromIndex:fromRow toIndex:toRow];
	[self performFetch];
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadActionData"
	 object:nil];
}

- (void)configureCell:(UITableViewCell*)cell 
          atIndexPath:(NSIndexPath*)indexPath
{
	Feed * feed=[self.items objectAtIndex:indexPath.row];
	
	//Feed * feed=[fetcher itemAtIndex:indexPath.row];
	
	//NSLog(@"feed %@ , class=%@",feed.name, [[feed class] description]);
	
	if([feed.feedCategory isEqualToString:@"_category"])
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
		cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
	}

	cell.textLabel.text=feed.name;
	
	if(feed.image)
	{
		cell.imageView.image=feed.image;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BadgedTableViewCell * cell = [[[BadgedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:nil] autorelease];
	
	cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
	
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;

	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.items count];
	//return [fetcher count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.title;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	Feed * feed=[self.items objectAtIndex:indexPath.row];
	
	//Feed * feed=[fetcher itemAtIndex:indexPath.row];
	
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
				
				//Feed * feed=[fetcher itemAtIndex:actionSheet.tag];
				
				feed.name=textField.text;
				
				[feed save];
				
				[tableView reloadData];	
				
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
		//Feed * feed=[fetcher itemAtIndex:indexPath.row];	
		
		if([feed respondsToSelector:@selector(feedFetcher)])
		{
			ItemFetcher * feedFetcher=[feed feedFetcher];
		
			if(feedFetcher!=nil)
			{
				FeedsViewController * feedsView=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
			
				feedsView.editable=(self.editable || [feed editable]);
				feedsView.fetcher=feedFetcher;
				feedsView.title=feed.name;
				feedsView.itemDelegate=self.itemDelegate;
				//feedsView.navigationItem.title=feed.name;
			
				[self.navigationController pushViewController:feedsView animated:YES];
				
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

- (void) refreshButtonTouch:(id)sender
{
	UIBarButtonItem * button=(UIBarButtonItem*)sender;
	
	if([[[UIApplication sharedApplication] delegate] isUpdating])
	{
		[[[UIApplication sharedApplication] delegate] cancelUpdate];
	}
	else 
	{
		// start
		if([fetcher isKindOfClass:[AccountFeedFetcher class]] ||
		   [fetcher isKindOfClass:[CategoryFeedFetcher class]])
		{
			// just update this account
			[[[UIApplication sharedApplication] delegate] updateSingleAccount:[fetcher accountName]];
		}
		else 
		{
			[[[UIApplication sharedApplication] delegate] update];
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
	[tableView release];
	[fetcher release];
	[super dealloc];
}

@end
