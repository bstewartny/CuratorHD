#import "FolderViewController.h"
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
#import "FolderTableViewCell.h"
#import "FolderTweetTableViewCell.h"
#import "FastFolderTableViewCell.h"
#import "FastTweetFolderTableViewCell.h"
#import "DocumentEditFormViewController.h"

@implementation FolderViewController

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 124.0;
}

- (void) viewDidLoad
{
	self.folderMode=YES;
	self.updatable=NO;
	
	[super viewDidLoad];
}

- (UITableViewCell *) headlineCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"FeedItemCellIdentifier";
	
	FastFolderTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[FastFolderTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
	}
			
	cell.item=item;
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;

	if([item.origin length]==0)
	{
		cell.origin=@"From the Web";
	}
	else
	{
		cell.origin=item.origin;
	}
	
	cell.date=[item shortDisplayDate];
	cell.headline=item.headline;
	
	if([[item origSynopsis] length]>0)
	{
		if([[item synopsis] length]==0)
		{
			item.synopsis=[stripper stripMarkup:[item origSynopsis]];
		}
	}
	
	cell.synopsis=item.synopsis;
	
	cell.comments=item.notes;  
	
	cell.itemImage=item.image;
	
	return cell;
}

- (UITableViewCell *) tweetCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"TweetItemCellIdentifier";
	
	FastTweetFolderTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[FastTweetFolderTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
	}
	
	cell.selectionStyle=UITableViewCellSelectionStyleGray;

	cell.tweet=item.headline;
	cell.date=[item shortDisplayDate];
	cell.username=item.origin;
	
	if(item.image)
	{
		cell.userImage=item.image;
	}
	else {
		cell.userImage=[UIImage imageNamed:@"profileplaceholder.png"];
	}

	cell.comments=item.notes;
	
	return cell;
}


@end
