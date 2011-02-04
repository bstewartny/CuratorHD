//
//  AutocompleteTextField.m
//  Untitled
//
//  Created by Robert Stewart on 5/13/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "AutocompleteTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation AutocompleteItem
@synthesize value,display,button,required,excluded;

- (id) init
{
	if([super init])
	{
		self.required=YES;
	}
	return self;
}

- (void) dealloc
{
	[value release];
	[display release];
	[button release];
	[super dealloc];
}

@end

@implementation AutocompleteTextField

@synthesize textField,items,addButton,scrollView,delegate;

- (void) ensureInitialized
{
	if(self.items==nil)
	{
		NSMutableArray * tmp=[[NSMutableArray alloc] init];
	
		self.items=tmp;
	
		[tmp release];
	}
	
	if(scrollView==nil)
	{
		UIScrollView * sv=[[UIScrollView alloc] init];
		self.scrollView=sv;
		[sv release];
		[self addSubview:self.scrollView];
	}
	
	if(textField==nil)
	{
		UITextField * f=[[UITextField alloc] init];
		self.textField=f;
		[f release];
		[self.scrollView addSubview:self.textField];
	}
	
	if(addButton==nil)
	{
		UIButton * b=[UIButton buttonWithType:UIButtonTypeContactAdd];
		self.addButton=b;
		[self addSubview:self.addButton];
	}
}

- (id) init
{
	NSLog(@"AutocompleteTextField::init");
	
	if([super init])
	{
		[self ensureInitialized];
	}
	return self;
}
- (id) initWithFrame:(CGRect)frame
{
	
	NSLog(@"AutocompleteTextField::initWithFrame: %@",NSStringFromCGRect(frame));
	
	if([super initWithFrame:frame])
	{
		[self ensureInitialized];
	}
	return self;
}
// add search criteria to the left view 
// this will create a button on the left side of the text field
- (void) addItem:(NSObject*) value display:(NSString*)display
{
	NSLog(@"AutocompleteTextField::addItem");
	
	[self ensureInitialized];
	
	AutocompleteItem * item =[[AutocompleteItem alloc] init];
	
	item.value=value;
	item.display=display;
	
	UIButton * button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	button.frame=CGRectMake(0, 0, 100, kAutocompleteItemHeight); // this frame gets reset later in layoutSubviews...
	button.titleLabel.font=[UIFont systemFontOfSize:kAutocompleteItemFontSize];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[button setTitle:display forState:UIControlStateNormal];
	[button addTarget:self action:@selector(touchSubValue:) forControlEvents:UIControlEventTouchUpInside];
	
	item.button=button;
	
	[self.scrollView addSubview:button];
	[self.scrollView bringSubviewToFront:button];
	
	[items addObject:item];
	[item release];
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

- (void) touchSubValue:(id)sender
{
	UIButton * button=sender;
	// find value user touched and remove from the search
	AutocompleteItem * item=nil;
	
	int item_index=0;
	for (AutocompleteItem * s in items)
	{
		if([s.button isEqual:button])
		{
			item=s;
			break;
		}
		item_index++;
	}
	if(item)
	{
		
		NSString * toggleButton;
		if(item.required)
		{
			toggleButton=@"Make item optional";
		}
		else 
		{
			toggleButton=@"Make item required";
		}
		
		NSString * excludeButton;
		if(item.excluded)
		{
			excludeButton=@"Include item";
		}
		else {
			excludeButton=@"Exclude item";
		}


		
		UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:item.display delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove from search" otherButtonTitles:@"Search this only",toggleButton,excludeButton,nil];
		
		[actionSheet showFromRect:button.frame inView:self animated:YES];
		actionSheet.tag=item_index;
		[actionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	int item_index=actionSheet.tag;
	
	AutocompleteItem * item=[items objectAtIndex:item_index];
	
	if(buttonIndex==0)
	{
		// delete
		[item.button removeFromSuperview];
		[items removeObjectAtIndex:item_index];
	}
	
	
	
	
	if(buttonIndex==1)
	{
		NSMutableArray * tmp=[[NSMutableArray alloc] init];
		// new search with just this entity
		for (AutocompleteItem * s in items)
		{
			if(![s isEqual:item])
			{
				[tmp addObject:s];
			}
		}
		for (AutocompleteItem * s in tmp)
		{
			[s.button removeFromSuperview];
			[items removeObject:s];
		}
		[tmp release];
	}
	if(buttonIndex==2)
	{
		item.required=!item.required;
		item.excluded=NO;
	}
	if(buttonIndex==3)
	{
		item.required=NO;
		item.excluded=!item.excluded;
	}
	if(delegate && [delegate respondsToSelector:@selector(searchChanged:)]) 
	{
        NSLog(@"Delegating!");
        [delegate searchChanged:self];
    } 
	else 
	{
        NSLog(@"Not Delegating. I dont know why.");
    }  
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
	NSLog(@"AutocompleteTextField::drawRect: %@",NSStringFromCGRect(rect));
	[super drawRect:rect];
}

- (void)layoutSubviews
{
	
	NSLog(@"AutocompleteTextField::layoutSubviews: bounds: %@",NSStringFromCGRect(self.bounds));
	
	[self ensureInitialized];
	
	// make scroll view as wide as main view with room on right for add button
	
	CGRect scrollViewFrame=CGRectMake(0, 0, self.bounds.size.width-40, self.bounds.size.height);
	
	self.scrollView.frame=scrollViewFrame;
	
	// put add button vertically centered on right side
	
	CGRect addButtonFrame=CGRectMake(self.bounds.size.width-35, self.bounds.size.height/2-10, addButton.frame.size.width, addButton.frame.size.height);
	
	addButton.frame=addButtonFrame;
	
	CGFloat left_padding=8;
	
	CGFloat right_padding=5;
	
	CGFloat row_height=kAutocompleteItemHeight + 8;
	
	CGFloat top_padding=2;
	
	CGFloat left=left_padding;
	
	CGFloat top=top_padding;
	
	CGFloat min_text_field_width=80;
	
	UIFont * itemFont=[UIFont systemFontOfSize:kAutocompleteItemFontSize];
	
	// set frames of sub values
	for (AutocompleteItem * item in items)
	{
		
		CGSize text_size=[item.display sizeWithFont:itemFont];
		
		CGFloat display_width=text_size.width+16;  
		
		CGFloat height=kAutocompleteItemHeight;
		
		if(left + display_width +right_padding >= scrollViewFrame.size.width)
		{
			// put on next row
			left=left_padding;
			top+=row_height;
		}
		
		CGRect frame=CGRectMake(left, top, display_width, height);
		
		item.button.frame=frame;
		
		if(!item.required)
		{
			item.button.titleLabel.textColor=[UIColor greenColor];
		}
		
		if(item.excluded)
		{
			item.button.titleLabel.textColor=[UIColor redColor];
		}
		
		left+=display_width+right_padding;
	}
	
	// add text field
	if(left+80 >=scrollViewFrame.size.width)
	{
		left=left_padding;
		top+=row_height;
	}
	
	self.textField.frame=CGRectMake(left,top-2, scrollViewFrame.size.width - left - right_padding, kAutocompleteItemHeight+2);
	[self.scrollView bringSubviewToFront:self.textField];
	
	[scrollView setContentSize:CGSizeMake(scrollViewFrame.size.width,    top+kAutocompleteItemHeight+2)];
	
	[super layoutSubviews];
}

- (void) dealloc
{
	[items release];
	[textField release];
	[scrollView release];
	[super dealloc];
}
@end
