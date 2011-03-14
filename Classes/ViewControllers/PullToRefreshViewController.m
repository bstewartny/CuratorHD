#import "PullToRefreshViewController.h"
#import <QuartzCore/QuartzCore.h>

#define REFRESH_HEADER_HEIGHT 60.0f

@implementation PullToRefreshViewController
@synthesize tableView,pullDownView,textPull,textRelease,textLoading,refreshLabel, refreshArrow, refreshSpinner,pullDownBackgroundColor;


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
	if (!updatable) {
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
	
	if(!updatable)
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

- (void) backfill
{
	// subclass
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(updatable)
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
	//[self.tableView setContentInset:UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0)   animated:NO];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
	
    // Refresh action!
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
}

- (void) refresh
{
	// subclass
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

- (void)addPullToRefreshHeader 
{
	self.textPull=@"Pull down to refresh...";
	self.textRelease=@"Release to refresh...";
	self.textLoading=@"Loading new items...";
	
	if(pullDownBackgroundColor)
	{
		pullDownView=[[UIView alloc] initWithFrame:CGRectMake(0, 0-(REFRESH_HEADER_HEIGHT*4), 320, REFRESH_HEADER_HEIGHT*4)];
	
		pullDownView.backgroundColor=pullDownBackgroundColor;//[UIColor viewFlipsideBackgroundColor];
	}
	
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 0-REFRESH_HEADER_HEIGHT, 320-80, REFRESH_HEADER_HEIGHT)];
    
	refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:14.0];
	refreshLabel.textColor=[UIColor lightGrayColor];
    refreshLabel.textAlignment = UITextAlignmentLeft;
	
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down.png"]];
    refreshArrow.frame = CGRectMake(2,
                                    ((REFRESH_HEADER_HEIGHT - 48) / 2)-REFRESH_HEADER_HEIGHT,
                                    48, 48);
	
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(16, ((REFRESH_HEADER_HEIGHT - 20) / 2)-REFRESH_HEADER_HEIGHT, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
	
    [tableView addSubview:refreshLabel];
    [tableView addSubview:refreshArrow];
    [tableView addSubview:refreshSpinner];
	
	if(pullDownView)
	{
		[tableView addSubview:pullDownView];
		[tableView sendSubviewToBack:pullDownView];
	}
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)dealloc {
	[tableView release];
	[textPull release];
	[textRelease release];
	[textLoading release];
	[pullDownView release];
	[refreshLabel release];
	[refreshArrow release];
	[refreshSpinner release];
	[pullDownBackgroundColor release];
    [super dealloc];
}


@end
