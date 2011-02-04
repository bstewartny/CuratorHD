//
//  PublishAction.m
//  Untitled
//
//  Created by Robert Stewart on 6/21/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "PublishAction.h"


@implementation PublishAction
@synthesize isFavorite,isSource;
 
- (void) action:(id)sender
{
	[self retain];
	// handle the publish action - typically show an action sheet and then respond to actions
	// when handling an action probably get current item or all selected items and then publish those items somehow...
	[self actionComplete];
}

- (void)longPress:(UILongPressGestureRecognizer*)recognizer
{
	if(recognizer.state==UIGestureRecognizerStateBegan)
	{
		[self longAction:recognizer.view];
	}
}

- (void) longAction:(id)sender
{
	
	// handle when user touches and holds on the button - a long press
	// usually to show a more comprehensive menu or options if using single touch action to add or send item
	[self action:sender];
}

- (void) actionComplete
{
	[self release];
	// call when action is finished, to notify other parts of the UI to reload data if counts changed, items were deleted, etc.
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadActionData"
	 object:nil];
}

- (void) alertUserNoCurrentItem
{
	UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"No current item" message:@"There is no current item to share." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
	[alertView show];
	[alertView release];
}

- (UIImage*)image
{
	// button image
	return nil;
}

- (NSString*)title
{
	// button title
	return @"PublishAction";
}

- (int)count
{
	// number of items if showing count (return -1 to show no count)
	return -1;
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		isFavorite=[decoder decodeBoolForKey:@"isFavorite"];
		isSource=[decoder decodeBoolForKey:@"isSource"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeBool:isFavorite forKey:@"isFavorite"];
	[encoder encodeBool:isSource forKey:@"isSource"];
	
}

- (void) dealloc
{
	[super dealloc];
}

@end
