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

#define REFRESH_HEADER_HEIGHT 60.0f

@implementation FeedViewController
@synthesize tableView,folderMode,fetcher,dateFormatter,itemDelegate,favoritesMode,editable;
@synthesize textPull, origTitle,textRelease, navPopoverController,textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;
@synthesize twitter;

-(void)handleNotification:(NSNotification *)pNotification
{
	[self performSelectorOnMainThread:@selector(handleNotificationUI:) withObject:pNotification waitUntilDone:YES];
}
-(void)handleNotificationUI:(NSNotification *)pNotification
{
	if([pNotification.name isEqualToString:@"ReloadData"])
	{
		[tableView reloadData];
	}
	if([pNotification.name isEqualToString:@"SelectItem"])
	{
		[self selectItem:pNotification.object];
	}
	if([pNotification.name isEqualToString:@"AccountUpdated"])
	{
		NSString * accountName=[pNotification object];
		
		if([self.fetcher isKindOfClass:[AccountItemFetcher class]])
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
	self.navigationItem.title=self.origTitle;
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(organize:)] autorelease];
	self.navigationItem.rightBarButtonItem.style=UIBarButtonItemStylePlain;
	[[[UIApplication sharedApplication] delegate] hideSelectedView];
	
	self.tableView.editing=NO;
	
	[self.tableView reloadData];
}

- (void) organize:(id)sender
{
	if([fetcher count]==0) return;
	
	// enter edit mode and show message
	self.origTitle=self.navigationItem.title;
	
	self.navigationItem.title=@"Tap a folder or newsletter to add selected items.";
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOrganize)] autorelease];
	
	[[[UIApplication sharedApplication] delegate] showSelectedView];
	
	self.tableView.editing=YES;
	
	[self.tableView reloadData];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	
	self.tableView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
	
	BlankToolbar * tools=[[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
	
	tools.opaque=NO;
	tools.backgroundColor=[UIColor clearColor];
	
	[tools setItems:[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
												[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(organize:)] autorelease],
					 nil]];
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithCustomView:tools] autorelease];
	[tools release];
	
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
	 name:@"AccountUpdated"
	 object:nil];
	
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy h:mm a"];
	self.dateFormatter=format;
	[format release];
	
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
	statusLabel.frame=CGRectMake(0, 0, 180, 20);
	
	UIBarButtonItem * statusLabelItem=[[UIBarButtonItem alloc] initWithCustomView:statusLabel];
	
	[toolbaritems addObject:statusLabelItem];
	
	[statusLabelItem release];
	
	spacer= [[UIBarButtonItem alloc]
			 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	[toolbaritems addObject:spacer];
	[spacer release];
	
	if(editable)
	{
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
		UIBarButtonItem * actionButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
		[toolbaritems addObject:actionButton];
		[actionButton release];
	}

	[self.toolbar setItems:toolbaritems];
	
	[toolbaritems release];
	
	[fetcher performFetch];
	
    [super viewDidLoad];
	
	if(!folderMode)
	{
		if(fetcher)
		{
			[self addPullToRefreshHeader];
		}
	}
	
	[tableView reloadData];
}

- (void)addPullToRefreshHeader 
{
	self.textPull=@"Pull down to refresh...";
	self.textRelease=@"Release to refresh...";
	self.textLoading=@"Loading new items...";
	
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0-REFRESH_HEADER_HEIGHT, 320-80, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:14.0];
	refreshLabel.textColor=[UIColor lightGrayColor];
    refreshLabel.textAlignment = UITextAlignmentLeft;
	
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down.png"]];
    refreshArrow.frame = CGRectMake(48,
                                    ((REFRESH_HEADER_HEIGHT - 48) / 2)-REFRESH_HEADER_HEIGHT,
                                    48, 48);
	
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake(44+((REFRESH_HEADER_HEIGHT - 20) / 2), ((REFRESH_HEADER_HEIGHT - 20) / 2)-REFRESH_HEADER_HEIGHT, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
	
    [tableView addSubview:refreshLabel];
    [tableView addSubview:refreshArrow];
    [tableView addSubview:refreshSpinner];
}

