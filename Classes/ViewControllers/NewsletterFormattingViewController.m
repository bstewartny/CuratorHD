#import "NewsletterFormattingViewController.h"
#import "Newsletter.h"
#import "ColorPickerViewController.h"
#import "FontPickerViewController.h"
#import "CustomCellBackgroundView.h"
#import "NewsletterItemContentView.h"
#define kSectionTitle 0
#define kSectionSectionHeadings 1
#define kSectionSummary 2
#define kSectionArticleTitles 3
#define kSectionBodyText 4
#define kSectionComments 5
#import "Font.h"

@implementation NewsletterFormattingViewController
@synthesize tableView,delegate,newsletter;

- (NSString*) titleForSection:(NSInteger)section
{
	switch (section) {
		case kSectionTitle:
			return @"Title";
		case kSectionSectionHeadings:
			return @"Section Headings";
		case kSectionSummary:
			return @"Summaries";
		case kSectionArticleTitles:
			return @"Headlines";
		case kSectionBodyText:
			return @"Body Text";
		case kSectionComments:
			return @"Comments";
	}
}

- (Font*) fontForSection:(NSInteger)section
{
	switch (section) {
		case kSectionTitle:
			return self.newsletter.titleFont;
		case kSectionSectionHeadings:
			return self.newsletter.sectionFont;
		case kSectionSummary:
			return self.newsletter.summaryFont;
		
		case kSectionArticleTitles:
			return self.newsletter.headlineFont;
		case kSectionBodyText:
			return self.newsletter.bodyFont;
		
		case kSectionComments:
			return self.newsletter.commentsFont;
	}
}

- (void) viewDidLoad
{
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];

	self.tableView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
	[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[UIView new] autorelease]] autorelease]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	cell.backgroundColor=[UIColor clearColor];

	CustomCellBackgroundView * gbView=[[[CustomCellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
	
	cell.backgroundView=gbView;
	
	gbView.fillColor=[UIColor blackColor]; 
	gbView.borderColor=[UIColor grayColor];
	
	cell.backgroundView.alpha=0.5;
	
	cell.textLabel.textColor=[UIColor whiteColor];
	
	cell.detailTextLabel.textColor=[NewsletterItemContentView colorWithHexString:@"73A2ED"];
	
	if(indexPath.row==0)
	{
		[cell.backgroundView setPosition:CustomCellBackgroundViewPositionSingle];
		
		cell.textLabel.text=@"Font Style";
		
		Font * font=[self fontForSection:indexPath.section];
		
		cell.detailTextLabel.text=font.family;
		
		
		//cell.detailTextLabel.text=[self fontForSection:indexPath.section];
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
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
	label.text=[self titleForSection:section];
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
	FontPickerViewController * fontPicker=[[FontPickerViewController alloc] initWithFont:[self fontForSection:indexPath.section]];
	fontPicker.sectionName=[self titleForSection:indexPath.section];
	fontPicker.delegate=self;
	[self.navigationController pushViewController:fontPicker animated:YES];
	[fontPicker release];
}

- (void) renderNewsletter
{
	[delegate renderNewsletter];
}

- (void) fontPicker:(FontPickerViewController *)fontPicker pickedFont:(Font *)font
{
	NSLog(@"fontPicker:pickedFont: saving newsletter and then rendering");
	[self.newsletter save];
	[delegate renderNewsletter];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[tableView reloadData];
}

- (void)dealloc 
{
	[tableView release];
	[newsletter release];
    [super dealloc];
}


@end
