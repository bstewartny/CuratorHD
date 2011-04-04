#import "HomeViewController.h"
#import "ItemFetcher.h"
#import "FeedFetcher.h"
#import "AQGridViewCell.h"
#import "FeedsViewController.h"
#import "FeedAccount.h"
#import "Feed.h"
#import "BadgeView.h"
#import "FeedFetcher.h"
#import "FoldersViewController.h"
#import "UserSettings.h"

#define gridViewCellImageWidth 64.0
#define gridViewCellWidth 128.0
#define gridViewCellHeight 124.0

@implementation HomeViewController
@synthesize sourcesFetcher,newslettersFetcher,foldersFetcher;
@synthesize tableView;

- (id) init
{
	if(self=[super initWithNibName:@"HomeView" bundle:nil])
	{
		self.tableView.backgroundColor=[UIColor blueColor];
		[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
		self.view.backgroundColor=[UIColor viewFlipsideBackgroundColor];
		self.tableView.showsVerticalScrollIndicator=NO;
		self.tableView.showsHorizontalScrollIndicator=NO;
	}
	return self;
}

- (AQGridView*) gridViewForSection:(NSInteger)section width:(CGFloat)width
{
	CGFloat height=[self heightForSection:section width:width];
	
	AQGridView * gridView=[[AQGridView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	
	gridView.autoresizesSubviews = YES;
	gridView.delegate = self;
	gridView.dataSource = self;
	gridView.separatorStyle = AQGridViewCellSeparatorStyleEmptySpace;
	gridView.separatorColor = [UIColor clearColor];
	gridView.backgroundColor=[UIColor clearColor];
	gridView.opaque=NO;
	gridView.scrollEnabled=NO;
	
	gridView.showsVerticalScrollIndicator=NO;
	gridView.showsHorizontalScrollIndicator=NO;
	
	if(section>0)
	{
		UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(moveActionGestureRecognizerStateChanged:)];
		gr.minimumPressDuration = 0.5;
		gr.delegate = self;
		gr.delaysTouchesBegan=YES;
		[gridView addGestureRecognizer: gr];
		[gr release];
	}
	return [gridView autorelease];
}

- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
	AQGridView * gridView=(AQGridView*)gestureRecognizer.view;
	
    CGPoint location = [gestureRecognizer locationInView: gridView];
	
	int numItems=[self numberOfItemsInSection:gridView.tag]-1;
	
	if(numItems>0)
	{
		if ( [gridView indexForItemAtPoint: location] < numItems )
		{
			[self startEditModeForGridView:gridView];
			//[self startEditMode:gridView];
			return YES;
		}
    }
	
    return NO;
}
/*
- (void) startEditMode:(AQGridView*)gridView
{
	if(!editMode)
	{
		editMode=YES;
		
		
		[self toggleEditMode];
	}
}*/

- (void) moveActionGestureRecognizerStateChanged: (UIGestureRecognizer *) recognizer
{
	AQGridView * gridView=(AQGridView*)recognizer.view;
	
	if(gridView==nil)
	{
		return;
	}
	
    switch ( recognizer.state )
    {
        default:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        	break;
        
		case UIGestureRecognizerStateEnded:
        {
            CGPoint p = [recognizer locationInView: gridView];
            NSUInteger index = [gridView indexForItemAtPoint: p];
			
			int lastIndexToMoveTo=[self numberOfItemsInSection:gridView.tag]-2;
			
			if ( index == NSNotFound )
			{
				index=lastIndexToMoveTo;
			}
			
            if(index>lastIndexToMoveTo)
			{
				index=lastIndexToMoveTo;
			}
            
			if(_dragOriginIndex!=index)
			{
				[[self fetcherForSection:gridView.tag] moveItemFromIndex:_dragOriginIndex toIndex:index];
			}    
			
			if ( index != _emptyCellIndex )
            {
                [gridView beginUpdates];
                [gridView moveItemAtIndex: _emptyCellIndex toIndex: index withAnimation: AQGridViewItemAnimationFade];
                _emptyCellIndex = index;
                [gridView endUpdates];
            }
            
            [UIView beginAnimations: @"SnapToPlace" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.3];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect r = [gridView rectForItemAtIndex: _emptyCellIndex];
			
			CGRect f = _draggingCell.frame;
			
			CGRect frameInGridView=[self.view convertRect: r fromView: gridView];
			
            f.origin.x = frameInGridView.origin.x + floorf((frameInGridView.size.width - f.size.width) * 0.5);
            f.origin.y = frameInGridView.origin.y + floorf((frameInGridView.size.height - f.size.height) * 0.5);
			
            _draggingCell.frame = f;
            
            _draggingCell.transform = CGAffineTransformIdentity;
            _draggingCell.alpha = 1.0;
            
            [UIView commitAnimations];
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            NSUInteger index = [gridView indexForItemAtPoint: [recognizer locationInView: gridView]];
            _emptyCellIndex = index;    // we'll put an empty cell here now
            
            AQGridViewCell * sourceCell = [gridView cellForItemAtIndex: index];
            CGRect frame = [self.view convertRect: sourceCell.frame fromView: gridView];
			
			[_draggingCell release];
			
			_draggingGridView=gridView;
			
			_draggingCell=[[AQGridViewCell alloc] initWithFrame:frame reuseIdentifier:@"draggingCell"];
			
			[self configureGridViewCell:_draggingCell forIndex:index inSection:gridView.tag editing:editMode];
			
			[self.view addSubview: _draggingCell];
            
            _dragOriginCellOrigin = frame.origin;
            _dragOriginIndex = index;
            
            [UIView beginAnimations: @"" context: NULL];
            [UIView setAnimationDuration: 0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            
            _draggingCell.transform = CGAffineTransformMakeScale( 1.2, 1.2 );
            _draggingCell.alpha = 0.7;
            _draggingCell.center = [recognizer locationInView: self.view];
            
            [UIView commitAnimations];
            
			[gridView reloadData];
            //[gridView reloadItemsAtIndices: [NSIndexSet indexSetWithIndex: index]
              //                withAnimation: AQGridViewItemAnimationNone];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            _draggingCell.center = [recognizer locationInView: self.view];
            
            if ( gridView.isAnimatingUpdates )
                break;
            
			CGPoint location=[recognizer locationInView:gridView];
			
			NSUInteger index = [gridView indexForItemAtPoint: location];
			
			if ( index == NSNotFound )
			{
				index=[self numberOfItemsInSection:gridView.tag]-2;
			}
			
            if ( index != _emptyCellIndex )
            {
                [gridView beginUpdates];
                
                if ( index < _emptyCellIndex )
                {
                    for ( NSUInteger i = index; i < _emptyCellIndex; i++ )
                    {
                        [gridView moveItemAtIndex: i toIndex: i+1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                else
                {
                    for ( NSUInteger i = index; i > _emptyCellIndex; i-- )
                    {
                        [gridView moveItemAtIndex: i toIndex: i-1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                
                [gridView moveItemAtIndex: _emptyCellIndex toIndex: index withAnimation: AQGridViewItemAnimationFade];
                _emptyCellIndex = index;
                
                [gridView endUpdates];
            }
            
            break;
        }
    }
}

- (void) finishedSnap: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context
{
    NSIndexSet * indices = [[NSIndexSet alloc] initWithIndex: _emptyCellIndex];
    _emptyCellIndex = NSNotFound;
    
    [_draggingGridView reloadItemsAtIndices: indices withAnimation: AQGridViewItemAnimationNone];
    _draggingGridView=nil;
	[_draggingCell removeFromSuperview];
    [_draggingCell release];
    _draggingCell = nil;
    
    [indices release];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	_emptyCellIndex = NSNotFound;

	self.tableView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	self.view.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	self.tableView.showsVerticalScrollIndicator=NO;
	self.tableView.showsHorizontalScrollIndicator=NO;
	
	self.navigationItem.title=@"InfoNgen Newsletter Publisher";
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEditMode)] autorelease];
		
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"ReloadData"
	 object:nil];
}


- (IBAction) startEditModeForGridView:(AQGridView*)gridView
{
	UIBarButtonItem * buttonItem=self.navigationItem.rightBarButtonItem;
	
	//_draggingGridView=gridView;
	
	if(!editMode)
	{
		editMode=YES;
		buttonItem.style=UIBarButtonItemStyleDone;
		buttonItem.title=@"Done";
	}
	//[gridView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	
	//[gridView reloadData];
}

- (IBAction) toggleEditMode
{
	UIBarButtonItem * buttonItem=self.navigationItem.rightBarButtonItem;
	
	if(editMode)
	{
		editMode=NO;
		buttonItem.style=UIBarButtonItemStyleBordered;
		buttonItem.title=@"Edit";
	}
	else
	{
		editMode=YES;
		buttonItem.style=UIBarButtonItemStyleDone;
		buttonItem.title=@"Done";
	}
	
	[self reloadData];
}

-(void)handleReloadData:(NSNotification *)pNotification
{
	[self performSelectorOnMainThread:@selector(handleReloadDataUI:) withObject:pNotification waitUntilDone:YES];
}

-(void)handleReloadDataUI:(NSNotification *)pNotification
{
	if([pNotification.name isEqualToString:@"ReloadData"])
	{
		[self reloadData];
	}
	if([pNotification.name isEqualToString:@"ReloadActionData"])
	{
		[self reloadData];
	}
} 

- (void) reloadData
{
	_draggingGridView=nil;
	
	[sourcesFetcher performFetch];
	[newslettersFetcher performFetch];
	[foldersFetcher performFetch];
	[tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self reloadData];
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
	return ( CGSizeMake(gridViewCellWidth, gridViewCellHeight) );
}

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
	return [self numberOfItemsInSection:aGridView.tag];
}

- (void) close:(id)sender
{
	[[[UIApplication sharedApplication] delegate] hideHomeScreen];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self heightForSection:indexPath.section width:tableView.bounds.size.width];
}
					
- (CGFloat) heightForSection:(NSInteger)section width:(CGFloat)width
{
	int count=[self numberOfItemsInSection:section];
	int numPerRow=width / gridViewCellWidth;
	int rows=(count +1) / numPerRow;
	rows++;
	return rows * gridViewCellHeight;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (int) numberOfItemsInSection:(NSInteger)section
{
	return [[self fetcherForSection:section] count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	cell.backgroundView=[[[UIView alloc] init] autorelease];
	cell.backgroundView.backgroundColor=[UIColor clearColor];
	
	cell.backgroundColor=[UIColor clearColor];
	
	cell.contentView.backgroundColor=[UIColor clearColor];
	
	AQGridView * gridView=[self gridViewForSection:indexPath.section width:tableView.bounds.size.width];
	
	gridView.tag=indexPath.section;
	
	[cell.contentView addSubview:gridView];
	
	[gridView reloadData];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView * v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self tableView:tableView heightForHeaderInSection:section])];
	v.backgroundColor=[UIColor clearColor];
	
	UILabel * label=[[UILabel alloc] init];
	
	label.textColor=[UIColor whiteColor];
	label.font=[UIFont boldSystemFontOfSize:17];
	label.shadowColor=[UIColor blackColor];
	label.shadowOffset=CGSizeMake(0, 1);
	
	switch (section) {
		case 0:
			label.text= @"Sources";
			break;
		case 1:
			label.text= @"Folders";
			break;
		case 2:
			label.text= @"Newsletters";
			break;
	}
	
	label.backgroundColor=[UIColor clearColor];
	
	[label sizeToFit];
	
	CGRect f=label.frame;
	f.origin.x=15;
	f.origin.y=(v.frame.size.height/2)-(f.size.height/2);
	label.frame=f;
	
	[v addSubview:label];
	
	[label release];
	
	return [v autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section==0)
		return 60;
	else 
		return 90;
}

- (void) configureGridViewCell:(AQGridViewCell*)cell forIndex:(NSUInteger)index inSection:(int)section editing:(BOOL)isEditing
{
	UIImage * image;
	NSString * itemname;
	int badgeCount=-1;
	
	BOOL showDeleteButton=isEditing;
	
	switch(section)
	{
		case 0:
			
			if(index>=[sourcesFetcher count])
			{
				itemname=@"Add Source";
				image=[UIImage imageNamed:@"additem.png"];
				showDeleteButton=NO;
			}
			else 
			{
				itemname=[[sourcesFetcher itemAtIndex:index] name];
				
				if([itemname isEqualToString:@"Google Reader"])
				{
					image=[UIImage imageNamed:@"64-googlreader.png"];
				}
				if([itemname isEqualToString:@"Twitter"])
				{
					image=[UIImage imageNamed:@"64-twitter.png"];
				}
				if([itemname isEqualToString:@"InfoNgen"])
				{
					image=[UIImage imageNamed:@"64-infongen.png"];
				}
			}
			break;
		case 1:
			if(index>=[foldersFetcher count])
			{
				itemname=@"Add Folder";
				image=[UIImage imageNamed:@"additem.png"];
				showDeleteButton=NO;
			}
			else 
			{
				badgeCount=[[[self foldersFetcher] itemAtIndex:index] itemCount];
				itemname=[[foldersFetcher itemAtIndex:index] name];
				image=[UIImage imageNamed:@"64-folderclosed.png"];
			}
			break;
			
		case 2:
			if(index>=[newslettersFetcher count])
			{
				itemname=@"Add Newsletter";
				image=[UIImage imageNamed:@"additem.png"];
				showDeleteButton=NO;
			}
			else 
			{
				badgeCount=[[[self newslettersFetcher] itemAtIndex:index] itemCount];
				itemname=[[newslettersFetcher itemAtIndex:index] name];
				image=[UIImage imageNamed:@"64-newsletter.png"];
			}
			break;
	}
	
	UIImageView * iv=[[UIImageView alloc] initWithFrame:CGRectMake((gridViewCellWidth-gridViewCellImageWidth)/2, 10, gridViewCellImageWidth, gridViewCellImageWidth)];
	iv.image=image;
	iv.contentMode=UIViewContentModeCenter;
	iv.backgroundColor=[UIColor clearColor];
	
	UILabel * name=[[UILabel alloc] initWithFrame:CGRectMake(5,gridViewCellHeight-45, gridViewCellWidth-10,40)];
	name.font=[UIFont boldSystemFontOfSize:12];
	name.backgroundColor=[UIColor clearColor];
	name.numberOfLines=2;
	name.textAlignment=UITextAlignmentCenter;
	name.textColor=[UIColor whiteColor];
	name.text=itemname;
	cell.backgroundColor=[UIColor clearColor];
	
	cell.contentView.backgroundColor=[UIColor clearColor];
	
	[cell.contentView addSubview:iv];
	[cell.contentView addSubview:name];
	if(badgeCount>-1)
	{
		BadgeView * badge=[[BadgeView alloc] initWithFrame:CGRectMake(gridViewCellWidth-30, 0, 30, 20)];
		badge.badgeString=[NSString stringWithFormat:@"%d",badgeCount];
		[badge sizeToFit];
		
		badge.frame=CGRectMake(((gridViewCellWidth-badge.frame.size.width)-((gridViewCellWidth-gridViewCellImageWidth)/2))+6,2, badge.frame.size.width, badge.frame.size.height);
		
		[cell.contentView addSubview:badge];
		
		[badge release];
	}
	
	if(showDeleteButton)
	{
		UIButton * deleteButton=[UIButton buttonWithType:UIButtonTypeCustom];
		[deleteButton setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
		[deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
		[deleteButton sizeToFit];
		//deleteButton.tag=index;
		deleteButton.backgroundColor=[UIColor clearColor];		
		deleteButton.frame=CGRectMake(((gridViewCellWidth-gridViewCellImageWidth)/2) - 14, 0, 29, 29);
		[cell.contentView addSubview:deleteButton];
	}

	[iv release];
	[name release];
}

- (void) showDeleteConfirm:(int)section index:(int)index
{
	Feed * feed=[self feedForSection:section index:index];
	_deleteSection=section;
	_deleteIndex=index;
	UIAlertView * alert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete \"%@\"",[feed name]] message:[NSString stringWithFormat:@"Deleting \"%@\" will also delete all of its data.",[feed name]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
	alert.tag=index;
	[alert show];
	
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1) 
	{
		[self doDeleteItem:_deleteGridView section:_deleteSection index:_deleteIndex];
	}
}

- (id) fetcherForSection:(int)section
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

- (Feed*) feedForSection:(int)section index:(int)index
{
	return [[self fetcherForSection:section] itemAtIndex:index];
}
- (AQGridView*) gridViewForView:(UIView*)v
{
	while(true)
	{
		UIView * s=[v superview];
		if(s==nil) break;
		if([s isKindOfClass:[AQGridView class]])
		{
			return s;
		}
		v=s;
	}
	return nil;
}

- (AQGridViewCell*) gridViewCellForView:(UIView*)v
{
	while(true)
	{
		UIView * s=[v superview];
		if(s==nil) break;
		if([s isKindOfClass:[AQGridViewCell class]])
		{
			return s;
		}
		v=s;
	}
	return nil;
}

- (void) deleteItem:(UIButton*)sender
{
	AQGridView * gridView=[self gridViewForView:sender];
	
	if(gridView)
	{
		AQGridViewCell * gridViewCell=[self gridViewCellForView:sender];
	
		if(gridViewCell)
		{
			int index=[gridView indexForCell:gridViewCell];
	
			_deleteGridView=gridView;
			
			[self showDeleteConfirm:gridView.tag index:index];
	
			
			
		}
	}
}

- (void) doDeleteItem:(AQGridView*)gridView section:(int)section index:(int)index
{
	id fetcher=[self fetcherForSection:section];
	
	if(section==0)
	{
		FeedAccount * account=[fetcher itemAtIndex:index];
		
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
	}
	
	[fetcher deleteItemAtIndex:index];
	[fetcher performFetch];
	
	[gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex: index] withAnimation:AQGridViewItemAnimationFade];
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
	AQGridViewCell * cell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, gridViewCellWidth, gridViewCellHeight)
												   reuseIdentifier: [NSString stringWithFormat:@"cellIdentifier%d",index]] autorelease];
	if ( index == _emptyCellIndex )
    {
        cell.hidden = YES;
        
		return cell;
    }
	
	cell.selectionStyle = AQGridViewCellSelectionStyleNone;
	
	[self configureGridViewCell:cell forIndex:index inSection:aGridView.tag editing:editMode];
	
	return cell;
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	[gridView deselectItemAtIndex:index animated:NO];
	
	id appDelegate=[[UIApplication sharedApplication] delegate];
	
	switch(gridView.tag)
	{
		case 0:
			
			if(index>=[sourcesFetcher count] || editMode)
			{
				// add source
				[appDelegate showAccountSettingsForm];
			}
			else 
			{
				FeedAccount * account=[[self sourcesFetcher] itemAtIndex:index];
				
				// go to source
				ItemFetcher * feedFetcher=[account feedFetcher];
				
				NSArray * feeds=[feedFetcher items];
				
				Feed * firstFeed=nil;
				
				if([feeds count]>0)
				{
					firstFeed=[feeds objectAtIndex:0];
				}
				
				FeedsViewController * feedsView=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
				
				feedsView.items=feeds;
				feedsView.editable=NO;
				feedsView.fetcher=feedFetcher;
				feedsView.title=account.name;
				feedsView.itemDelegate=appDelegate;
				
				feedsView.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:appDelegate action:@selector(showHomeScreen)] autorelease];
				
				[[appDelegate masterNavController] setViewControllers:[NSArray arrayWithObject:feedsView] animated:NO];
				
				[appDelegate hideHomeScreen];
				
				if(firstFeed)
				{
					[appDelegate showFeed:firstFeed delegate:appDelegate editable:NO];
				}
				
				[feedsView release];
			}
			break;
			
		case 1:
			if(index>=[foldersFetcher count])
			{
				// add folder
				[appDelegate addFolder];
			}
			else 
			{
				// go to folder
				if(!editMode)
				{
					FoldersViewController * feedsView=[[FoldersViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
					
					feedsView.fetcher=foldersFetcher;
					feedsView.delegate=appDelegate;
					feedsView.selectedRow=index;
					
					[[appDelegate masterNavController] setViewControllers:[NSArray arrayWithObject:feedsView] animated:NO];
					
					Folder * folder=[[self foldersFetcher] itemAtIndex:index];
					[appDelegate hideHomeScreen];
					[appDelegate showFolder:folder delegate:appDelegate editable:YES];
					
					[feedsView release];
				}
				else 
				{
					// edit folder name
					
					[[[UIApplication sharedApplication] delegate] editFolderName:[foldersFetcher itemAtIndex:index]];
					 
										
					
				}
			}
			break;
			
		case 2:
			if(index>=[newslettersFetcher count])
			{
				// add newsletter
				[appDelegate addNewsletter];
			}
			else 
			{
				if(!editMode)
				{
					FoldersViewController * feedsView=[[FoldersViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
					
					feedsView.fetcher=newslettersFetcher;
					feedsView.delegate=appDelegate;
					feedsView.selectedRow=index;
					
					[[appDelegate masterNavController] setViewControllers:[NSArray arrayWithObject:feedsView] animated:NO];
					
					// go to newsletter
					Newsletter * newsletter=[[self newslettersFetcher] itemAtIndex:index];
					[appDelegate hideHomeScreen];
					[appDelegate showNewsletter:newsletter delegate:appDelegate editable:YES];
					
					[feedsView release];
				}
				else 
				{
					// edit newsletter name	
					// edit newsleter
					[[[UIApplication sharedApplication] delegate] editNewsletterName:[newslettersFetcher itemAtIndex:index]];
					
					
				}
			}
			break;
	}	 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)dealloc 
{
	[tableView release];
	[sourcesFetcher release];
	[newslettersFetcher release];
	[foldersFetcher release];
    [super dealloc];
}

@end
