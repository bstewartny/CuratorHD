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

@implementation FolderViewController

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 140.0;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (UITableViewCell *) headlineCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"FeedItemCellIdentifier";
	
	FolderTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[FolderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	if(tableView.editing)
	{
		cell.selectionStyle=3;
	}
	else 
	{
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
	}
	
	if(item.image)
	{
		cell.itemImageView.image=item.image;
	}
	else 
	{
		cell.itemImageView.image=[UIImage imageNamed:@"dot_blank.png"]; 
		//cell.itemImageView.image=[UIImage imageNamed:@"samplenewsletter-1.png"]; 
	}

	cell.sourceLabel.text=item.origin;
	cell.dateLabel.text=[item shortDisplayDate];
	
	if([[item origSynopsis] length]>0)
	{
		if([[item synopsis] length]==0)
		{
			item.synopsis=[stripper stripMarkup:[item origSynopsis]];
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
	
	cell.commentLabel.text=item.notes;  
	
	return cell;
}

- (UITableViewCell *) tweetCellForRowAtIndexPath:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath item:(FeedItem*)item
{
	static NSString * identifier=@"TweetItemCellIdentifier";
	
	FolderTweetTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[FolderTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	if(tableView.editing)
	{
		cell.selectionStyle=3;
	}
	else 
	{
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
	}
	
	if(item.image)
	{
		cell.itemImageView.image=item.image;
	}
	else 
	{
		cell.itemImageView.image=[UIImage imageNamed:@"profileplaceholder.png"]; 
	}
	
	cell.sourceLabel.text=item.origin;
	cell.dateLabel.text=[item shortDisplayDate];
	cell.headlineLabel.text=item.headline;
	cell.commentLabel.text=item.notes;  
	
	return cell;
}

@end
