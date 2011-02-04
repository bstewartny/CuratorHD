//
//  ScrubberView.m
//  Untitled
//
//  Created by Robert Stewart on 7/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ScrubberView.h"


@implementation ScrubberView
@synthesize items,delegate,selectedItemIndex;

- (id) initWithFrame:(CGRect)frame
{
	if([super initWithFrame:frame])
	{
		// other initialization?
		selectedItemIndex=-1;
		self.backgroundColor=[UIColor whiteColor];
	}
	return self;
}

- (void) drawRect:(CGRect)rect
{
	NSLog(@"ScrubberView::drawRect");
	
	// draw the view...
	int count=[self.items count];
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	if(count>1)
	{
		CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1.0);
		
		int item_box_width=24;
		int item_box_height=16;
		
		float item_width = rect.size.width / (count+1);
		
		for(int i=0;i<count;i++)
		{
			int left=12 + (item_width*i);
			int top=10;
			
			// draw spot...
			
			CGContextStrokeEllipseInRect(ctx,CGRectMake(left, top, 2, 2));
		}
		
		if(self.selectedItemIndex>-1)
		{
			int spot_left=12 + (item_width*self.selectedItemIndex);
			int spot_top=10;
			
			// draw box on top of spot...
			int box_left=spot_left-12;
			int box_top=spot_top-8;
			
			// draw box
			CGContextStrokeRectWithWidth(ctx,CGRectMake(box_left, box_top, item_box_width, item_box_height),2.0);
			
		}
	}
}


-(void) dealloc
{
	[items release];
	[super dealloc];
}
@end
