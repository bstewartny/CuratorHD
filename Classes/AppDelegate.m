#define kNewsletterServiceURL @"http://api.qa.infongen.cc/Services/InfoNgen.NewsletterHelper.Service/"
#define kMetaDataURL @"http://ipad.infongen.com/metanames.xml"
#define kFreeUsername @"ipadfree"
#define kFreePassword @"ipadngen"
#import "FeedsViewController.h"
#import "FeedViewController.h"
#import "AppDelegate.h"
#import "AddItemsViewController.h"
#import "AccountSettingsFormViewController.h"
#import "HelpWizardViewController.h"
#import "SHK.h"
#import "SHKTwitter.h"
#import "FacebookClient.h"
#import "FolderViewController.h"
#import "NewsletterViewController.h"
#import "Newsletter.h"
#import "Folder.h"
#import "UserSettings.h"
#import "UIImage-NSCoding.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterItemContentView.h"
#import "Reachability.h"
#import "ImageRepositoryClient.h"
//#import "LoginAlertView.h"
#import "FeedAccount.h"
//#import "DetailViewController.h"
#import "FeedItemHTMLViewController.h"
#import "FeedGroup.h"
//#import "GoogleReaderAccount.h"
#import "InfoNgenAccount.h"
#import "AccountUpdater.h"
#import "GoogleAccountUpdater.h"
#import "InfoNgenAccountUpdater.h"
#import "ItemFetcher.h"
#import "RssFeed.h"
#import "FeedFetcher.h"
#import "SHK.h"
#import "FeedItemDictionary.h"
#import "FeedItem.h"
#import "NewsletterPublishAction.h"
#import "FolderPublishAction.h"
#import "NewsletterSection.h"
#import "EmailPublishAction.h"
#import "TumblrPublishAction.h"
#import "InstapaperPublishAction.h"
#import "TwitterPublishAction.h"
#import "FacebookPublishAction.h"
#import "DeliciousPublishAction.h"
#import "GoogleReaderPublishAction.h"
#import "SplitViewController.h"
#import "TouchXML.h"
#import "RootFeedsViewController.h"
#import "FormViewController.h"
#import "MGSplitViewController.h"

@interface AppDelegate (CoreDataPrivate)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;
@end

@implementation AppDelegate

@synthesize tmpFolder,tmpNewsletter,feedImageCache,navPopoverController,statusText,maxNewsletterSynopsisLength,refreshOnStart,sharingPublishActions,masterNavController,fetcher,itemIndex,fetchers,selectedItems,clearOnPublish,newsletterFormat,window,tabBarController,headlineColor,detailNavController,itemHtmlView,itemHtmlViewNoNav,newslettersScrollView;//,newsletterClient; //scroller,navigationController,homeController;


 
- (BOOL) hasInternetConnection
{
	Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
	{
		return NO;
	}
	else 
	{
		return YES;
	}
}

- (NSString*) newsletterTemplateName
{
	 
	if(newsletterFormat==nil)
	{
		newsletterFormat=@"wide";
	}
	
	if([newsletterFormat isEqualToString:@"narrow"])
	{
		return @"NewsletterDocumentTwoColumn";
	}
	else 
	{
		return @"NewsletterDocumentOneColumn";
	}
}

- (FeedItem*) currentItem
{
	if([detailNavController.topViewController isEqual:itemHtmlViewNoNav])
	{
		return [itemHtmlViewNoNav currentItem];
	}
	else 
	{
		return [itemHtmlView currentItem];
	}
}

- (NSString*) shareText
{
	if([detailNavController.topViewController isEqual:itemHtmlViewNoNav])
	{
		return [itemHtmlViewNoNav shareText];
	}
	else 
	{
		return [itemHtmlView shareText];
	}
}

/*- (UIImage*) shareImage
{
	if([detailNavController.topViewController isEqual:itemHtmlViewNoNav])
	{
		return [itemHtmlViewNoNav shareImage];
	}
	else 
	{
		return [itemHtmlView shareImage];
	}
}*/


/*- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc 
{
    barButtonItem.title = @"Sources";
	
	[[self.detailNavController topViewController].navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	
	//[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.navPopoverController = pc;
}*/
- (void)splitViewController:(MGSplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController 
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc
{
	NSLog(@"splitViewController:willHideViewController");
	barButtonItem.title = @"Sources";
	
	[[self.detailNavController topViewController].navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	
	//[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.navPopoverController = pc;
}
- (void)splitViewController:(MGSplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	NSLog(@"splitViewController:willShowViewController");
	[[self.detailNavController topViewController].navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[UIView new] autorelease]] autorelease]];
    //[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.navPopoverController = nil;
}

- (void) showFeed:(Feed*)feed delegate:(id)itemDelegate editable:(BOOL)editable
{
	NSLog(@"showFeed");
	
	FeedViewController * feedView=[[FeedViewController alloc] initWithNibName:@"FeedView" bundle:nil];
	
	if([detailNavController topViewController])
	{
		feedView.navigationItem.leftBarButtonItem=[detailNavController topViewController].navigationItem.leftBarButtonItem;
	}
	
	feedView.editable=editable; 
	feedView.itemDelegate=itemDelegate;
	feedView.title=feed.name;
	feedView.navigationItem.title=feed.name;
	
	feedView.twitter=[feed.feedCategory hasPrefix:@"_twitter"];
	
	feedView.fetcher=[feed itemFetcher];
	
	[detailNavController setViewControllers:[NSArray arrayWithObject:feedView] animated:NO];
	
	//[feedView.fetcher performFetch];
	//[feedView.tableView reloadData];
	
	[feedView release];
}

- (void) showFolder:(Feed*)feed delegate:(id)itemDelegate editable:(BOOL)editable
{
	FolderViewController * folderView=[[FolderViewController alloc] initWithNibName:@"FolderView" bundle:nil];
	
	if([detailNavController topViewController])
	{
		folderView.navigationItem.leftBarButtonItem=[detailNavController topViewController].navigationItem.leftBarButtonItem;
	}
	
	folderView.editable=editable; 
	folderView.itemDelegate=itemDelegate;
	folderView.title=feed.name;
	folderView.navigationItem.title=feed.name;
	folderView.fetcher=[feed itemFetcher];
	
	[detailNavController setViewControllers:[NSArray arrayWithObject:folderView] animated:NO];

	//[folderView.fetcher performFetch];
	//[folderView.tableView reloadData];
	
	[folderView release];
}

- (void) showNewsletter:(Feed*)feed delegate:(id)itemDelegate editable:(BOOL)editable
{
	NewsletterViewController * newsletterView=[[NewsletterViewController alloc] initWithNibName:@"NewsletterView" bundle:nil];
	
	if([detailNavController topViewController])
	{
		newsletterView.navigationItem.leftBarButtonItem=[detailNavController topViewController].navigationItem.leftBarButtonItem;
	}

	[newsletterView setViewMode:kViewModeSynopsis];
	
	newsletterView.newsletter=feed;
	newsletterView.title=feed.name;
	
	[detailNavController setViewControllers:[NSArray arrayWithObject:newsletterView] animated:NO];

	[newsletterView release];	
}

 
- (void) showItemHtml:(NSInteger)index itemFetcher:(ItemFetcher*)itemFetcher
{
	self.fetcher=itemFetcher;
	self.itemIndex=index;
	
	FeedItemHTMLViewController * itemHtml=[[FeedItemHTMLViewController alloc] initWithNibName:@"FeedItemHTMLView" bundle:nil];
	
	itemHtml.showPublishView=NO;
	
	itemHtml.modalPresentationStyle=UIModalPresentationPageSheet;
	
	itemHtml.itemIndex=index;
	itemHtml.fetcher=itemFetcher;
	
	[detailNavController presentModalViewController:itemHtml animated:YES];
	
	[itemHtml release];
}

