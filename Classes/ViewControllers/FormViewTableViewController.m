#import "FormViewTableViewController.h"

@implementation FormViewTableViewController
@synthesize delegate,names,title,tag;

- (id) initWithTitle:(NSString*)theTitle tag:(NSInteger)theTag delegate:(id)theDelegate names:(NSArray*)theNames andValues:(NSArray*)theValues;
{
	self=[super initWithStyle:UITableViewStyleGrouped];
	
	if(self)
	{
		self.tag=theTag;
		self.title=theTitle;
		self.delegate=theDelegate;
		self.names=theNames;
		
		valueFields=[[NSMutableArray alloc] init];
		for(int i=0;i<[names count];i++)
		{
			if([[names objectAtIndex:i] hasPrefix:@"text:"])
			{
				UITextView * t=[[UITextView alloc] init];
				if([theValues count]>i)
				{
					t.text=[theValues objectAtIndex:i];
				}
				[valueFields addObject:t];
				[t release];
			}
			else 
			{
				UITextField * t=[[UITextField alloc] init];
				if([theValues count]>i)
				{
					t.text=[theValues objectAtIndex:i];
				}
				[valueFields addObject:t];
				[t release];
			}
		}
		
		self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
		
		self.navigationItem.title=theTitle;
		
		self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
	}
		
	return self;
}

- (void) cancel:(id)sender
{
	[delegate formViewDidCancel:tag];
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void) done:(id)sender
{
	NSMutableArray * values=[[[NSMutableArray alloc] init] autorelease];
	
	for(id * t in valueFields)
	{
		if([[t text] length]>0)
		{
			[values addObject:[t text]];
		}
		else 
		{
			[values addObject:@""];
		}
	}
	
	[delegate formViewDidFinish:tag withValues:values];
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	id * textField=[valueFields objectAtIndex:indexPath.section];
	[textField becomeFirstResponder];
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if([[valueFields objectAtIndex:indexPath.section] isKindOfClass:[UITextView class]])
	{
		return 132;
	}
	else 
	{
		return tableView.rowHeight;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	if([[valueFields objectAtIndex:indexPath.section] isKindOfClass:[UITextView class]])
	{
		UITextView * t=[valueFields objectAtIndex:indexPath.section]; 
		
		t.frame=CGRectMake(8, 4, 300, 122);
		t.backgroundColor=[UIColor clearColor];
		t.delegate=self;
		 
		t.autoresizingMask=UIViewAutoresizingFlexibleWidth; 
		
		t.font=[UIFont systemFontOfSize:18];
		t.textColor=[UIColor blackColor];
		t.tag=indexPath.section;
		
		 
		if(indexPath.section==0)
		{
			[t becomeFirstResponder];
		}
		
		[cell.contentView addSubview:t];
		
	}
	else 
	{
		UITextField * t=[valueFields objectAtIndex:indexPath.section]; 
		
		t.frame=CGRectMake(10, (tableView.rowHeight - 22)/2, 310,      22);
		t.backgroundColor=[UIColor clearColor];
		t.delegate=self;
		t.autocapitalizationType=UITextAutocapitalizationTypeWords;
		
		t.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		
		t.font=[UIFont systemFontOfSize:18];
		t.textColor=[UIColor blackColor];
		t.tag=indexPath.section;
		 
		if(indexPath.section==0)
		{
			[t becomeFirstResponder];
		}
		
		[cell.contentView addSubview:t];
	}

	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if([[valueFields objectAtIndex:section] isKindOfClass:[UITextView class]])
	{
		return [[names objectAtIndex:section] substringFromIndex:5];
	}
	else 
	{
		return [names objectAtIndex:section];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [names count];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES;
}

- (void) dealloc
{
	 
	[valueFields release];
	[title release];
	[names release];
	[super dealloc];
}

@end
