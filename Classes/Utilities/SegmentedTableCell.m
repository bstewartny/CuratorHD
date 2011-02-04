    //
//  SegmentedTableCell.m
//  Untitled
//
//  Created by Robert Stewart on 2/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "SegmentedTableCell.h"


@implementation SegmentedTableCell
@synthesize segmentedControl;


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier buttonNames:(NSArray*)buttonNames
{
    self = [super initWithStyle:style reuseIdentifier:identifier];
    
    if (self == nil)
    { 
        return nil;
    }
    
    UISegmentedControl * _segmentedControl=[[UISegmentedControl alloc] initWithItems:buttonNames];
	_segmentedControl.momentary = NO;                               
	//_segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	//_segmentedControl.frame = CGRectMake(75, 5, 60, 30);
	//[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	[self addSubview:_segmentedControl];
	
	self.accessoryView=_segmentedControl;
	
	/*
	for (UIView *oneView in self.contentView.subviews) {
		if ([oneView isMemberOfClass:[UITextField class]]) {
			[self.contentView insertSubview:_segmentedControl aboveSubview:oneView];
			[oneView removeFromSuperview];
		}
	}*/
	
	self.segmentedControl=_segmentedControl;
	
	[_segmentedControl release];
	 
    return self;
}

//  Disable highlighting of currently selected cell.
//
- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated 
{
    [super setSelected:selected animated:NO];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[segmentedControl release];
	[super dealloc];
}


@end