- (UIViewController*) controllerForFetcher:(ItemFetcher*)fetcher
{
	UIViewController * controller=nil;
	
	if([fetcher isKindOfClass:[AccountItemFetcher class]])
	{
		controller=[[FeedViewController alloc] initWithNibName:@"FeedView" bundle:nil];
		controller.title=@"All Items";
		controller.navigationItem.title=@"All Items";
		[controller setEditable:NO];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	
	if([fetcher isKindOfClass:[AccountFeedFetcher class]])
	{
		controller=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
		controller.title=[fetcher accountName];
		controller.navigationItem.title=[fetcher accountName];
		[controller setEditable:NO];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	if([fetcher isKindOfClass:[NewsletterFetcher class]])
	{
		controller=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
		controller.title=@"Newsletters";
		controller.navigationItem.title=@"Newsletters";
		[controller setEditable:YES];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	if([fetcher isKindOfClass:[NewsletterSectionFetcher class]])
	{
		controller=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
		controller.title=@"Sections";
		controller.navigationItem.title=@"Sections";
		[controller setEditable:YES];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	if([fetcher isKindOfClass:[NewsletterItemFetcher class]])
	{
		controller=[[FeedViewController alloc] initWithNibName:@"FeedView" bundle:nil];
		controller.title=[[fetcher section] name];
		controller.navigationItem.title=[[fetcher section] name];
		[controller setEditable:YES];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	if([fetcher isKindOfClass:[FolderFetcher class]])
	{
		controller=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
		controller.title=@"Folders";
		controller.navigationItem.title=@"Folders";
		[controller setEditable:YES];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	if([fetcher isKindOfClass:[FolderItemFetcher class]])
	{
		controller=[[FeedViewController alloc] initWithNibName:@"FeedView" bundle:nil];
		controller.title=[[fetcher folder] name];
		controller.navigationItem.title=[[fetcher folder] name];
		[controller setEditable:YES];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	if([fetcher isKindOfClass:[FeedItemFetcher class]])
	{
		controller=[[FeedViewController alloc] initWithNibName:@"FeedView" bundle:nil];
		controller.title=[[fetcher feed] name];
		controller.navigationItem.title=[[fetcher feed] name];
		[controller setEditable:NO];
		[controller setItemDelegate:self];
		[controller setFetcher:fetcher];
		return [controller autorelease];
	}
	return nil;
}

- (void) reconfigure
{
	NSLog(@"reconfigure");
	// load app settings and make appropriate behavioral changes to running app...
	
	[self loadAccounts];
	
	self.newsletterFormat=[UserSettings getSetting:@"newsletterFormat"];
	
	if(self.newsletterFormat==nil)
	{
		self.newsletterFormat=@"wide";
	}
	
	self.clearOnPublish=[[UserSettings getSetting:@"clearOnPublish"] boolValue];
	self.refreshOnStart=[[UserSettings getSetting:@"refreshOnStart"] boolValue];
	
	self.maxNewsletterSynopsisLength=[[UserSettings getSetting:@"maxNewsletterSynopsisLength"] intValue];
}

- (void) hideSelectedView
{
	[[self selectedItems] removeAllItems];
	
	if(tmpViewController)
	{
		[masterNavController popToViewController:tmpViewController animated:YES];
		[tmpViewController release];
		tmpViewController=nil;
	}
	else 
	{
		[masterNavController popToRootViewControllerAnimated:YES];
	}
}

- (void) showSelectedView
{
	
	[[self selectedItems] removeAllItems];
	
	
	FolderFetcher * foldersFetcher=[[FolderFetcher alloc] init];
	
	NewsletterFetcher * newslettersFetcher=[[NewsletterFetcher alloc] init];
	
	AddItemsViewController * feedsView=[[AddItemsViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
	//feedsView.title=@"Add Items";
	//feedsView.navigationItem.title=@"Add Items";
		
	[feedsView setFoldersFetcher:foldersFetcher];
	[feedsView setNewslettersFetcher:newslettersFetcher];
		
	feedsView.itemDelegate=self;
	
	tmpViewController=[[masterNavController topViewController] retain];
	
	[masterNavController pushViewController:feedsView animated:YES];
										   
	[feedsView release];
	
	[foldersFetcher release];
	[newslettersFetcher release];
	
}

- (void) setUpSourcesView
{
	NSLog(@"setUpSourcesView");
	
	ArrayFetcher * sourcesFetcher=[[ArrayFetcher alloc] init];
	
	sourcesFetcher.array=[self accounts];
	
	FolderFetcher * foldersFetcher=[[FolderFetcher alloc] init];
	
	NewsletterFetcher * newslettersFetcher=[[NewsletterFetcher alloc] init];
	
	if(masterNavController!=nil)
	{
		[sourcesFetcher performFetch];
		[foldersFetcher performFetch];
		[newslettersFetcher performFetch];
		
		[rootFeedsView setSourcesFetcher:sourcesFetcher];
		[rootFeedsView setFoldersFetcher:foldersFetcher];
		[rootFeedsView setNewslettersFetcher:newslettersFetcher];
		
		[masterNavController popToViewController:rootFeedsView animated:YES];
		
		[rootFeedsView.tableView reloadData];
	}
	else 
	{
		RootFeedsViewController * feedsView=[[RootFeedsViewController alloc] initWithNibName:@"RootFeedsView" bundle:nil];
		//feedsView.title=@"Sources";
		//feedsView.navigationItem.title=@"Sources";
		
		[feedsView setSourcesFetcher:sourcesFetcher];
		[feedsView setFoldersFetcher:foldersFetcher];
		[feedsView setNewslettersFetcher:newslettersFetcher];
		
		feedsView.itemDelegate=self;
		masterNavController=[[UINavigationController alloc] initWithRootViewController:feedsView];
		
		rootFeedsView=[feedsView retain];
		
		[feedsView release];
	}
	
	[sourcesFetcher release];
	[foldersFetcher release];
	[newslettersFetcher release];
}



- (void) setUpSourcesViewOld
{
	NSLog(@"setUpSourcesView");
	NSMutableArray * array=[NSMutableArray new];
	
	ArrayFetcher * arrayFetcher=[[ArrayFetcher alloc] init];
	
	// add accounts
	
	NSArray * tmpAccounts=[self accounts];
	
	for(FeedAccount * a in tmpAccounts)
	{
		NSLog(@"Got account from db: %@",[a name]);
		if([a isDeleted])
		{
			NSLog(@"FeedAccount is deleted!");
		}
	}
	
	
	[array addObjectsFromArray:tmpAccounts];
	
	// add newsletter fetcher
	NewsletterFeedGroup * newslettersGroup=[[NewsletterFeedGroup alloc] init];
	newslettersGroup.name=@"Newsletters";
	newslettersGroup.image=[UIImage imageNamed:@"32-newsletter.png"];
	newslettersGroup.editable=YES;
	
	[array addObject:newslettersGroup];
	
	[newslettersGroup release];
	
	// add folders
	FolderFeedGroup * foldersGroup=[[FolderFeedGroup alloc] init];
	foldersGroup.name=@"Folders";
	foldersGroup.image=[UIImage imageNamed:@"32-folderclosed.png"];
	foldersGroup.editable=YES;
	
	[array addObject:foldersGroup];
	
	[foldersGroup release];
	
	arrayFetcher.array=array;
	[array release];
	
	if(masterNavController!=nil)
	{
		NSLog(@"popToRootViewControllerAnimated");
		
		[arrayFetcher performFetch];
		
		[accountFeedsView setFetcher:arrayFetcher];
		
		[masterNavController popToViewController:accountFeedsView animated:YES];
		
		[accountFeedsView.tableView reloadData];
	}
	else 
	{
		FeedsViewController * feedsView=[[FeedsViewController alloc] initWithNibName:@"FeedsView" bundle:nil];
		feedsView.title=@"Sources";
		feedsView.navigationItem.title=@"Sources";
	
		feedsView.fetcher=arrayFetcher;
		feedsView.itemDelegate=self;
		masterNavController=[[UINavigationController alloc] initWithRootViewController:feedsView];
		
		accountFeedsView=[feedsView retain];
		[feedsView release];
	}
	
	[arrayFetcher release];
}


- (void) createSampleNewsletter
{
	Newsletter * newsletter=[self createNewNewsletter:@"Curation News" sectionName:@"Curated Curation News"];
	
	newsletter.summary=@"This is a sample newsletter generated by Curator HD to illustrate newsletter creation.";
	newsletter.isFavorite=[NSNumber numberWithBool:YES];
	
	NewsletterSection * section=[[newsletter sortedSections] objectAtIndex:0];
	
	section.summary=@"A collection of news articles and blog posts about curation.";
	
	NSData * rssData=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"samplenewsletter" ofType:@"xml"]];
	
	// load XML/RSS for sample newsletter...
	NSArray * feedItems=[self loadFeedItemsFromRssData:rssData];	
	
	for(TempFeedItem * feedItem in feedItems)
	{	
		[section addFeedItem:feedItem];
	}
	
	[newsletter save];
}

- (void) createHelpObjects
{
	NSLog(@"Creating help newsletter and folder");
	
	// if no newsletters exist...
	NewsletterFetcher * newsletterFetcher=[[NewsletterFetcher alloc] init];
	
	NSArray * allNewsletters=[newsletterFetcher items];
	
	if([allNewsletters count]==0)
	{
		[self createSampleNewsletter];
	}
	[newsletterFetcher release];
	
	FolderFetcher * folderFetcher=[[FolderFetcher alloc] init];
	
	NSArray * allFolders=[folderFetcher items];
	
	if([allFolders count]==0)
	{
		Folder * folder=[self createNewFolder:@"Read Later"];
	
		folder.isFavorite=[NSNumber numberWithBool:YES];
		[folder save];
	}
	[folderFetcher release];

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];

	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	queue=[[NSOperationQueue alloc] init];
	
	markAsReadQueue=[[NSOperationQueue alloc] init];
	
	[queue setMaxConcurrentOperationCount:4];
	[markAsReadQueue setMaxConcurrentOperationCount:1];
	
	self.headlineColor=[NewsletterItemContentView colorWithHexString:@"336699"];
	
	[self reconfigure];
	
	[self loadArchivedData];
	
	if(isFirstRun)
	{
		[self createHelpObjects];
	}
	
	// create a split view
	
	splitView=[[MGSplitViewController alloc] init];
	splitView.dividerStyle=MGSplitViewDividerStyleNone;
	splitView.delegate=self;
	
	[self setUpSourcesView];

	// push previous navigation state to restore user to where they left off...
	/*if(fetchers)
	{
		for(ItemFetcher * fetcher in fetchers)
		{
			UIViewController * controller=[self controllerForFetcher:fetcher];
			
			if(controller)
			{
				[masterNavController pushViewController:controller animated:NO];
			}
		}
		
		self.fetchers=nil;
	}*/
	
	
	FeedViewController * feedView=[[FeedViewController alloc] initWithNibName:@"FeedView" bundle:nil];
	
	detailNavController=[[UINavigationController alloc] initWithRootViewController:feedView];
	
	[feedView release];
	
	splitView.viewControllers=[NSArray arrayWithObjects:masterNavController,detailNavController,nil];
	
	// add to split view
	[window addSubview:splitView.view];
	
	[window makeKeyAndVisible];
	
	[pool drain];
	
	return YES;
}

- (NSArray*) loadFeedItemsFromRssData:(NSData*)rssData
{
	NSMutableArray * items=[[NSMutableArray alloc] init];
	
	//NSString * contents= [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"help" ofType:@"xml"] 
//							  encoding: NSUTF8StringEncoding 
//								 error: nil];
	
	
	// parse xml...
	CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:rssData options:0 error:nil] autorelease];
	
	// Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
	NSArray * itemNodes = [xmlParser nodesForXPath:@"rss/channel/item" error:nil];
	
	if(itemNodes==nil || [itemNodes count]==0) return nil;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:enUS];
	[enUS release];
	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];  
	
	// Loop through the resultNodes to access each items actual data
	for (CXMLElement *itemNode in itemNodes) 
	{
		TempFeedItem * tmp=[[TempFeedItem alloc] init];
		
		@try 
		{
			tmp.headline=[itemNode elementValue:@"title"];
			
			tmp.url=[itemNode elementValue:@"link"];
			
			NSString * imageName=[itemNode elementValue:@"image"];
			
			if (imageName)
			{
				tmp.image=[UIImage imageNamed:imageName];
			}
			
			if(tmp.image==nil)
			{
				NSString * videoUrl=[itemNode elementValue:@"video"];
				
				if(videoUrl)
				{
					tmp.url=videoUrl;
				}
			}
			 
			tmp.origSynopsis=[itemNode elementValue:@"description"];
			
			tmp.origin=[itemNode elementValue:@"origin"];
			
			tmp.notes=[itemNode elementValue:@"comments"];
			
			tmp.date=[formatter dateFromString:[itemNode elementValue:@"pubDate"]];
			
			//tmp.date=[
			
			[items addObject:tmp];
		}
		@catch (NSException * e) 
		{
			NSLog(@"Error parsing item from feed: %@",[e description]);
		}
		@finally 
		{
			[tmp release];
		}
	}
	[formatter release];
	return [items autorelease];
}
 
	
- (BOOL) areAccountsValid:(NSMutableArray*)failedAccountNames
{
	NSLog(@"areAccountsValid");
	if([[self accounts] count]>0)
	{
		if([self hasInternetConnection])
		{
			// first verify accounts...
			UIApplication* app = [UIApplication sharedApplication];
			app.networkActivityIndicatorVisible = YES;
			
			BOOL failed=NO;
			//NSMutableArray * failedAccountNames=[[NSMutableArray alloc] init];
			@try 
			{
				// first update feed lists for each account...
				
				for(FeedAccount * account in [self accounts])
				{
					if(![account isValid])
					{
						[failedAccountNames addObject:account.name];
						failed=YES;
					}
				}
			}
			@catch (NSException * e) 
			{
				NSLog(@"Error validating accounts: %@",[e description]);
			}		
			@finally 
			{
				app.networkActivityIndicatorVisible=NO;
			
			}
			
			if(failed)
			{
				return NO;
			}
		}
	}
	return YES;
}

- (void) validateAccounts
{
	NSLog(@"validateAccounts");
	
	NSMutableArray * failedAccountNames=[[NSMutableArray alloc] init];
	
	if(![self areAccountsValid:failedAccountNames])
	{
		if([failedAccountNames count]>0)
		{
			if([failedAccountNames count]==1)
			{
				UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Invalid Account Settings" message:[NSString stringWithFormat:@"Failed to authenticate %@ account. Please verify username and password in app settings.",[failedAccountNames objectAtIndex:0]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				alertView.delegate=self;
				alertView.tag=kInvalidAccountSettingsAlertViewTag;
				[alertView show];
				[alertView release];
			}
			else 
			{
				UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Invalid Account Settings" message:@"Failed to authenticate your accounts. Please verify accounts in app settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				alertView.delegate=self;
				alertView.tag=kInvalidAccountSettingsAlertViewTag;
				[alertView show];
				[alertView release];
			}
			
			//[self showAccountSettingsForm];
			
		}
	}
	[failedAccountNames release];
}

- (void) accountSettingsDidCancel:(AccountSettingsFormViewController*)accountSettingsForm
{
	[accountSettingsForm dismissModalViewControllerAnimated:YES];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateComplete"
	 object:nil];
}

- (void) accountSettingsDone:(AccountSettingsFormViewController*)accountSettingsForm
{
	[accountSettingsForm dismissModalViewControllerAnimated:YES];

	NSLog(@"accountSettingsDone");
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateComplete"
	 object:nil];
	
	// reconfigure app
	[self reconfigure];
	
	NSMutableArray * failedAccountNames=[[NSMutableArray alloc] init];
	
	/*if(![self areAccountsValid:failedAccountNames])
	{
		if([failedAccountNames count]>0)
		{
			if([failedAccountNames count]==1)
			{
				UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Invalid Account Settings" message:[NSString stringWithFormat:@"Failed to authenticate %@ account. Please verify username and password.",[failedAccountNames objectAtIndex:0]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				alertView.delegate=self;
				alertView.tag=kInvalidAccountSettingsAlertViewTag;
				[alertView show];
				[alertView release];
			}
			else 
			{
				UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"Invalid Account Settings" message:@"Failed to authenticate your accounts. Please verify account settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				alertView.delegate=self;
				alertView.tag=kInvalidAccountSettingsAlertViewTag;
				[alertView show];
				[alertView release];
			}
			//[self showAccountSettingsForm];
		}
	}
	else 
	{*/
		[self setUpSourcesView];
		
		if([self hasInternetConnection])
		{
			if([[self accounts] count]>0)
			{
				[self update];
			}
		}
	//}
	[failedAccountNames release];
}

