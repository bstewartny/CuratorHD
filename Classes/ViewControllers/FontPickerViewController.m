#import "FontPickerViewController.h"
#import "UIColorAdditions.h"
#import "CustomCellBackgroundView.h"
#import <QuartzCore/QuartzCore.h>
#import "Font.h"

@implementation FontPickerViewController
@synthesize tableView,delegate;
@synthesize families;
@synthesize styles;
@synthesize sizes;
@synthesize weights;
@synthesize colors,sectionName;
@synthesize font;

- (id) initWithFont:(Font*)font
{
	if(self=[super initWithNibName:@"NewsletterFormattingView" bundle:nil])
	{
		self.font=font;
		self.families=[NSArray arrayWithObjects:[FontValue withName:@"Arial" andValue:@"Arial"],
					   [FontValue withName:@"Georgia" andValue:@"Georgia"],
					   [FontValue withName:@"Courier" andValue:@"Courier"],nil];
		
		self.styles=[NSArray arrayWithObjects:[FontValue withName:@"Normal" andValue:@"normal"],
					 [FontValue withName:@"Italic" andValue:@"italic"],nil];
		
		self.weights=[NSArray arrayWithObjects:[FontValue withName:@"Normal" andValue:@"normal"],
					  [FontValue withName:@"Bold" andValue:@"bold"],nil];
		
		self.sizes=[NSArray arrayWithObjects:[FontValue withName:@"Small" andValue:@"small"],
					[FontValue withName:@"Medium" andValue:@"medium"],
					[FontValue withName:@"Large" andValue:@"large"],
					[FontValue withName:@"Extra Large" andValue:@"x-large"],nil];
		
		self.colors=[NSArray arrayWithObjects:[FontValue withName:@"Black" andValue:@"black"],
					 [FontValue withName:@"Grey" andValue:@"grey"],
					 [FontValue withName:@"Red" andValue:@"red"],
					 [FontValue withName:@"Blue" andValue:@"blue"],nil];
	}
	return self;
}
- (void) viewDidLoad
{
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];

	self.tableView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) 
	{
		case 0:
			return [families count];	
		case 1:
			return [styles count];
		case 2:
			return [weights count];
		case 3:
			return [sizes count];
		case 4:
			return [colors count];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView * v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
	v.backgroundColor=[UIColor clearColor];
	
	UILabel * label=[[UILabel alloc] init];
	
	label.textColor=[UIColor whiteColor];
	
	switch (section) 
	{
		case 0:
			label.text=[NSString stringWithFormat:@"%@ Font",sectionName];	
			break;
		case 1:
			label.text=[NSString stringWithFormat:@"%@ Style",sectionName];
			break;
		case 2:
			label.text=[NSString stringWithFormat:@"%@ Weight",sectionName];
			break;
		case 3:
			label.text=[NSString stringWithFormat:@"%@ Size",sectionName];
			break;
		case 4:
			label.text=[NSString stringWithFormat:@"%@ Color",sectionName];
			break;
	}

	label.backgroundColor=[UIColor clearColor];
	
	[label sizeToFit];
	
	CGRect f=label.frame;
	f.origin.x=15;
	f.origin.y=5;
	label.frame=f;
	
	[v addSubview:label];
	
	[label release];
	
	return [v autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	cell.backgroundColor=[UIColor clearColor];
	
	CustomCellBackgroundView * gbView=[[[CustomCellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
	
	cell.backgroundView=gbView;
	
	gbView.fillColor=[UIColor blackColor]; 
	gbView.borderColor=[UIColor grayColor];
	
	cell.backgroundView.alpha=0.5;
	
	cell.textLabel.textColor=[UIColor whiteColor];
	
	NSString * value=nil;
	FontValue * fontValue;
	int numValues=0;
	
	switch (indexPath.section) 
	{
		case 0:
			value=font.family;
			fontValue=[families objectAtIndex:indexPath.row];
			numValues=[families count];
			break;
		case 1:
			value=font.style;
			fontValue=[styles objectAtIndex:indexPath.row];
			numValues=[styles count];
			break;
		case 2:
			value=font.weight;
			fontValue=[weights objectAtIndex:indexPath.row];
			numValues=[weights count];
			break;
		case 3:
			value=font.size;
			fontValue=[sizes objectAtIndex:indexPath.row];
			numValues=[sizes count];
			break;
		case 4:
			value=font.color;
			fontValue=[colors objectAtIndex:indexPath.row];
			numValues=[colors count];
			break;
	}
	
	if(indexPath.row==0)
	{
		[cell.backgroundView setPosition:CustomCellBackgroundViewPositionTop];
	}
	else 
	{
		if(indexPath.row==(numValues-1))
		{
			[cell.backgroundView setPosition:CustomCellBackgroundViewPositionBottom];
		}
		else 
		{
			[cell.backgroundView setPosition:CustomCellBackgroundViewPositionMiddle];
		}
	}
	
	if([value isEqualToString:fontValue.value])
	{
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	}
	else 
	{
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
	cell.textLabel.text=fontValue.name;
	 
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	switch (indexPath.section) 
	{
		case 0:
			font.family=[[families objectAtIndex:indexPath.row] value];
			break;	
		case 1:
			font.style=[[styles objectAtIndex:indexPath.row] value];
			break;	
		case 2:
			font.weight=[[weights objectAtIndex:indexPath.row] value];
			break;
		case 3:
			font.size=[[sizes objectAtIndex:indexPath.row] value];
			break;
		case 4:
			font.color=[[colors objectAtIndex:indexPath.row] value];
			break;
	}
	
	[tableView reloadData];
	
	[delegate fontPicker:self pickedFont:font];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)dealloc 
{
	[sectionName release];
	[font release];
	[tableView release];
	[families release];
	[styles release];
	[sizes release];
	[weights release];
	[colors release];
	
	[super dealloc];
}

@end