- (void) actionButtonTouched:(id)sender
{
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Feed Actions" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Mark All as Read",@"Delete Older Than 7 Days",@"Delete Older Than 30 Days",@"Delete Older Than 90 Days",@"Delete Read Items",nil];
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
	
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	Feed * feed=nil;
	
	if([fetcher isKindOfClass:[FeedItemFetcher class]])
	{
		feed=[fetcher feed];
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
				[self.tableView reloadData];
				return;
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
		[self.tableView reloadData];
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
	[self.tableView reloadData];
}

- (IBAction) toggleEditMode:(id)sender
{
	
	UIBarButtonItem * buttonItem=(UIBarButtonItem*)sender;
	
	if(self.tableView.editing)
	{
		[self.tableView setEditing:NO animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleBordered;
		buttonItem.title=@"Edit";
		
		[self.tableView reloadData];
	}
	else
	{	
		if([fetcher count]>0)
		{
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
	 postNotificationName:@"ReloadActionData"
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
			[itemDelegate showItemHtml:indexPath.row itemFetcher:fetcher];
		}
	}
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(twitter)
	{
		return 70;
	}
	else 
	{
		return 70; 
		//return tableView.rowHeight;
	}
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
	
	CustomCellBackgroundView * gbView=[[[CustomCellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
	
	cell.backgroundView=gbView;
	
	gbView.fillColor=[UIColor blackColor]; 
	gbView.borderColor=[UIColor grayColor];
	
	cell.backgroundView.alpha=0.5;
	
	cell.textLabel.textColor=[UIColor lightGrayColor];
	
	cell.textLabel.textAlignment=UITextAlignmentCenter;

	[cell.backgroundView setPosition:CustomCellBackgroundViewPositionSingle];
	
	if(fetcher)
	{
		if(folderMode)
		{
			cell.textLabel.text=@"No items in folder. Add items from source feeds.";
		}
		else 
		{
			cell.textLabel.text=@"No items loaded. Pull down to load latest feed items.";
		}
	}
	else 
	{
		cell.textLabel.text=@"No feed selected. Select a source feed from the sources menu.";
	}

	return cell;
}

- (UITableViewCell *) tweetCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"TweetItemCellIdentifier";
	
	TweetTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[TweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;
	
	if(item.image)
	{
		cell.itemImageView.image=item.image;
	}
	else 
	{
		cell.itemImageView.image=[UIImage imageNamed:@"profileplaceholder.png"];
	}

	cell.tweetLabel.text=item.headline;
	cell.dateLabel.text=[item shortDisplayDate];
	cell.sourceLabel.text=item.origin;
	
	return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
	if (folderMode) {
		return;
	}
    if (isLoading) 
	{	
		return;
	}
	else 
	{
		isDragging = YES;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if(folderMode)
	{
		return;
	}
    if (isLoading) 
	{
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
		{
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
		else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
		{
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
		}
    } 
	else 
	{
		if (isDragging && scrollView.contentOffset.y < 0) 
		{
			// Update the arrow direction and label
			[UIView beginAnimations:nil context:NULL];
			if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) 
			{
				// User is scrolling above the header
				refreshLabel.text = self.textRelease;
				[refreshArrow layer].transform = CATransform3DMakeRotation(-M_PI, 0, 0, 1);
			} 
			else 
			{ 
				// User is scrolling somewhere within the header
				refreshLabel.text = self.textPull;
				[refreshArrow layer].transform = CATransform3DMakeRotation(-M_PI * 2, 0, 0, 1);
			}
			[UIView commitAnimations];
		}
		else 
		{
			if(scrollView.contentSize.height > tableView.frame.size.height)
			{
				if(scrollView.contentOffset.y > ((scrollView.contentSize.height - tableView.frame.size.height) + REFRESH_HEADER_HEIGHT))
				{
					[self backfill];
				}
			}
			else 
			{
				if(scrollView.contentOffset.y > REFRESH_HEADER_HEIGHT)
				{
					[self backfill];
				}
			}
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!folderMode)
	{
	if (isLoading) 
	{
		return;
	}
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) 
	{
        // Released above the header
        [self startLoading];
    }
	}
}

- (void)startLoading 
{
    isLoading = YES;
	
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
	
    // Refresh action!
    //[self refresh];
	[self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
}

- (void)stopLoading 
{	
	if(isLoading)
	{
		isLoading = NO;
		
		@try 
		{
			// Hide the header
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
			[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
			//self.tableView.contentInset = UIEdgeInsetsZero;
			[refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
			[UIView commitAnimations];
		}
		@catch (NSException * e) 
		{
		}
		@finally 
		{
		}
	}
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
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
		NSLog(@"updating singlefeed");
		[[[UIApplication sharedApplication] delegate] updateSingleFromScroll:[fetcher feed]];
		return;
	}
	else 
	{
		if([fetcher isKindOfClass:[AccountItemFetcher class]])
		{
			NSLog(@"updating single account");
			[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName]];
			return;
		}
		else 
		{
			[self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
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
		if([fetcher isKindOfClass:[AccountItemFetcher class]])
		{
			[[[UIApplication sharedApplication] delegate] updateSingleAccountFromScroll:[fetcher accountName]];
		}
	}
}

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
}

- (UITableViewCell *) headlineCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"FeedItemCellIdentifier";
	
	FeedItemCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[FeedItemCell alloc] initWithReuseIdentifier:identifier] autorelease];
	}
		
	cell.selectionStyle=UITableViewCellSelectionStyleGray;
		
	if([item.isRead boolValue])
	{
		cell.headlineLabel.textColor=[UIColor grayColor];
		cell.readImageView.image=[UIImage imageNamed:@"dot_blank.png"];
	}
	else 
	{
		cell.headlineLabel.textColor=[UIColor blackColor];
		cell.readImageView.image=[UIImage imageNamed:@"dot_blue.png"];
	}
	
	if([[item origSynopsis] length]>0)
	{
		if([[item synopsis] length]==0)
		{
			//item.synopsis=[stripper stripMarkup:[item origSynopsis]];
			// faster to just strip up to what we need to display...
			item.synopsis=[stripper stripMarkupSummary:[item origSynopsis] maxLength: 300];
		}
	}
	
	cell.synopsisLabel.text=[item synopsis];
	
	if([item.headline length]>0)
	{
		cell.headlineLabel.text=item.headline;
	}
	else 
	{
		if([item.synopsis length]>0)
		{
			cell.headlineLabel.text=item.synopsis;
		}
		else 
		{
			cell.headlineLabel.text=item.origSynopsis;
		}
	}
	
	cell.sourceLabel.text=item.origin;
	
	cell.dateLabel.text=[item shortDisplayDate];
	
	cell.sourceImageView.image=nil;
	
	if([item isKindOfClass:[RssFeedItem class]])
	{
		UIImage * img=[[((RssFeedItem*)item) feed] image];
		if(img)
		{
			cell.sourceImageView.image=img;
		}
	}
	
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
	 
	return 3;
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
		if([fetcher isKindOfClass:[FeedItemFetcher class]])
		{
			[[[UIApplication sharedApplication] delegate] updateSingle:[fetcher feed]];
		}
		else 
		{
			if([fetcher isKindOfClass:[AccountItemFetcher class]])
			{
				[[[UIApplication sharedApplication] delegate] updateSingleAccount:[fetcher accountName]];
			}
			else 
			{
				[[[UIApplication sharedApplication] delegate] update];
			}
		}
	}
}

- (void)dealloc {
	[tableView release];
	[origTitle release];
	[fetcher release];
	[dateFormatter release];
	[navPopoverController release];
	[refreshHeaderView release];
    [refreshLabel release];
    [refreshArrow release];
    [refreshSpinner release];
    [textPull release];
    [textRelease release];
    [textLoading release];
	[stripper release];
    [super dealloc];
}

@end




