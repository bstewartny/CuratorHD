#import "ColorPickerViewController.h"
#import "UIColorAdditions.h"
#import "CustomCellBackgroundView.h"

@implementation ColorPickerViewController
@synthesize tableView,colorNames,delegate,colorName,tag,colorTitle;

- (void) viewDidLoad
{
	//self.navigationItem.title=@"Colors";
	self.colorNames=[UIColor cssColorNames];
	
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	
	
	self.tableView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
}
- (void) pickedColor:(UIColor*)color withName:(NSString*)name
{
	[delegate colorPicker:self pickedColor:color withName:name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [colorNames count];
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return colorTitle;
}*/

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
	
	if(indexPath.row==0)
	{
		[cell.backgroundView setPosition:CustomCellBackgroundViewPositionTop];
	}
	else 
	{
		if(indexPath.row==[colorNames count]-1)
		{
			[cell.backgroundView setPosition:CustomCellBackgroundViewPositionBottom];
			
		}
		else 
		{
			[cell.backgroundView setPosition:CustomCellBackgroundViewPositionMiddle];
			
			
		}

	}

	NSString * name=[colorNames objectAtIndex:indexPath.row];
	//UIColor * color=[colors objectAtIndex:indexPath.row];
	UIColor * color=[UIColor searchForColorByName:name];
	if(color==nil)
	{
		color=[UIColor lightGrayColor];
	}
	cell.imageView.backgroundColor=color;
	cell.imageView.frame=CGRectMake(0, 0, 40, 40);
	cell.imageView.image=[UIImage imageNamed:@"dot_blank.png"];
	
	if([name isEqualToString:colorName])
	{
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	}
	else 
	{
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
	cell.textLabel.text=name;
	
	return cell;
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
	label.text=[NSString stringWithFormat:@"%@ Color",colorTitle];
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
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	self.colorName=[colorNames objectAtIndex:indexPath.row];
	
	[tableView reloadData];
	
	[self pickedColor:[UIColor searchForColorByName:[colorNames objectAtIndex:indexPath.row]] withName:[colorNames objectAtIndex:indexPath.row]];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)dealloc {
	[colorTitle release];
	[tableView release];
	//[colors release];
	[colorNames release];
	[colorName release];
    [super dealloc];
}


@end
