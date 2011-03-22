#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MGSplitViewController.h"

//#import "IASKAppSettingsViewController.h"
// set this to YES to enabled sources, newsletters and favorites, or to NO to just enable newsletters
#define kEnableSearchFeatures YES 

#define kEnableV2 YES

// tags for alert view and text fields inside alert views

#define kAddNewsletterAlertViewTag 1001
#define kAddNewsletterAlertViewNameTag 1002
#define kAddNewsletterAlertViewSectionNameTag 1003

#define kAddFolderAlertViewTag 2001
#define kAddFolderAlertViewNameTag 2002
#define kEditFolderNameAlertViewTag 2003
#define kEditNewsletterNameAlertViewTag 2004

#define kAddNewsletterSectionAlertViewTag 3001
#define kAddNewsletterSectionAlertViewNameTag 3002

#define kInvalidAccountSettingsAlertViewTag 9999

#ifdef UI_USER_INTERFACE_IDIOM()
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (false)
#endif




@class NewsletterViewController;
@class NewslettersViewController; 
@class NewsletterSettingsViewController;
@class NewsletterHTMLPreviewViewController;
@class LoginTicket;
@class SearchResults;
@class Newsletter;
@class NewslettersScrollViewController;
@class HomeViewController;
//@class Favorites;
@class MetaNameResolver;
@class FeedItemHTMLViewController;
@class FeedItemDictionary;
@class FeedItem;
@class FeedsViewController;
@class RootFeedsViewController;
@class FeedViewController;
@class Folder;
@class FeedAccount; 
@class CategoryFeedFetcher;

//@class MGSplitViewController;
@interface AppDelegate : NSObject <UIApplicationDelegate,MGSplitViewControllerDelegate> 
{
	NSMutableArray * sharingPublishActions;
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    UIWindow *window;
	UITabBarController * tabBarController;
	//IASKAppSettingsViewController *appSettingsViewController;
	//Newsletter * newsletter;
	//NSMutableArray * newsletters;
	//NSMutableArray * newsletterArchives;
	//NSMutableArray * folders;
	//NSMutableArray * accounts;
	//NSMutableArray * feeds;
	//MetaNameResolver * metaNameResolver;
	//Favorites * favorites;
	//Favorites * selectedItems;
	FeedItemDictionary * selectedItems;
	UIViewController * tmpViewController;
	NSMutableDictionary * feedImageCache;
	BOOL clearOnPublish;
	UIColor * headlineColor;
	NSString * newsletterFormat;
	UINavigationController * detailNavController;
	UINavigationController * masterNavController;
	FeedItemHTMLViewController * itemHtmlView;
	FeedItemHTMLViewController * itemHtmlViewNoNav;
	
	
	//FeedViewController * feedView;
	
	
	
	NewslettersScrollViewController * newslettersScrollView;
	BOOL updating;
	NSOperationQueue * queue;
	NSString * statusText;
	Newsletter * currentNewsletter;
	
	
	NSOperationQueue * markAsReadQueue;
	
	NSMutableArray * fetchers;
	ItemFetcher * fetcher;
	int itemIndex;
	
	BOOL useGoogleReaderReadingListCache;
	BOOL refreshOnStart;
	
	int maxNewsletterSynopsisLength;
	FeedsViewController * accountFeedsView;
	RootFeedsViewController * rootFeedsView;
	BOOL isFirstRun;
	MGSplitViewController	* splitView;
	//UISplitViewController * splitView;
	UIPopoverController * navPopoverController;
	Folder * tmpFolder;
	Newsletter * tmpNewsletter;
}
@property(nonatomic,retain) NSString * statusText;
@property(nonatomic,retain) Folder * tmpFolder;
@property(nonatomic,retain) Newsletter * tmpNewsletter;
@property(nonatomic,retain) UIPopoverController * navPopoverController;

//@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;
@property(retain) NSMutableDictionary * feedImageCache;
@property(nonatomic,retain) NSMutableArray * fetchers;
@property(nonatomic,retain) UITabBarController * tabBarController;
@property(nonatomic,retain) UINavigationController * detailNavController;
@property(nonatomic,retain) FeedItemHTMLViewController * itemHtmlView;
@property(nonatomic,retain) FeedItemHTMLViewController * itemHtmlViewNoNav;
//@property(nonatomic,retain) FeedViewController * feedView;


@property(nonatomic,retain) NewslettersScrollViewController * newslettersScrollView;
@property(nonatomic,retain) ItemFetcher * fetcher;
@property(nonatomic) int itemIndex;
@property(nonatomic) int maxNewsletterSynopsisLength;


@property(nonatomic,retain) NSMutableArray * sharingPublishActions;
//@property (retain) NSMutableArray * newsletters;
//@property (retain) NSMutableArray * newsletterArchives;
@property(nonatomic,retain) UINavigationController * masterNavController;
@property(nonatomic,retain) FeedItemDictionary * selectedItems;
//@property (retain) NSMutableArray * folders;
//@property (retain) NSMutableArray * feeds;
//@property (retain) NSMutableArray * accounts;
//@property (retain) Favorites * favorites;
//@property (retain) Favorites * selectedItems;
//@property(nonatomic,retain) MetaNameResolver * metaNameResolver;
// @property (nonatomic,retain) Newsletter * newsletter;
@property(nonatomic,retain) UIColor * headlineColor;
@property(nonatomic) BOOL clearOnPublish;
@property(nonatomic) BOOL refreshOnStart;

@property(nonatomic,retain) NSString * newsletterFormat;
@property (nonatomic, retain) IBOutlet UIWindow *window;
//- (void) resolveMetaNames:(SearchResults*)searchResults;
//- (NSArray*) lookupByName:(NSString*)name displayValue:(NSString*)displayValue;
//- (void) resetMetaNamesStore;
- (NSString *)dataFilePath;
- (void) loadArchivedData;
- (void) saveData;
//- (UIImage*) shareImage;
//- (NSString*) shareText;
- (void) markAsRead:(FeedItem*)item;
- (void) applyDefaultFormatting:(Newsletter*)newsletter;
- (void) pushMasterViewController:(UIViewController*)controller;
- (void) showItemHtml:(NSInteger)index itemFetcher:(ItemFetcher*)itemFetcher allowComments:(BOOL)allowComments;
- (void) addAccount:(NSString*)name  sortName:(NSString*)sortName prefix:(NSString*)prefix image:(UIImage*)image username:(NSString*)username password:(NSString*)password;
- (FeedAccount*)fetchOrCreateAccount:(NSString*)accountName sortName:(NSString*)sortName prefix:(NSString*)accountSettingsPrefix image:(UIImage*)image;

@end
