    //
//  DocumentTextViewController.m
//  Untitled
//
//  Created by Robert Stewart on 2/22/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DocumentTextViewController.h"
#import "SearchResult.h"


@implementation DocumentTextViewController
@synthesize searchResult,text,textView;


- (IBAction) select
{
	// get selected text...
	// add as synopsis for result...
	NSString * selectedText=nil;
	
	NSRange range=textView.selectedRange;
	
	if(range.length!=0)
	{
		if(range.location!=-1)
		{
			selectedText=[self.text substringWithRange:range];
		}
	}
	
	if(selectedText && [selectedText length]>0)
	{
		searchResult.synopsis=selectedText;
	}
	[self.view removeFromSuperview];
}

- (IBAction) cancel
{
	[self.view removeFromSuperview];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.textView.text=text;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[text release];
	[textView release];
	[searchResult release];
    [super dealloc];
}


@end