- (void) finishStartup
{
	NSLog(@"Verify connection and load feeds...");
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	@try 
	{
		// flush any sharing requests made while app was offline...
		[SHK flushOfflineQueue];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Failed to flush offline queue with ShareKit: %@",[e userInfo]);
	}
	@finally 
	{
		
	}
	
	if([[self accounts]count]==0)
	{
		[self showAccountSettingsForm];
		/*
		AccountSettingsFormViewController * accountSettingsForm=[[AccountSettingsFormViewController alloc] initWithNibName:@"AccountSettingsFormView" bundle:nil];
		
		accountSettingsForm.modalPresentationStyle=UIModalPresentationFormSheet;
		
		[detailNavController presentModalViewController:accountSettingsForm animated:YES];
	
		[accountSettingsForm release];
		*/
		/*UIAlertView * noAccountsAlertView=[[UIAlertView alloc] initWithTitle:@"No account settings" message:@"Please setup your account info in app settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[noAccountsAlertView show];
		
		[noAccountsAlertView release];*/
	}
	else 
	{
		/*if(self.refreshOnStart)
		{
			//[self validateAccounts];
			if([self hasInternetConnection])
			{
				[self update];
			}
		}*/
	}
	
	[pool drain];
}
- (void)showAccountSettingsForm
{
	AccountSettingsFormViewController * accountSettingsForm=[[AccountSettingsFormViewController alloc] initWithNibName:@"AccountSettingsFormView" bundle:nil];
	
	accountSettingsForm.delegate=self;
	accountSettingsForm.modalPresentationStyle=UIModalPresentationFormSheet;
	
	[detailNavController presentModalViewController:accountSettingsForm animated:YES];
	
	[accountSettingsForm release];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (NSString *)dataFilePath
{
	NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"archive"];
}

