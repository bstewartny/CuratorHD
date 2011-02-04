//
//  LabelledSwitch.m
//  Untitled
//
//  Created by Robert Stewart on 6/15/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "LabelledSwitch.h"
#import "UICustomSwitch.h"


@implementation LabelledSwitch
@synthesize centerSwitch,leftLabel,rightLabel,on;

- (id) initWithFrame:(CGRect) frame leftLabelText:(NSString*)leftLabelText rightLabelText:(NSString*)rightLabelText
{
	if([super initWithFrame:frame])
	{
		CGFloat labelWidth=(frame.size.width - 100 ) / 2;
		
		
		// Demonstrate alternte colors
		//switchView = [[UICustomSwitch alloc] initWithFrame:CGRectZero];
		//[switchView setCenter:CGPointMake(160.0f,200.0f)];
		//[switchView setAlternateColors:YES]; // built in, undocumented
		//[contentView addSubview:switchView];
		//[switchView release];
		
		centerSwitch=[[UICustomSwitch alloc] initWithFrame:CGRectZero];//WithFrame:CGRectMake(labelWidth+1, 0, 100, frame.size.height)];
		[centerSwitch setCenter:self.center];
		[centerSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		 
		centerSwitch.leftLabel.text=@"";
		centerSwitch.rightLabel.text=@"";
		
		leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, frame.size.height)];
		rightLabel=[[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-labelWidth, 0, labelWidth, frame.size.height)];
		
		leftLabel.text=leftLabelText;
		leftLabel.textAlignment=UITextAlignmentRight;
		rightLabel.text=rightLabelText;
		
		leftLabel.backgroundColor=[UIColor clearColor];
		rightLabel.backgroundColor=[UIColor clearColor];
		
		[self addSubview:leftLabel];
		[self addSubview:rightLabel];
		[self addSubview:centerSwitch];
		
		[self bringSubviewToFront:centerSwitch];
		
		[self setLabelStates:NO];
		
	
	}
	return self;
}

- (void) setOn:(BOOL)on
{
	centerSwitch.on=on;
	[self setLabelStates:on];
}

- (void) setLabelStates:(BOOL)state
{
	if(state)
	{
		leftLabel.textColor=[UIColor grayColor];
		
		rightLabel.textColor=[UIColor blackColor];
	}
	else 
	{
		leftLabel.textColor=[UIColor blackColor];
		
		rightLabel.textColor=[UIColor grayColor];
	}	

}

- (void) switchChanged:(id)sender
{
	on=centerSwitch.on;
	
	[self setLabelStates:centerSwitch.on];
		
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) dealloc
{
	[leftLabel release];
	[rightLabel release];
	[centerSwitch release];
	[super dealloc];
}
@end
