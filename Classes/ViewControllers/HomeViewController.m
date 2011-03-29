#import "HomeViewController.h"
#import "ItemFetcher.h"
#import "FeedFetcher.h"
#import "AQGridViewCell.h"

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
		NSLog(@"setup table bg color");
		/*self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		self.gridView.autoresizesSubviews = YES;
		self.gridView.delegate = self;
		self.gridView.dataSource = self;
		self.gridView.separatorStyle = AQGridViewCellSeparatorStyleEmptySpace;
		self.gridView.separatorColor = [UIColor blackColor];
		self.gridView.backgroundColor=[UIColor blackColor];*/
		self.tableView.backgroundColor=[UIColor blueColor];
		[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
		//self.tableView.backgroundView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
		self.view.backgroundColor=[UIColor greenColor];
		self.tableView.showsVerticalScrollIndicator=NO;
		self.tableView.showsHorizontalScrollIndicator=NO;
	}
	return self;
}

- (AQGridView*) gridViewForSection:(NSInteger)section width:(CGFloat)width
{
	CGFloat height=[self heightForSection:section width:width];
	
	AQGridView * gridView=[[AQGridView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	
	//gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	gridView.autoresizesSubviews = YES;
	gridView.delegate = self;
	gridView.dataSource = self;
	gridView.separatorStyle = AQGridViewCellSeparatorStyleEmptySpace;
	gridView.separatorColor = [UIColor clearColor];
	gridView.backgroundColor=[UIColor clearColor];
	//gridView.backgroundView=[[[UIView alloc] init] autorelease];
	//gridView.backgroundView.backgroundColor=[UIColor clearColor];
	gridView.opaque=NO;
	
	gridView.showsVerticalScrollIndicator=NO;
	gridView.showsHorizontalScrollIndicator=NO;
	
	return [gridView autorelease];
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self reloadData];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	
	self.tableView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	//self.tableView.backgroundView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
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
	[sourcesFetcher performFetch];
	[newslettersFetcher performFetch];
	[foldersFetcher performFetch];
	[tableView reloadData];
	
	/*[gridView reloadData];
	[gridView updateVisibleGridCellsNow];*/
}

- (void)viewDidAppear:(BOOL)animated
{
	[self reloadData];
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
	NSLog(@"portraitGridCellSizeForGridView");
	
    return ( CGSizeMake(gridViewCellWidth, gridViewCellHeight) );
}

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
	NSLog(@"numberOfItemsInGridView");
	
	
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
	NSLog(@"heightForSection: %d width:%f",section,width);
	
	int count=[self numberOfItemsInSection:section];
	 
	int numPerRow=width / gridViewCellWidth;
	int rows=(count +1) / numPerRow;
	rows++;
	CGFloat h= rows * gridViewCellHeight;	

	NSLog(@"height=%f",h);
	
	return h;
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
	//v.alpha=0.8;
	
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
	f.origin.y=v.frame.size.height-(f.size.height+2);
	label.frame=f;
	
	[v addSubview:label];
	
	[label release];
	
	return [v autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 23;
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
	NSLog(@"cellForItemAtIndex");
	
    static NSString * cellIdentifier = @"CellIdentifier";
	
	AQGridViewCell * cell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, gridViewCellWidth, gridViewCellHeight)
											  reuseIdentifier: cellIdentifier] autorelease];
	
	cell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
	
	UIImage * image;
	NSString * itemname;
	
	switch(aGridView.tag)
	{
		case 0:
			
			if(index>=[sourcesFetcher count])
			{
				itemname=@"Add Source";
				image=[UIImage imageNamed:@"additem.png"];
			}
			else {
				itemname=[[sourcesFetcher itemAtIndex:index] name];
				image=[UIImage imageNamed:@"64-googlreader.png"];
			}
			break;
		case 1:
			if(index>=[foldersFetcher count])
			{
				itemname=@"Add Folder";
				image=[UIImage imageNamed:@"additem.png"];
			}
			else {
			itemname=[[foldersFetcher itemAtIndex:index] name];
			image=[UIImage imageNamed:@"64-folderclosed.png"];
			}
			break;
			
		case 2:
			if(index>=[newslettersFetcher count])
			{
				itemname=@"Add Newsletter";
				image=[UIImage imageNamed:@"additem.png"];
			}
			else {
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
	
	[iv release];
	[name release];

	return cell;
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	switch(gridView.tag)
	{
		case 0:
			if(index>=[sourcesFetcher count])
			{
				// add source
				[[[UIApplication sharedApplication] delegate] showAccountSettingsForm];
			}
			else 
			{
				// go to source
			}
			break;
			
		case 1:
			if(index>=[foldersFetcher count])
			{
				// add folder
				[[[UIApplication sharedApplication] delegate] addFolder];
			}
			else 
			{
				// go to folder
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
