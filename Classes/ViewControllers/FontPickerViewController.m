#import "FontPickerViewController.h"
#import "UIColorAdditions.h"
#import "CustomCellBackgroundView.h"
@implementation FontPickerViewController
@synthesize tableView,colorName,colorNames,fontSizeNames,fontStyle,fonts,fontNames,delegate,fontName,tag,fontTitle,fontSize,fontSizes;

- (void) viewDidLoad
{
	//self.navigationItem.title=@"Fonts";
	
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];

	self.tableView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
	
	//fontStyles=[[NSArray arrayWithObjects:@"normal",@"bold",nil] retain];
	//fontStyleNames=[[NSArray arrayWithObjects:@"Normal",@"Bold",nil] retain];
}
- (void) pickedFontStyle:(NSString*)style
{
	[delegate fontPicker:self pickedFontStyle:style];
}
- (void) pickedFontSize:(NSString*)size 
{
	[delegate fontPicker:self pickedFontSize:size];
}
- (void) pickedFontColor:(NSString*)colorName 
{
	[delegate fontPicker:self pickedFontColor:colorName];
}

- (void) pickedFont:(UIFont*)font withName:(NSString*)name
{
	[delegate fontPicker:self pickedFont:font withName:name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section==0)
	{
		return [fonts count];
	}
	else 
	{
		if(section==1)
		{
			return [fontSizes count];
		}
		else 
		{
			return [colorNames count];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
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
	
	if(section==0)
	{
		label.text=[NSString stringWithFormat:@"%@ Font",fontTitle];
	}
	else 
	{
		if(section==1)
		{
			label.text=[NSString stringWithFormat:@"%@ Size",fontTitle];
		}
		else 
		{
			label.text=[NSString stringWithFormat:@"%@ Color",fontTitle];
		}
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
	
	if(indexPath.section==0)
	{
		if(indexPath.row==0)
		{
			[cell.backgroundView setPosition:CustomCellBackgroundViewPositionTop];
		}
		else 
		{
			if(indexPath.row==[fontNames count]-1)
			{
				[cell.backgroundView setPosition:CustomCellBackgroundViewPositionBottom];
			}
			else 
			{
				[cell.backgroundView setPosition:CustomCellBackgroundViewPositionMiddle];
			}
		}
		NSString * name=[fontNames objectAtIndex:indexPath.row];
		UIFont * font=[fonts objectAtIndex:indexPath.row];
		
		if([name isEqualToString:fontName])
		{
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
		}
		else 
		{
			cell.accessoryType=UITableViewCellAccessoryNone;
		}
		cell.textLabel.font=font;
		cell.textLabel.text=name;
	}
	else 
	{
		if(indexPath.section==1)
		{
			if(indexPath.row==0)
			{
				[cell.backgroundView setPosition:CustomCellBackgroundViewPositionTop];
			}
			else 
			{
				if(indexPath.row==[fontSizes count]-1)
				{
					[cell.backgroundView setPosition:CustomCellBackgroundViewPositionBottom];
				}
				else 
				{
					[cell.backgroundView setPosition:CustomCellBackgroundViewPositionMiddle];
				}
			}
			NSString * size=[fontSizes objectAtIndex:indexPath.row];
			
			CGFloat sz=12.0 + (2.0 * indexPath.row);
			
			UIFont * currentFont=nil;
			
			if(fontName)
			{
				currentFont=[UIFont fontWithName:fontName size:sz];
			}
			else 
			{
				currentFont=[UIFont systemFontOfSize:sz];
			}
			
			if(currentFont)
			{
				cell.textLabel.font=currentFont;
			}
			
			if([size isEqualToString:fontSize])
			{
				cell.accessoryType=UITableViewCellAccessoryCheckmark;
			}
			else 
			{
				cell.accessoryType=UITableViewCellAccessoryNone;
			}
			cell.textLabel.text=[fontSizeNames objectAtIndex:indexPath.row];
		}
		else 
		{
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
			//switch(indexPath.row)
			//{
				//case 0:
					cell.textLabel.font=[UIFont systemFontOfSize:18];
				//	break;
				//case 1:
				//	cell.textLabel.font=[UIFont boldSystemFontOfSize:18];
				//	break;
			//}
			if([[colorNames objectAtIndex:indexPath.row] isEqualToString:colorName])
			{
				cell.accessoryType=UITableViewCellAccessoryCheckmark;
			}
			else 
			{
				cell.accessoryType=UITableViewCellAccessoryNone;
			}
			cell.textLabel.text=[colorNames objectAtIndex:indexPath.row];
			
			UIColor * color=[UIColor searchForColorByName:[colorNames objectAtIndex:indexPath.row]];
			if(color==nil)
			{
				color=[UIColor lightGrayColor];
			}
			cell.imageView.backgroundColor=color;
			cell.imageView.frame=CGRectMake(0, 0, 40, 40);
			cell.imageView.image=[UIImage imageNamed:@"dot_blank.png"];
			
			
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.section==0)
	{
		self.fontName=[fontNames objectAtIndex:indexPath.row];
		[self pickedFont:[fonts objectAtIndex:indexPath.row] withName:[fontNames objectAtIndex:indexPath.row]];
	}
	else 
	{
		if(indexPath.section==1)
		{
			self.fontSize=[fontSizes objectAtIndex:indexPath.row];
			[self pickedFontSize:[fontSizes objectAtIndex:indexPath.row]];
		}
		else 
		{
			self.colorName=[colorNames objectAtIndex:indexPath.row];
			[self pickedFontColor:self.colorName];
		}
	}
	[tableView reloadData];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)dealloc 
{
	[colorNames release];
	[colorName release];
	[fontStyles release];
	[fontStyleNames release];
	[fontTitle release];
	[fontSizes release];
	[fontSizeNames release];
	[fontSize release];
	[tableView release];
	[fonts release];
	[fontNames release];
	[fontName release];
	[fontStyle release];
    [super dealloc];
}

@end