- (BOOL) isUpdating
{
	return updating;
}

- (void) update
{
	NSLog(@"AppDelegate.update");
	/*
	FacebookClient * fb=[[[FacebookClient alloc] init] autorelease];
	
	if([fb isAuthorized])
	{
		NSArray * wall=[fb getWall];
	}
	*/
	 
	
	if(!updating)
	{
		if([[self accounts]count]==0)
		{
			[self showAccountSettingsForm];
			return;
		}
		
		if([self hasInternetConnection])
		{
			updating=YES;
			
			BOOL needAuthorization=NO;
			
			// enumerate accounts on main thread for accounts which require user input on validation (such as OAuth accounts)
			for(FeedAccount * account in [self accounts])
			{
				if(![account isValid])
				{
					needAuthorization=YES;
					break;
				}
			}
			
			if(!needAuthorization)
			{
				// send notification that update is starting
				[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"UpdateStarting"
				object:nil];
		
				[self performSelectorInBackground:@selector(update_start) withObject:nil];
			}
			else 
			{
				updating=NO;
				[self update_end];
				for(FeedAccount * account in [self accounts])
				{
					if(![account isValid])
					{
						[account authorize];
						return;
					}
				}
			}
		}
		else 
		{
			[self update_end];
			UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You must have an internet connection to update sources." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
			
			[alertView show];
			
			[alertView release];
		}
	}
}
- (void) updateSingleAccountFromScroll:(NSString*)accountName
{
	if(!updating)
	{
		if([self hasInternetConnection])
		{
			updating=YES;
			// send notification that update is starting
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"UpdateStarting"
			 object:nil];
			
			FeedAccount * account=[self fetchAccount:accountName];
			
			if(account==nil)
			{
				NSLog(@"Not such account found: %@",accountName);
			}
			else
			{
				if(![account isValid])
				{
					NSLog(@"Account %@ is not valid, calling authorize...",[account name]);
					[account authorize];
				}
				else 
				{
					[self performSelectorInBackground:@selector(update_start_account:) withObject:accountName];
				}
			}
		}
		else {
			[self update_end];
		}

	}
}

- (void) updateSingleAccount:(NSString*)accountName
{
	NSLog(@"AppDelegate.updateSingleAccount: %@",accountName);
	if(!updating)
	{
		if([self hasInternetConnection])
		{
			updating=YES;
			// send notification that update is starting
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"UpdateStarting"
			 object:nil];
			
			FeedAccount * account=[self fetchAccount:accountName];
			
			if(account==nil)
			{
				NSLog(@"Not such account found: %@",accountName);
			}
			else
			{
				if(![account isValid])
				{
					[self update_end];
					NSLog(@"Account %@ is not valid, calling authorize...",[account name]);
					[account authorize];
				}
				else 
				{
					[self performSelectorInBackground:@selector(update_start_account:) withObject:accountName];
				}
			}
		}
		else 
		{
			[self update_end];
			UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You must have an internet connection to update feeds." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
			
			[alertView show];
			
			[alertView release];
		}
	}
}


- (void) updateSingleFromScroll:(RssFeed*)feed
{
	if(!updating)
	{
		if([self hasInternetConnection])
		{
			updating=YES;
			// send notification that update is starting
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"UpdateStarting"
			 object:nil];
			
			[self performSelectorInBackground:@selector(update_start_single:) withObject:feed];
		}
		else	
		{
			[self update_end];
		}
	}
}

- (void) backFillSingleFromScroll:(RssFeed*)feed
{
	if(!updating)
	{
		if([self hasInternetConnection])
		{
			updating=YES;
			// send notification that update is starting
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"UpdateStarting"
			 object:nil];
			
			[self performSelectorInBackground:@selector(backfill_start_single:) withObject:feed];
		}
	}
}

- (void) updateSingle:(RssFeed*)feed
{
	if(!updating)
	{
		if([self hasInternetConnection])
		{
			updating=YES;
			// send notification that update is starting
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"UpdateStarting"
			 object:nil];
			
			[self performSelectorInBackground:@selector(update_start_single:) withObject:feed];
		}
		else 
		{
			[self update_end];
			
			UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You must have an internet connection to update feeds." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
			
			[alertView show];
			
			[alertView release];
		}
	}
}

 
- (void) update_start_single:(RssFeed*)feed
{
	//NSLog(@"AppDelegate.update_start_single");
	updating=YES;
	@try 
	{
		[self updateSingleFeed:feed];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating accounts: %@",[e description]);
	}
	@finally 
	{
		
	}
	updating=NO;
	[self performSelectorOnMainThread:@selector(update_end) withObject:nil waitUntilDone:YES];
}

- (void) backfill_start_single:(RssFeed*)feed
{
	//NSLog(@"AppDelegate.update_start_single");
	updating=YES;
	@try 
	{
		[self backFillSingleFeed:feed];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating accounts: %@",[e description]);
	}
	@finally 
	{
		
	}
	updating=NO;
	[self performSelectorOnMainThread:@selector(update_end) withObject:nil waitUntilDone:YES];
}

 - (void) updateSingleFeed:(RssFeed*)feed
{
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	@try 
	{
		// first update feed lists for each account...
		
		AccountUpdater * updater=[feed.account accountUpdater];
		
		updater.iterations=[NSArray arrayWithObjects:[NSNumber numberWithInt:100],nil];
		 
		if([updater isAccountValid])
		{
			// notify updating feed list for account
			[[NSNotificationCenter defaultCenter] 
				 postNotificationName:@"UpdateStatus"
				 object:[NSString stringWithFormat:@"Updating \"%@\"...",feed.name]];
				
			NSInvocationOperation * op=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateFeed:) object:[NSArray arrayWithObjects:updater,[feed objectID],nil]];
						
			[queue addOperation:op];
						
			[op release];
					 				
			[queue waitUntilAllOperationsAreFinished];
		
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating feed: %@",[e description]);
	}
	@finally 
	{
		[pool drain];
		app.networkActivityIndicatorVisible=NO;
	}
}


- (void) backFillSingleFeed:(RssFeed*)feed
{
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	@try 
	{
		// first update feed lists for each account...
		
		AccountUpdater * updater=[feed.account accountUpdater];
		
		updater.iterations=[NSArray arrayWithObjects:[NSNumber numberWithInt:100],nil];
		
		if([updater isAccountValid])
		{
			// notify updating feed list for account
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"UpdateStatus"
			 object:[NSString stringWithFormat:@"Updating \"%@\"...",feed.name]];
			
			NSInvocationOperation * op=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(backFillFeed:) object:[NSArray arrayWithObjects:updater,[feed objectID],nil]];
			
			[queue addOperation:op];
			
			[op release];
			
			[queue waitUntilAllOperationsAreFinished];
			
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating feed: %@",[e description]);
	}
	@finally 
	{
		[pool drain];
		app.networkActivityIndicatorVisible=NO;
	}
}


- (void) update_start_account:(NSString*)accountName
{
	NSLog(@"AppDelegate.update_start_account: %@",accountName);
	updating=YES;
	@try 
	{
		[self updateSingleAccountImpl:accountName];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating accounts: %@",[e description]);
	}
	@finally 
	{
		
	}
	updating=NO;
	[self performSelectorOnMainThread:@selector(update_end) withObject:nil waitUntilDone:YES];
}


- (void) update_start
{
	NSLog(@"AppDelegate.update_start");
	updating=YES;
	@try 
	{
		[self updateAccounts];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating accounts: %@",[e description]);
	}
	@finally 
	{
		
	}
	updating=NO;
	[self performSelectorOnMainThread:@selector(update_end) withObject:nil waitUntilDone:YES];
}

- (void) update_end
{
	NSLog(@"AppDelegate.update_end");
	updating=NO;
	// send notification that update is finished
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStatus"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateComplete"
	 object:nil];
}

- (void) cancelUpdate
{
	NSLog(@"AppDelegate.cancelUpdate");
	/*
	// stop updating...
	updating=NO;
	
	[queue cancelAllOperations];*/
}


