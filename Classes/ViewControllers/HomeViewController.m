#import "HomeViewController.h"
#import "ItemFetcher.h"
#import "FeedFetcher.h"
#import "AQGridViewCell.h"
#import "FeedsViewController.h"
#import "FeedAccount.h"
#import "Feed.h"
#import "BadgeView.h"

#define gridViewCellWidth 84.0
#define gridViewCellHeight 124.0

@implementation HomeViewController
@synthesize sourcesFetcher,newslettersFetcher,foldersFetcher;
//@synthesize gridView;
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
	
	if(numItems>1)
	{
		if ( [gridView indexForItemAtPoint: location] < numItems )
		{
			[self startEditMode:gridView];
			return ( YES );
		}
    }
    // touch is outside the bounds of any icon cells, so don't start the gesture
    return ( NO );
}

- (void) startEditMode:(AQGridView*)gridView
{
	gridView.editing=YES;
	[gridView reloadData];
	[gridView updateVisibleGridCellsNow];
}

- (void) endEditMode:(AQGridView*)gridView
{
	gridView.editing=NO;
	[gridView reloadData];
	[gridView updateVisibleGridCellsNow];
}

- (void) moveActionGestureRecognizerStateChanged: (UIGestureRecognizer *) recognizer
{
	AQGridView * gridView=(AQGridView*)recognizer.view;
	
	if(gridView==nil)
	{
		NSLog(@"recognizer.view is nil!");
		return;
	}
	
    switch ( recognizer.state )
    {
        default:
        case UIGestureRecognizerStateFailed:
            // do nothing
            break;
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        {
			NSLog(@"No implementation for UIGestureRecognizerStateCancelled!!!");
            /*[gridView beginUpdates];
            
            if ( _emptyCellIndex != _dragOriginIndex )
            {
                [gridView moveItemAtIndex: _emptyCellIndex toIndex: _dragOriginIndex withAnimation: AQGridViewItemAnimationFade];
            }
            
            _emptyCellIndex = _dragOriginIndex;
            
            // move the cell back to its origin
            [UIView beginAnimations: @"SnapBack" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.5];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect f = _draggingCell.frame;
            f.origin = _dragOriginCellOrigin;
            _draggingCell.frame = f;
			NSLog(@"set draggingCell.frame=%@",NSStringFromCGRect(_draggingCell.frame));
            
            [UIView commitAnimations];
            
            [gridView endUpdates];
            */
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint p = [recognizer locationInView: gridView];
            NSUInteger index = [gridView indexForItemAtPoint: p];
			
			int lastIndexToMoveTo=[self numberOfItemsInSection:gridView.tag]-2;
			
			if ( index == NSNotFound )
			{
				// index is the last available location
				index=lastIndexToMoveTo;
			}
			
            if(index>lastIndexToMoveTo)
			{
				index=lastIndexToMoveTo;
			}
            
			if(_dragOriginIndex!=index)
			{
				// update the data store
				switch (gridView.tag) 
				{
					case 0:
						[sourcesFetcher moveItemFromIndex:_dragOriginIndex toIndex:index];
						break;
					case 1:
						[foldersFetcher moveItemFromIndex:_dragOriginIndex toIndex:index];
						break;
					case 2:
						[newslettersFetcher moveItemFromIndex:_dragOriginIndex toIndex:index];
						break;
				}
			}
            
			if ( index != _emptyCellIndex )
            {
                [gridView beginUpdates];
                [gridView moveItemAtIndex: _emptyCellIndex toIndex: index withAnimation: AQGridViewItemAnimationFade];
                _emptyCellIndex = index;
                [gridView endUpdates];
            }
            
            // move the real cell into place
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
            
            // find the cell at the current point and copy it into our main view, applying some transforms
            AQGridViewCell * sourceCell = [gridView cellForItemAtIndex: index];
            CGRect frame = [self.view convertRect: sourceCell.frame fromView: gridView];
			
			[_draggingCell release];
			
			_draggingGridView=gridView;
			
			_draggingCell=[[AQGridViewCell alloc] initWithFrame:frame reuseIdentifier:@""];
			
			[self configureGridViewCell:_draggingCell forIndex:index inSection:gridView.tag editing:gridView.editing];
			
			[self.view addSubview: _draggingCell];
            
            // grab some info about the origin of this cell
            _dragOriginCellOrigin = frame.origin;
            _dragOriginIndex = index;
            
            [UIView beginAnimations: @"" context: NULL];
            [UIView setAnimationDuration: 0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            
            // transformation-- larger, slightly transparent
            _draggingCell.transform = CGAffineTransformMakeScale( 1.2, 1.2 );
            _draggingCell.alpha = 0.7;
            
            // also make it center on the touch point
            _draggingCell.center = [recognizer locationInView: self.view];
            
            [UIView commitAnimations];
            
            // reload the grid underneath to get the empty cell in place
            [gridView reloadItemsAtIndices: [NSIndexSet indexSetWithIndex: index]
                              withAnimation: AQGridViewItemAnimationNone];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            // update draging cell location
            _draggingCell.center = [recognizer locationInView: self.view];
            
            // don't do anything with content if grid view is in the middle of an animation block
            if ( gridView.isAnimatingUpdates )
                break;
            
			CGPoint location=[recognizer locationInView:gridView];
			
			// update empty cell to follow, if necessary
            NSUInteger index = [gridView indexForItemAtPoint: location];
			
			// don't do anything if it's over an unused grid cell
			if ( index == NSNotFound )
			{
				// snap back to the last possible index
				index=[self numberOfItemsInSection:gridView.tag]-2;
			}
			
            if ( index != _emptyCellIndex )
            {
                NSLog( @"Moving empty cell from %u to %u", _emptyCellIndex, index );
                
                // batch the movements
                [gridView beginUpdates];
                
                // move everything else out of the way
                if ( index < _emptyCellIndex )
                {
                    for ( NSUInteger i = index; i < _emptyCellIndex; i++ )
                    {
                        NSLog( @"Moving %u to %u", i, i+1 );
                        [gridView moveItemAtIndex: i toIndex: i+1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                else
                {
                    for ( NSUInteger i = index; i > _emptyCellIndex; i-- )
                    {
                        NSLog( @"Moving %u to %u", i, i-1 );
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
    
    // load the moved cell into the grid view
	[_draggingGridView reloadItemsAtIndices: indices withAnimation: AQGridViewItemAnimationNone];
    
	_draggingGridView=nil;
	
    // dismiss our copy of the cell
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
	
	self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)] autorelease];

	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleReloadData:)
	 name:@"ReloadData"
	 object:nil];
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
	switch (section) 
	{
		case 0:
			return [sourcesFetcher count]+1;
		case 1:
			return [foldersFetcher count]+1;
		case 2:
			return [newslettersFetcher count]+1;
	}
	return 0;
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
		return 40;
	else 
		return 80;
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
				if(isEditing)
				{
					itemname=@"Cancel";
				}
				else {
					itemname=@"Add Folder";
				}
				image=[UIImage imageNamed:@"additem.png"];
				showDeleteButton=NO;
			}
			else {
				badgeCount=[[[self foldersFetcher] itemAtIndex:index] itemCount];
				itemname=[[foldersFetcher itemAtIndex:index] name];
				image=[UIImage imageNamed:@"64-folderclosed.png"];
			}
			break;
			
		case 2:
			if(index>=[newslettersFetcher count])
			{
				if(isEditing)
				{
					itemname=@"Cancel";
				}
				else {
					itemname=@"Add Newsletter";
				}
				
				image=[UIImage imageNamed:@"additem.png"];
				showDeleteButton=NO;
			}
			else {
				badgeCount=[[[self newslettersFetcher] itemAtIndex:index] itemCount];
				itemname=[[newslettersFetcher itemAtIndex:index] name];
				image=[UIImage imageNamed:@"64-newsletter.png"];
			}
			break;
	}
	
	UIImageView * iv=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, cell.frame.size.width-10, cell.frame.size.height-50)];
	iv.image=image;
	iv.contentMode=UIViewContentModeCenter;
	iv.backgroundColor=[UIColor clearColor];
	
	UILabel * name=[[UILabel alloc] initWithFrame:CGRectMake(2,cell.frame.size.height-45, cell.frame.size.width-4,40)];
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
		
		BadgeView * badge=[[BadgeView alloc] initWithFrame:CGRectMake(cell.frame.size.width-30, 0, 30, 20)];
		badge.badgeString=[NSString stringWithFormat:@"%d",badgeCount];
		[badge sizeToFit];
		
		badge.frame=CGRectMake(cell.frame.size.width-badge.frame.size.width,0, badge.frame.size.width, badge.frame.size.height);
		
		[cell.contentView addSubview:badge];
		
		[badge release];
		
	}
	
	if(showDeleteButton)
	{
		UIButton * deleteButton=[UIButton buttonWithType:UIButtonTypeCustom];
		[deleteButton setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
		[deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
		[deleteButton sizeToFit];
		deleteButton.tag=index;
		deleteButton.backgroundColor=[UIColor clearColor];
		
		deleteButton.frame=CGRectMake(2, 0, 29, 29);
		[cell.contentView addSubview:deleteButton];
	}
	
	
	
	[iv release];
	[name release];
}

- (void) deleteItem:(UIButton*)sender
{
	// what item is it?
	int index=sender.tag;
	
	// what section is it?
	AQGridView * gridView=nil;
	 
	UIView * v=sender;
	while(true)
	{
		UIView * s=[v superview];
		if(s==nil) break;
		if([s isKindOfClass:[AQGridView class]])
		{
			gridView=s;
			break;
		}
		v=s;
	}
	
	if(gridView)
	{
		int section=gridView.tag;
	 
		switch (section) {
			case 0:
				[sourcesFetcher deleteItemAtIndex:index];
				[sourcesFetcher performFetch];
				[gridView reloadData];
				break;
			case 1:
				[foldersFetcher deleteItemAtIndex:index];
				[foldersFetcher performFetch];
				[gridView reloadData];
				break;
			case 2:
				[newslettersFetcher deleteItemAtIndex:index];
				[newslettersFetcher performFetch];
				[gridView reloadData];
				break;
		}
		
	}
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
	AQGridViewCell * cell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, gridViewCellWidth, gridViewCellHeight)
                                                reuseIdentifier: @""] autorelease];
	if ( index == _emptyCellIndex )
    {
        cell.hidden = YES;
        
		return cell;
    }
	
	cell.selectionStyle = AQGridViewCellSelectionStyleNone;
	
	[self configureGridViewCell:cell forIndex:index inSection:aGridView.tag editing:aGridView.editing];
	
	return cell;
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	id appDelegate=[[UIApplication sharedApplication] delegate];
	
	if(gridView.editing)
	{
		switch(gridView.tag)
		{
			case 0:
				if(index>=[sourcesFetcher count])
				{
					// cancel editing
					gridView.editing=NO;
					[gridView reloadData];
					
				}
				break;
			case 1:
				if(index>=[foldersFetcher count])
				{
					// cancel editing
					gridView.editing=NO;
					[gridView reloadData];
				}
				break;
			case 2:
				if(index>=[newslettersFetcher count])
				{
					// cancel editing
					gridView.editing=NO;
					[gridView reloadData];
				}
				break;
		}
		
	}
	else 
	{
		switch(gridView.tag)
		{
			case 0:
				if(index>=[sourcesFetcher count])
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
					
					// go back to root view
					[[appDelegate masterNavController] popToRootViewControllerAnimated:NO];
					[[appDelegate masterNavController] pushViewController:feedsView animated:YES];
					
					[appDelegate hideHomeScreen];
					
					if(firstFeed)
					{
						[appDelegate showFeed:firstFeed delegate:appDelegate editable:NO];
						
						[feedsView.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]   animated:NO scrollPosition:UITableViewScrollPositionNone];
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
					Folder * folder=[[self foldersFetcher] itemAtIndex:index];
					[appDelegate hideHomeScreen];
					[appDelegate showFolder:folder delegate:appDelegate editable:YES];
				}
				break;
				
			case 2:
				if(index>=[newslettersFetcher count])
				{
					// add newsletter
					[[[UIApplication sharedApplication] delegate] addNewsletter];
				}
				else 
				{
					// go to newsletter
					Newsletter * newsletter=[[self newslettersFetcher] itemAtIndex:index];
					[appDelegate hideHomeScreen];
					[appDelegate showNewsletter:newsletter delegate:appDelegate editable:YES];
				}
				break;
		}
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
