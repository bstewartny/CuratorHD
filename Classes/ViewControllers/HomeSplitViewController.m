#import "HomeSplitViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeSplitViewController
@synthesize homeViewController;

- (void) showHomeView
{
	if(homeViewController)
	{
		CATransition* transition = [CATransition animation];
		transition.duration = 0.2;
		transition.type = kCATransitionFade;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		[self.view addAnimation:transition forKey:kCATransition];
		
		[self.view addSubview:homeViewController.view];
		[self.view bringSubviewToFront:homeViewController.view];
		[self layoutSubviews];
		
		[homeViewController viewDidAppear:NO];
	/*
		if (_hiddenPopoverController && _hiddenPopoverController.popoverVisible) {
			[_hiddenPopoverController dismissPopoverAnimated:YES];
		}*/
	}
}

- (void) hideHomeView
{
	if(homeViewController)
	{
		CATransition* transition = [CATransition animation];
		transition.duration = 0.2;
		transition.type = kCATransitionFade;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		[self.view addAnimation:transition forKey:kCATransition];
		
		[homeViewController.view removeFromSuperview];
		[self layoutSubviews];
	}
}

- (BOOL) isShowingHomeView
{
	return ([homeViewController.view superview]!=nil);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.masterViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.detailViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.homeViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.masterViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.detailViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.homeViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	[self.masterViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.detailViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.homeViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (_hiddenPopoverController && _hiddenPopoverController.popoverVisible) 
	{
		[_hiddenPopoverController dismissPopoverAnimated:NO];
	}
	
	_reconfigurePopup = YES;
	[self layoutSubviewsForInterfaceOrientation:toInterfaceOrientation withAnimation:YES];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.masterViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.detailViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.homeViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	[self.masterViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
	[self.detailViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
	[self.homeViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.masterViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
	[self.detailViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
	[self.homeViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
}

- (void)layoutSubviewsForInterfaceOrientation:(UIInterfaceOrientation)theOrientation withAnimation:(BOOL)animate
{
	CGSize fullSize = [self splitViewSizeForOrientation:theOrientation];
		
	float width = fullSize.width;
	float height = fullSize.height;
		
	homeViewController.view.frame=CGRectMake(0, 0, width, height);
		
	if(![self isShowingHomeView])
	{
		[super layoutSubviewsForInterfaceOrientation:theOrientation withAnimation:animate];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self isShowingHomeView])
	{
		[self.homeViewController viewWillAppear:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if([self isShowingHomeView])
	{
		[self.homeViewController viewDidAppear:animated];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if([self isShowingHomeView])
	{
		[self.homeViewController viewWillDisappear:animated];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if([self isShowingHomeView])
	{
		[self.homeViewController viewDidAppear:animated];
	}
}

- (void) dealloc
{
	[homeViewController release];
	[super dealloc];
}

@end