- (void) updateSingleAccountImpl:(NSString*)accountName
{
	NSLog(@"AppDelegate.updateSingleAccountImpl: %@",accountName);
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	@try 
	{
		// first update feed lists for each account...
		BOOL accountFound=NO;
		for(FeedAccount * account in [self accounts])
		{
			if([[account name] isEqualToString:accountName])
			{
				if(updating==NO) break;
			
				accountFound=YES;
				[self updateAccount:account updateFeeds:YES];
			}
		}
		
		if(!accountFound)
		{
			NSLog(@"No account found with name: %@",accountName);
		}
		else 
		{
			if(updating==YES)
			{
				[queue waitUntilAllOperationsAreFinished];
			}
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating accounts: %@",[e description]);
	}
	@finally 
	{
		[pool drain];
		app.networkActivityIndicatorVisible=NO;
	}	
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"AccountUpdated"
	 object:accountName];
}

- (void) updateAccount:(FeedAccount*)account updateFeeds:(BOOL)updateFeeds
{
	NSLog(@"updateAccount: %@",[account name]);
	
	AccountUpdater * updater=[account accountUpdater];
	
	if([updater isAccountValid])
	{
		NSManagedObjectContext * moc=[self createNewManagedObjectContext:NSMergeByPropertyObjectTrumpMergePolicy];
		
		NSLog(@"AppDelegate.updateAccounts: %@",account.name);
	
		if(updating==YES)
		{
			// notify updating feed list for account
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"UpdateStatus"
				object:[NSString stringWithFormat:@"Updating \"%@\"...",account.name]];
		
			if([updater updateFeedListWithContext:moc])
			{
				[[NSNotificationCenter defaultCenter] 
				 postNotificationName:@"FeedsUpdated"
				 object:account.name];
			}
			
			if(updating==YES)
			{
				if(updateFeeds)
				{
					[updater willUpdateFeeds:moc];
					
					AccountUpdatableFeedFetcher * feedFetcher=[[AccountUpdatableFeedFetcher alloc] init];
					
					feedFetcher.accountName=account.name;
					feedFetcher.managedObjectContext=moc;
					
					[feedFetcher performFetch];
					
					int count=[feedFetcher count];
					
					for(int i=0;i<count;i++)
					{
						if(updating==NO) break;
						
						RssFeed * feed=[feedFetcher itemAtIndex:i];
						
						NSInvocationOperation * op=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateFeed:) object:[NSArray arrayWithObjects:updater,[feed objectID],nil]];
						
						[queue addOperation:op];
						
						[op release];
					}
					
					[feedFetcher release];
				}
			}
		}
		[moc reset];
		[moc release];
	}
}

- (void) updateAccounts
{
	NSLog(@"AppDelegate.updateAccounts");
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
		
	@try 
	{
		// first update feed lists for each account...
			
		for(FeedAccount * account in [self accounts])
		{
			if(updating==NO) break;
			
			[self updateAccount:account updateFeeds:NO];
		}
		
		if(updating==YES)
		{
			[queue waitUntilAllOperationsAreFinished];
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating accounts: %@",[e description]);
	}
	@finally 
	{
		[pool drain];
		app.networkActivityIndicatorVisible=NO;
	}
}

- (void) markAsRead:(FeedItem*)item
{
	NSLog(@"AppDelegate.markAsRead");
	// push item onto queue for marking items as read on remote server(s)...
	NSInvocationOperation * op=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doMarkAsRead:) object:item];
	
	[markAsReadQueue addOperation:op];
	
	[op release];
}

- (FeedAccount*) accountByName:(NSString*) name
{
	return [self fetchAccount:name];
}


- (NSArray*) newsletterPublishActions
{
	NSMutableArray * tmp=[[NSMutableArray alloc] init];
	
	NewsletterFetcher * newsletterFetcher=[NewsletterFetcher new];
	
	for(Newsletter * newsletter in newsletterFetcher.items)
	{
		NewsletterPublishAction * publishAction=[[NewsletterPublishAction alloc] init];
		publishAction.newsletter=newsletter;
		[tmp addObject:publishAction];
		[publishAction release];
	}
	
	[newsletterFetcher release];
	
	return [tmp autorelease];
}

- (NSArray*) folderPublishActions
{
	NSMutableArray * tmp=[[NSMutableArray alloc] init];
	
	FolderFetcher * folderFetcher=[FolderFetcher new];
	
	for(Folder  * folder in folderFetcher.items)
	{
		FolderPublishAction * publishAction=[[FolderPublishAction alloc] init];
		publishAction.folder=folder;
		[tmp addObject:publishAction];
		[publishAction release];
	}
	
	[folderFetcher release];
	return [tmp autorelease];
}

- (NSArray*) sharingPublishActions
{
	if(sharingPublishActions==nil)
	{
		NSMutableArray * tmp=[[NSMutableArray alloc] init];
			
		TwitterPublishAction * twitterAction=[[TwitterPublishAction alloc] init];
		twitterAction.isFavorite=YES;
		[tmp addObject:twitterAction];
		[twitterAction release];
		
		FacebookPublishAction * facebookAction=[[FacebookPublishAction alloc] init];
		facebookAction.isFavorite=YES;
		[tmp addObject:facebookAction];
		[facebookAction release];
						
		TumblrPublishAction * tumblrAction=[[TumblrPublishAction alloc] init];
		[tmp addObject:tumblrAction];
		[tumblrAction release];
		
		GoogleReaderPublishAction * googleReaderAction=[[GoogleReaderPublishAction alloc] init];
		[tmp addObject:googleReaderAction];
		[googleReaderAction release];

		DeliciousPublishAction * deliciousAction=[[DeliciousPublishAction alloc] init];
		[tmp addObject:deliciousAction];
		[deliciousAction release];
		
		InstapaperPublishAction * instapaperAction=[[InstapaperPublishAction alloc] init];
		instapaperAction.isFavorite=YES;
		[tmp addObject:instapaperAction];
		[instapaperAction release];
		
		EmailPublishAction * emailPublishAction=[[EmailPublishAction alloc] init];
		emailPublishAction.isFavorite=YES;
		[tmp addObject:emailPublishAction];
		[emailPublishAction release];
		
		sharingPublishActions=[tmp retain];
		
		[tmp release];
	}
	return sharingPublishActions;
}

- (NSArray*) favoritePublishActions
{
	NSMutableArray * tmp=[[NSMutableArray alloc] init];
	// get favorite newsletters
	for(PublishAction * action in [self newsletterPublishActions])
	{
		if(action.isFavorite)
		{
			[tmp addObject:action];
		}
	}
	// get favorite folders
	for(PublishAction * action in [self folderPublishActions])
	{
		if(action.isFavorite)
		{
			[tmp addObject:action];
		}
	}
	// get favorite sharing icons
	for(PublishAction * action in [self sharingPublishActions])
	{
		if(action.isFavorite)
		{
			[tmp addObject:action];
		}
	}

	return [tmp autorelease];
}


-(void) doMarkAsRead:(FeedItem*)item
{
	NSLog(@"AppDelegate.doMarkAsRead");
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	@try 
	{
		if([item respondsToSelector:@selector(feed)])
		{
			NSString * accountName=[[[item feed] account] name];
			
			if([accountName isEqualToString:@"Google Reader"])
			{
				FeedAccount * account=[[item feed] account];
				
				GoogleReaderClient * google=[[GoogleReaderClient alloc] initWithUsername:account.username password:account.password];
				
				[google markAsRead:item];
				
				[google release];
			}
			else 
			{
				//NSLog(@"Failed to find account by name: %@",[[[item feed] account] name]);
			}
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Failed to mark item as read: %@",[e userInfo]);
	}
	@finally 
	{
		[pool drain];
	}
}

- (void) updateFeed:(NSArray*)args
{
	if(updating==NO) return;
	
	NSManagedObjectContext * moc=[self createNewManagedObjectContext:NSMergeByPropertyObjectTrumpMergePolicy];
	
	RssFeed * feed=[moc objectWithID:[args objectAtIndex:1]];
	
	AccountUpdater * updater=[args objectAtIndex:0];
	
	[self updateFeedWithFeed:feed updater:updater];
	
	[moc reset];
	[moc release];
}


- (void) updateFeedWithFeed:(RssFeed*)feed updater:(AccountUpdater*)updater
{
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	BOOL wasUpdated=NO;
	@try 
	{
		[updater updateFeed:feed withContext:[feed managedObjectContext]];
		if([updater updateFeed:feed withContext:[feed managedObjectContext]])
		{
			wasUpdated=YES;
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"FeedUpdated"
			 object:[NSArray arrayWithObjects:updater.account.name,feed.url,nil]];
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating feed: %@",[e userInfo]);
 	}
	@finally 
	{
		[pool drain];
	}
	if(!wasUpdated)
	{
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"FeedUpdateFinished"
		 object:[NSArray arrayWithObjects:updater.account.name,feed.url,nil]];
	}
}

