//
//  NewsletterUpdateFormViewController.m
//  Untitled
//
//  Created by Robert Stewart on 4/7/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterUpdateFormViewController.h"
#import "NewsletterSection.h"
#import "NewsletterItemContentView.h"

@implementation NewsletterUpdateFormViewController
@synthesize tableView,cancelButton,sections,tableCells,sectionStatus;

- (BOOL) isCancelled
{
	return cancelled;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	cancelled=NO;
	self.tableCells=[[NSMutableArray alloc] init];
	self.sectionStatus=[[NSMutableArray alloc] init];
	
	self.cancelButton.possibleTitles = [NSSet setWithObjects:@"Cancel", @"Close", nil];
	
	self.title=@"Updating Newsletter Sections";
	
	if(self.sections)
	{
		for(NewsletterSection * section in self.sections)
		{
			UITableViewCell * cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			
			cell.tag=section;
			
			cell.textLabel.text=section.name;
			
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			
			//UIColor * nameColor=[NewsletterItemContentView colorWithHexString:@"339933"];
			
			cell.textLabel.textColor=[NewsletterItemContentView colorWithHexString:@"339933"];
			
			//UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
			
			//UIImage *whiteback = [UIImage imageNamed:@"blank.png"]; 
			//cell.imageView.image = whiteback; 
			//[cell.imageView addSubview:spinner]; 
			//[spinner release];
			
			[self.tableCells addObject:cell];
			[self.sectionStatus addObject:@""];
			
			[cell release];
		}
	}

    [super viewDidLoad];
}


-(IBAction) cancel:(id)sender
{
	cancelled=YES;
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (UITableViewCell*) getCellForSection:(NewsletterSection*)section
{
	for(UITableViewCell * cell in self.tableCells)
	{
		if(cell.tag==section)
		{
			NSLog(@"Got section: %@",section.name);
			return cell;
		}
	}
	return nil;
}

- (void) endUpdate
{
	[self.cancelButton setTitle:@"Close"];
}

- (void) startProgressForSection:(NewsletterSection*)section
{
	/*UITableViewCell * cell=[self getCellForSection:section];
	
	if(cell)
	{
		if([[cell.imageView subviews] count]>0)
		{
			UIActivityIndicatorView * av=[[cell.imageView subviews] objectAtIndex:0];
			if(av)
			{
				[av startAnimating];
			}
		}
	}*/
}

- (void) endProgressForSection:(NewsletterSection*)section
{
	/*UITableViewCell * cell=[self getCellForSection:section];
	
	if(cell)
	{
		if([[cell.imageView subviews] count]>0)
		{
			UIActivityIndicatorView * av=[[cell.imageView subviews] objectAtIndex:0];
			if(av)
			{
				[av performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
				[av removeFromSuperview];
			}
		}
	}*/
}

- (void) setStatusText:(NSString*)status forSection:(NewsletterSection*)section
{
	for(int i=0;i<[self.tableCells count];i++)
	{
		UITableViewCell * cell=[self.tableCells objectAtIndex:i];
	
		if(cell.tag==section)
		{
			[self.sectionStatus replaceObjectAtIndex:i withObject:status];	
			[tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
			return;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"cellForRowAtIndexPath");
	UITableViewCell * cell= [self.tableCells objectAtIndex:indexPath.row];
	cell.detailTextLabel.text=[self.sectionStatus objectAtIndex:indexPath.row];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"numberOfRowsInSection");
	return [self.tableCells count];
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
	[sections release];
	[tableView release];
	[cancelButton release];
	[tableCells release];
	[sectionStatus release];
    [super dealloc];
}


@end