- (void) backFillFeed:(NSArray*)args
{
	if(updating==NO) return;
	
	NSManagedObjectContext * moc=[self createNewManagedObjectContext:NSMergeByPropertyObjectTrumpMergePolicy];
	
	RssFeed * feed=[moc objectWithID:[args objectAtIndex:1]];
	
	AccountUpdater * updater=[args objectAtIndex:0];
	
	[self backFillFeedWithFeed:feed updater:updater];
	
	[moc reset];
	[moc release];
}


- (void) backFillFeedWithFeed:(RssFeed*)feed updater:(AccountUpdater*)updater
{
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	@try 
	{
		[updater backFillFeed:feed withContext:[feed managedObjectContext]];
		
		//if([updater backFillFeed:feed withContext:[feed managedObjectContext]])
		//{
		///	[[NSNotificationCenter defaultCenter] 
		//	 postNotificationName:@"FeedUpdated"
		//	 object:[NSArray arrayWithObjects:updater.account.name,feed.url,nil]];
		//}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error updating feed: %@",[e userInfo]);
 	}
	@finally 
	{
		[pool drain];
	}
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"FeedUpdated"
	 object:[NSArray arrayWithObjects:updater.account.name,feed.url,nil]];
}


- (void) loadAccounts
{
	NSLog(@"loadAccounts");
	
	// get accounts from db
	FeedAccount * account;
	
	[self fetchOrCreateAccount:@"Google Reader" prefix:@"googlereader" image:[UIImage imageNamed:@"32-googlreader.png"]];
	
	[self fetchOrCreateAccount:@"InfoNgen" prefix:@"infongen" image:[UIImage imageNamed:@"32-infongen.png"]];
		
	[self fetchOrCreateAccount:@"Twitter" prefix:@"twitter" image:[UIImage imageNamed:@"32-twitter.png"]];
	
	// verify twitter has saved userId/screenName, otherwise logout from twitter
	// we need this in case user has previously saved twitter account in keychain
	NSString * twitterUserId=[UserSettings getSetting:@"twitter.userId"];
	
	if([twitterUserId length]==0)
	{
		NSLog(@"Did not find saved twitter userId, logging out of twitter service...");
		[UserSettings saveSetting:@"twitter.userId" value:nil];
		[UserSettings saveSetting:@"twitter.screenName" value:nil];
		
		// logout
		[SHK logoutOfService:[SHKTwitter sharerId]];
		[SHK logoutOfService:@"TwitterClient"];
	}
}

- (void) addAccount:(NSString*)name prefix:(NSString*)prefix image:(UIImage*)image username:(NSString*)username password:(NSString*)password
{
	NSLog(@"addAccount: %@",name);
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	// add to database if not already exists
	FeedAccount * account=[self fetchAccount:name];
	if(account)
	{
		NSLog(@"Found existing account, updating credentials...");
		account.username=username;
		account.password=password;
		account.image=image;
	}
	else 
	{
		NSLog(@"Creating new account...");
		account= [NSEntityDescription insertNewObjectForEntityForName:@"FeedAccount" inManagedObjectContext:moc];
		account.name=name;
		account.image=image;
		account.username=username;
		account.password=password;
	}
	
	NSError * error=nil;
	[moc save:&error];
	if(error)
	{
		NSLog(@"Error saving account info: %@",[error localizedDescription]);
	}
}

- (void) deleteAccount:(NSString*)name
{
	NSLog(@"deleteAccount: %@",name);
	// delete from database if exists
	FeedAccount * account=[self fetchAccount:name];
	if(account)
	{
		NSManagedObjectContext * moc=[account managedObjectContext];
	
		if(![moc isEqual:[self managedObjectContext]])
		{
			NSLog(@"!!!! moc is NOT equal!!!!");
		}
		
		NSLog(@"deleting account object from database...");
		
		[moc deleteObject:account];
		
		if ([account isDeleted]) 
		{
			NSLog(@"account state is deleted");
		}
	
		NSError * error=nil;
		if(![[self managedObjectContext] save:&error])
		{
			NSLog(@"Failed to save moc!!!!");
			if(error)
			{
				NSLog(@"Error saving account info: %@",[error localizedDescription]);
			}
		}
		
		//[moc processPendingChanges];
		
		FeedAccount * tmpAccount=[self fetchAccount:name];
		
		if(tmpAccount)
		{
			NSLog(@"still got object...!!!!????");
			if([tmpAccount isDeleted])
			{
				NSLog(@"object state is deleted");
			}
		}
	}
}

- (NSArray*) accounts
{
	// read accounts from database...
	
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:@"FeedAccount" inManagedObjectContext:moc];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
	[request setEntity:entity];
	[request setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" 
																					 ascending:YES] autorelease]]];
	
	return [NSMutableArray arrayWithArray:[[self managedObjectContext] executeFetchRequest:request error:nil]];
}



- (void) formViewDidCancel:(NSInteger)tag
{
	
}

- (void) formViewDidFinish:(NSInteger)tag withValues:(NSArray*)values
{
	NSLog(@"formViewDidFinish tag: %d",tag);
	if(tag==kAddFolderAlertViewTag)
	{
		NSString * folderName=[values objectAtIndex:0];
		
		if([folderName length]>0)
		{
			NSLog(@"create folder with name: %@",folderName);
			[self createNewFolder:folderName];
			
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadData"
			 object:nil];
			
			/*[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadActionData"
			 object:nil];*/
		}
		return;
	}
	if(tag==kEditFolderNameAlertViewTag)
	{
		NSString * folderName=[values objectAtIndex:0];
		
		if([folderName length]>0)
		{
			tmpFolder.name=folderName;
			[tmpFolder save];
			
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadData"
			 object:nil];
			
			/*[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadActionData"
			 object:nil];*/
		}
		self.tmpFolder=nil;
		return;
	}
	if(tag==kEditNewsletterNameAlertViewTag)
	{
		NSString * newsletterName=[values objectAtIndex:0];
		
		if([newsletterName length]>0)
		{
			tmpNewsletter.name=newsletterName;
			[tmpNewsletter save];
			
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadData"
			 object:nil];
			
			/*[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadActionData"
			 object:nil];*/
		}
		self.tmpNewsletter=nil;
		return;
	}
	if(tag==kAddNewsletterAlertViewTag)
	{
		NSString * newsletterName=[values objectAtIndex:0];
		NSString * sectionName=[values objectAtIndex:1];
		
		if ([newsletterName length]>0) 
		{
			[self createNewNewsletter:newsletterName sectionName:sectionName];
			
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadData"
			 object:nil];
			/*[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadActionData"
			 object:nil];*/
		}
	}
}
- (void) editFolderName:(Folder*)folder
{
	self.tmpFolder=folder;
	
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Rename folder" tag:kEditFolderNameAlertViewTag delegate:self names:[NSArray arrayWithObject:@"Folder name"] andValues:[NSArray arrayWithObject:folder.name]];
	[detailNavController presentModalViewController:formView animated:YES];
	
	[formView release];
}
- (void) editNewsletterName:(Newsletter*)newsletter
{
	self.tmpNewsletter=newsletter;
	
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Rename newsletter" tag:kEditNewsletterNameAlertViewTag delegate:self names:[NSArray arrayWithObject:@"Newsletter name"] andValues:[NSArray arrayWithObject:newsletter.name]];
	[detailNavController presentModalViewController:formView animated:YES];
	
	[formView release];
}
- (void) addFolder
{
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Add folder" tag:kAddFolderAlertViewTag delegate:self names:[NSArray arrayWithObject:@"Folder name"] andValues:nil];
	[detailNavController presentModalViewController:formView animated:YES];
	
	[formView release];
	
	
	
	/*
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Create New Folder" 
													 message:@"\n\n" // IMPORTANT
													delegate:self 
										   cancelButtonTitle:@"Cancel" 
										   otherButtonTitles:@"Ok", nil];
	
	prompt.tag=kAddFolderAlertViewTag;
	
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 50.0, 250.0, 25.0)]; 
	[textField setBackgroundColor:[UIColor whiteColor]];
	[textField setPlaceholder:@"Enter folder name"];
	textField.tag=kAddFolderAlertViewNameTag;
	[prompt addSubview:textField];
	
	// set place
	[prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
	[prompt show];
    [prompt release];
	
	[textField release];*/
}

- (void) addNewsletter
{
	
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Add newsletter" tag:kAddNewsletterAlertViewTag delegate:self names:[NSArray arrayWithObjects:@"Newsletter name",@"Section name",nil] andValues:nil];
	[detailNavController presentModalViewController:formView animated:YES];
	
	[formView release];
	
	/*
	// prompt for name
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Create New Newsletter" 
													 message:@"\n\n\n" // IMPORTANT
													delegate:self 
										   cancelButtonTitle:@"Cancel" 
										   otherButtonTitles:@"Ok", nil];
	
	prompt.tag=kAddNewsletterAlertViewTag;
	
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 50.0, 250.0, 25.0)]; 
	[textField setBackgroundColor:[UIColor whiteColor]];
	[textField setPlaceholder:@"Enter newsletter name"];
	textField.tag=kAddNewsletterAlertViewNameTag;
	[prompt addSubview:textField];
	
	[textField release];
	
	textField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 82.0, 250.0, 25.0)]; 
	[textField setBackgroundColor:[UIColor whiteColor]];
	[textField setPlaceholder:@"Enter section name"];
	textField.tag=kAddNewsletterAlertViewSectionNameTag;
	[prompt addSubview:textField];
	
	// set place
	[prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
	[prompt show];
    [prompt release];
	
	[textField release];*/
}
- (void) addNewsletterSection:(Newsletter*)newsletter
{
	currentNewsletter=newsletter;
	
	// prompt for name
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Add New Section" 
													 message:@"\n\n\n" // IMPORTANT
													delegate:self 
										   cancelButtonTitle:@"Cancel" 
										   otherButtonTitles:@"Ok", nil];
	
	prompt.tag=kAddNewsletterSectionAlertViewTag;
	
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 50.0, 250.0, 25.0)]; 
	[textField setBackgroundColor:[UIColor whiteColor]];
	[textField setPlaceholder:@"Enter section name"];
	textField.tag=kAddNewsletterSectionAlertViewNameTag;
	[prompt addSubview:textField];
	
	[textField release];
	
	// set place
	[prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
	[prompt show];
    [prompt release];
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if(actionSheet.tag==kInvalidAccountSettingsAlertViewTag)
	{
		[self showAccountSettingsForm];
		return;
	}
	
	if(actionSheet.tag==kAddNewsletterAlertViewTag)
	{
		if(buttonIndex==1) 
		{
			UITextField * nameField=[actionSheet viewWithTag:kAddNewsletterAlertViewNameTag];
			UITextField * sectionField=[actionSheet viewWithTag:kAddNewsletterAlertViewSectionNameTag];
			
			[nameField resignFirstResponder];
			[sectionField resignFirstResponder];
			
			if(nameField && sectionField)
			{
				if (nameField.text != nil && [nameField.text length]>0) 
				{
					[self createNewNewsletter:nameField.text sectionName:sectionField.text];
					
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"ReloadData"
					 object:nil];
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"ReloadActionData"
					 object:nil];
				}
			}
		}
	}
	else 
	{
		if(actionSheet.tag==kAddFolderAlertViewTag)
		{
			if(buttonIndex==1) 
			{
				UITextField * nameField=[actionSheet viewWithTag:kAddFolderAlertViewNameTag];
				
				[nameField resignFirstResponder];
					
				if (nameField.text != nil && [nameField.text length]>0) 
				{
					[self createNewFolder:nameField.text];
						
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"ReloadData"
					 object:nil];
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"ReloadActionData"
					 object:nil];
				}
			}
		}
		else 
		{
			if(actionSheet.tag==kAddNewsletterSectionAlertViewTag)
			{
				UITextField * textField=[actionSheet viewWithTag:kAddNewsletterSectionAlertViewNameTag];
				
				if(textField.text && [textField.text length]>0)
				{
					Newsletter * newsletter=currentNewsletter;
					
					NewsletterSection * newSection=[newsletter addSection];
					
					newSection.name=textField.text;
					
					[newSection save];
					
					FeedItemDictionary * tmpSelectedItems=[self selectedItems];
					
					if([tmpSelectedItems.items count]>0)
					{
						for(FeedItem * item in tmpSelectedItems.items)
						{
							[newSection addFeedItem:item];
							[newSection save];
						}
						[tmpSelectedItems removeAllItems];
					}
					else 
					{
						FeedItem * item=[self currentItem];
						if(item!=nil)
						{
							[newSection addFeedItem:item];
							[newSection save];
						}
					}
					[newsletter save];
					
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"ReloadData"
					 object:nil];
					[[NSNotificationCenter defaultCenter] 
					 postNotificationName:@"ReloadActionData"
					 object:nil];
				}
			}
		}
	}
}

- (Newsletter *) createNewNewsletter:(NSString*)name sectionName:(NSString*)sectionName
{
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	/*NewsletterFetcher * newsletterFetcher=[[NewsletterFetcher alloc] init];
	int numNewsletters=[newsletterFetcher.items count];
	[newsletterFetcher release];
	*/
	
	Newsletter * newNewsletter=[Newsletter createInContext:moc];
	
	int numNewsletters=[newNewsletter entityCount:@"Newsletter" predicate:nil];

	//newNewsletter.maxSynopsisLength=self.maxNewsletterSynopsisLength;
	newNewsletter.name=name;
	newNewsletter.logoImage=[UIImage imageNamed:@"32-newsletter.png"];
	newNewsletter.displayOrder=[NSNumber numberWithInt:numNewsletters];
	
	NewsletterSection * section=[newNewsletter addSection];
	
	if(sectionName && [sectionName length]>0)
	{
		section.name=sectionName;
	}
	else 
	{
		section.name=@"Latest News";
	}
	
	// use default logo...
	UIImage * logo=[UIImage imageNamed:@"logo-infongen2.png"];
	
	if(logo)
	{
		newNewsletter.logoImage=logo;
	}
	
	[newNewsletter save];
	
	return newNewsletter;
}

- (Folder * ) createNewFolder:(NSString*)name
{
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	Folder * newFolder=[Folder createInContext:moc];
	
	int numFolders=[newFolder entityCount:@"Folder" predicate:nil];

	newFolder.name=name;
	newFolder.image=[UIImage imageNamed:@"32-folderclosed.png"];
	newFolder.displayOrder=[NSNumber numberWithInt:numFolders];
	
	[newFolder save];
	
	return newFolder;
}

- (FeedAccount*)fetchOrCreateAccount:(NSString*)accountName prefix:(NSString*)accountSettingsPrefix image:(UIImage*)image
{
	//NSLog(@"fetchOrCreateAccount: %@",accountName);
	
	// do we have this account in app settings?
	NSString * username=[UserSettings getSetting:[NSString stringWithFormat:@"%@.username",accountSettingsPrefix]];
	NSString * password=[UserSettings getSetting:[NSString stringWithFormat:@"%@.password",accountSettingsPrefix]];
	
	FeedAccount * account=[self fetchAccount:accountName];
	
	if(account==nil)
	{
		// only create if we have a username
		if([username length]>0)
		{
			// create new account
			[self addAccount:accountName prefix:accountSettingsPrefix image:image username:username password:password];
		}
	}
	else 
	{
		if([username length]>0)
		{
			// update settings
			[self addAccount:accountName prefix:accountSettingsPrefix image:image username:username password:password];
		}
		else 
		{
			// delete account
		
			[self deleteAccount:accountName];
		}
	}

	/*
	
	FeedAccount * account=nil;
	
	BOOL accountExists=NO;
	for(FeedAccount * tmp in accounts)
	{
		if([tmp.name isEqualToString:accountName])
		{
			account=tmp;
			accountExists=YES;
			break;
		}
	}
	
	NSManagedObjectContext * moc=[self managedObjectContext];

	if(account==nil)
	{
		account=[self fetchAccount:accountName];
	}
	
	// do we have this account in the db?
	//FeedAccount * account=[self fetchAccount:accountName];
	
	if(username && [username length]>0)
	{
		NSLog(@"Found username for %@ account: %@",accountName,username);
		if(account==nil)
		{
			NSLog(@"Adding new %@ account to db...",accountName);
			// add account to db
			account= [NSEntityDescription insertNewObjectForEntityForName:@"FeedAccount" inManagedObjectContext:moc];
			account.name=accountName;
			account.image=image;
			account.username=username;
			account.password=password;
			
			[accounts addObject:account];
		}
		else 
		{
			// update credentials in case they changed
			if([account.username isEqualToString:username])
			{
				// just update password in case it changed...
				account.password=password;
				
				if(!accountExists)
				{
					[accounts addObject:account];
				}
			}
			else 
			{
				NSLog(@"Username changed for %@ account, replacing existing account with new one...",accountName);
				// username changed, so delete existing account and create a new one...
				[moc deleteObject:account];
				
				if(accountExists)
				{
					[accounts removeObject:account];
				}
				
				account=nil;
				
				account= [NSEntityDescription insertNewObjectForEntityForName:@"FeedAccount" inManagedObjectContext:moc];
				
				account.name=accountName;
				account.image=image;
				account.username=username;
				account.password=password;
				
				[accounts addObject:account];
			}
		}
	}
	else 
	{
		if(account)
		{
			NSLog(@"No username in settings for %@ account, deleting account from db...",accountName);
			[moc deleteObject:account];
			
			if(accountExists)
			{
				[accounts removeObject:account];
			}
			
			// delete from db
			
			
			
			account=nil;
		}
	}
	NSError * error=nil;
	[moc save:&error];
	if(error)
	{
		NSLog(@"Error saving account info: %@",[error localizedDescription]);
	}*/
	
	return account;
}

- (FeedAccount*) fetchAccount:(NSString*)accountName
{
	NSManagedObjectContext * moc=[self managedObjectContext];

	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:@"FeedAccount" inManagedObjectContext:moc];
	
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"name == %@", accountName];
	
	[request setPredicate:predicate];
	
	NSArray * results=[[self managedObjectContext] executeFetchRequest:request error:nil];
	
	FeedAccount* account=nil;
	
	if([results count]>0)
	{
		if([results count]>1)
		{
			NSLog(@"More than one account found with name %@",accountName);
		}
		account=[results objectAtIndex:0];
	}
	else 
	{
		NSLog(@"No such account found in database: %@",accountName);
	}

	
	[request release];
	
	return account;
}
	
- (void) loadArchivedData
{
	NSLog(@"loadArchivedData");

	NSString * filePath=[self dataFilePath];
	
	NSLog(@"Loading archived data from: %@",filePath);
	
	@try {
		
		NSData * data =[[NSMutableData alloc]
						initWithContentsOfFile:filePath];
		
		if (data) 
		{
			NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc]
										  initForReadingWithData:data];
		
			self.feedImageCache=[unarchiver decodeObjectForKey:@"feedImageCache"];
					
			self.selectedItems=[unarchiver decodeObjectForKey:@"selectedItems"];
			
			self.fetchers=[unarchiver decodeObjectForKey:@"fetchers"];
			
			self.fetcher =[unarchiver decodeObjectForKey:@"fetcher"];
			self.itemIndex=[unarchiver decodeIntForKey:@"itemIndex"]; 
			self.sharingPublishActions=[unarchiver decodeObjectForKey:@"sharingPublishActions"];
			
			BOOL isNotFirstRun= [unarchiver decodeBoolForKey:@"isNotFirstRun"];
			
			if(!isNotFirstRun)
			{
				NSLog(@"isFirstRun=YES");
				isFirstRun=YES;
			}
			else 
			{
				NSLog(@"isFirstRun=NO");
				isFirstRun=NO;
			}

			
			[unarchiver finishDecoding];
			
			[unarchiver	release];
		
			[data release];
		}
		else 
		{
			isFirstRun=YES;
		}

	}
	@catch (NSException * e) {
		NSLog(@"Exception in loadArchivedData");
		NSLog(@"Exception: %@",[e description]);
	}
	@finally 
	{
		if(feedImageCache==nil)
		{
			feedImageCache=[[NSMutableDictionary alloc] init];
		}
		if(selectedItems==nil)
		{
			selectedItems=[[FeedItemDictionary alloc] init];
		}
	}
}


- (UIImage*) getImageFromCache:(NSString *)url usingUrl:(NSString*)usingUrl
{
	@synchronized(feedImageCache)
	{
		UIImage * img=[feedImageCache objectForKey:url];
		if(img!=nil)
		{
			return img;
		}
		img=[feedImageCache objectForKey:usingUrl];
		if(img!=nil)
		{
			[feedImageCache setObject:img forKey:url];
			return img;
		}
		@try 
		{
			// use the using url first...
			img=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:usingUrl]]];
			if(img)
			{
				NSLog(@"Got image from %@",usingUrl);
			}
			else 
			{
				NSLog(@"Failed to download image from url: %@",usingUrl);
			}
		}
		@catch (NSException * e) 
		{
			NSLog(@"Failed to download image from url: %@: %@",usingUrl,[e userInfo]);
		}
		@finally 
		{
		}
		
		if(img==nil)
		{
			@try 
			{
				img=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
				if(img)
				{
					NSLog(@"Got image from %@",url);
				}
				else 
				{
					NSLog(@"Failed to download image from url: %@",url);
				}
			}
			@catch (NSException * e) 
			{
				NSLog(@"Failed to download image from url: %@: %@",url,[e userInfo]);
			}
			@finally 
			{
			}
		}
		
		if(img)
		{
			[feedImageCache setObject:img forKey:url];
		}
		return img;
	}
	
}


- (UIImage*) getImageFromCache:(NSString*)url
{
	@synchronized(feedImageCache)
	{
		UIImage * img=[feedImageCache objectForKey:url];
		
		if(!img)
		{
			@try 
			{
				// TODO: push these into a queue and process all items in parallel at the end of this function...
				NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
				
				if(data)
				{
					img = [[[UIImage alloc] initWithData:data] autorelease];
				}
			}
			@catch (NSException * e) 
			{
				NSLog(@"Failed to download image from %@",url);
			}
			@finally 
			{
			}
			if(img)
			{	
				// TODO: resize if too big...
			
				// add to cache...
				[feedImageCache setObject:img forKey:url];
			}
		}
		
		return img;
	}
}


- (void) saveData
{
	NSLog(@"saveData");

	@try {
		 
		NSMutableData * data=[[NSMutableData alloc] init];
		
		if(data)
		{
			NSKeyedArchiver * archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		
			if(feedImageCache!=nil)
			{
				[archiver encodeObject:feedImageCache forKey:@"feedImageCache"];
			}
			if(selectedItems!=nil)
			{
				[archiver encodeObject:selectedItems forKey:@"selectedItems"];
				
			}
			if(fetchers!=nil)
			{
				[archiver encodeObject:fetchers	 forKey:@"fetchers"];
			}
			
			//if(itemHtmlView!=nil)
			//{
				[archiver encodeObject:self.fetcher forKey:@"fetcher"];
				[archiver encodeInt:self.itemIndex forKey:@"itemIndex"];
			//}
			if(self.sharingPublishActions)
			{
				[archiver encodeObject:self.sharingPublishActions forKey:@"sharingPublishActions"];
			}
			
			
			[archiver encodeBool:YES forKey:@"isNotFirstRun"];
			
			
			[archiver finishEncoding];
		
			[data writeToFile:[self dataFilePath] atomically:YES];
		
			[archiver release];
		
			
			[data release];
			NSLog(@"Data saved ...");
		}
		
	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception in saveData");
		NSLog(@"Exception: %@",[e description]);
	}
	@finally 
	{
		
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
	
	// get current navigation stack...
	NSArray * viewControllers=[[self masterNavController] viewControllers];
	
	self.fetchers=nil;
	fetchers=[NSMutableArray new];
	
	for(int i=1;i<[viewControllers count];i++)
	{
		UIViewController * controller = [viewControllers objectAtIndex:i];
		
		ItemFetcher * fetcher=[controller fetcher];
		
		[fetchers addObject:fetcher];
	}
	
	// Save data if appropriate
	[self saveData];
	
	NSError *error = nil;
    if (managedObjectContext != nil) 
	{
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
		{
			NSLog(@"Failed to save in AppDelegate.applicationWillTerminate: %@, %@", error, [error userInfo]);
			//abort();
        } 
    }
}

- (NSManagedObjectModel*)managedObjectModel 
{
	if (managedObjectModel) return managedObjectModel;
	
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
	
	return managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator 
{
	if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"InfoNgen.sqlite"]];
	
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSError *error = nil;
	[persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
	 
	return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	//managedObjectContext=[self createNewManagedObjectContext:NSMergeByPropertyStoreTrumpMergePolicy];
	managedObjectContext=[self createNewManagedObjectContext:NSOverwriteMergePolicy];
	
	//managedObjectContext=[self createNewManagedObjectContext:NSRollbackMergePolicy];
	
	return managedObjectContext;
}

- (NSManagedObjectContext *) createNewManagedObjectContext:(id)mergePolicy
{
  NSManagedObjectContext * moc=nil;
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
	  moc = [[NSManagedObjectContext alloc] init];
	  [moc setPersistentStoreCoordinator: coordinator];
	  [moc setMergePolicy:mergePolicy];
	  //[moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	  //[moc setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
	  
	  
	  
  }
  return moc;
}					   
									   
									  
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)dealloc {

	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [window release];
	[feedImageCache release];
	[headlineColor release];
	//[accounts release];
	[newsletterFormat release];
	[detailNavController release];
	[itemHtmlView  release];
	[newslettersScrollView release];
	[statusText	 release];
	[itemHtmlViewNoNav release];
	[masterNavController release];
	[selectedItems release];
	[queue release];
	[markAsReadQueue release];
	[fetchers release];
	[fetcher release];
	[sharingPublishActions release];
	[accountFeedsView release];
	[rootFeedsView release];
	[navPopoverController release];
	[tmpViewController release];
	[tmpFolder release];
	[tmpNewsletter release];
	//[feedView release];
    [super dealloc];
}

@end

