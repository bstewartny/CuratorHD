#import "NewsletterFormattingViewController.h"
#import "Newsletter.h"
#import "ColorPickerViewController.h"
#import "FontPickerViewController.h"
#import "CustomCellBackgroundView.h"
#import "NewsletterItemContentView.h"
#define kSectionTitle 0
#define kSectionIntroAndComments 1
#define kSectionSectionHeadings 2
#define kSectionArticleTitles 3
#define kSectionBodyText 4

@implementation NewsletterFormattingViewController
@synthesize tableView,delegate,newsletter;

- (NSString*) titleForSection:(NSInteger)section
{
	switch (section) {
		case kSectionTitle:
			return @"Title";
		case kSectionIntroAndComments:
			return @"Summary & Comments";
		case kSectionSectionHeadings:
			return @"Section Headings";
		case kSectionArticleTitles:
			return @"Headlines";
		case kSectionBodyText:
			return @"Body Text";
	}
}

- (NSString*) fontSizeForSection:(NSInteger)section
{
	switch (section) {
		case kSectionTitle:
			return self.newsletter.titleSize;
		case kSectionIntroAndComments:
			return self.newsletter.commentsSize;
		case kSectionSectionHeadings:
			return self.newsletter.sectionSize;
		case kSectionArticleTitles:
			return self.newsletter.headlineSize;
		case kSectionBodyText:
			return self.newsletter.bodySize;
	}
}
- (NSString*) fontForSection:(NSInteger)section
{
	switch (section) {
		case kSectionTitle:
			return self.newsletter.titleFont;
		case kSectionIntroAndComments:
			return self.newsletter.commentsFont;
		case kSectionSectionHeadings:
			return self.newsletter.sectionFont;
		case kSectionArticleTitles:
			return self.newsletter.headlineFont;
		case kSectionBodyText:
			return self.newsletter.bodyFont;
	}
}

- (NSString*) colorForSection:(NSInteger)section
{
	switch (section) {
		case kSectionTitle:
			return self.newsletter.titleColor;
		case kSectionIntroAndComments:
			return self.newsletter.commentsColor;
		case kSectionSectionHeadings:
			return self.newsletter.sectionColor;
		case kSectionArticleTitles:
			return self.newsletter.headlineColor;
		case kSectionBodyText:
			return self.newsletter.bodyColor;
	}
}

- (void) setColorForSection:(NSInteger)section color:(NSString*)color
{
	switch (section) {
		case kSectionTitle:
			self.newsletter.titleColor=color;
			break;
		case kSectionIntroAndComments:
			self.newsletter.commentsColor=color;
			break;
		case kSectionSectionHeadings:
			self.newsletter.sectionColor=color;
			break;
		case kSectionArticleTitles:
			self.newsletter.headlineColor=color;
			break;
		case kSectionBodyText:
			self.newsletter.bodyColor=color;
			break;
	}
	[self.newsletter save];
	[delegate renderNewsletter];
}

- (void) setFontForSection:(NSInteger)section font:(NSString*)font
{
	switch (section) {
		case kSectionTitle:
			self.newsletter.titleFont=font;
			break;
		case kSectionIntroAndComments:
			self.newsletter.commentsFont=font;
			break;
		case kSectionSectionHeadings:
			self.newsletter.sectionFont=font;
			break;
		case kSectionArticleTitles:
			self.newsletter.headlineFont=font;
			break;
		case kSectionBodyText:
			self.newsletter.bodyFont=font;
			break;
	}
	[self.newsletter save];
	[delegate renderNewsletter];
}

- (void) setFontSizeForSection:(NSInteger)section fontSize:(NSString*)fontSize
{
	switch (section) {
		case kSectionTitle:
			self.newsletter.titleSize=fontSize;
			break;
		case kSectionIntroAndComments:
			self.newsletter.commentsSize=fontSize;
			break;
		case kSectionSectionHeadings:
			self.newsletter.sectionSize=fontSize;
			break;
		case kSectionArticleTitles:
			self.newsletter.headlineSize=fontSize;
			break;
		case kSectionBodyText:
			self.newsletter.bodySize=fontSize;
			break;
	}
	[self.newsletter save];
	[delegate renderNewsletter];
}

- (void) viewDidLoad
{
	//self.navigationItem.title=@"Formatting";
	
	
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
		[cell.backgroundView setPosition:CustomCellBackgroundViewPositionTop];
		cell.textLabel.text=@"Font";
		cell.detailTextLabel.text=[self fontForSection:indexPath.section];
	}
	else 
	{
		[cell.backgroundView setPosition:CustomCellBackgroundViewPositionBottom];
		cell.textLabel.text=@"Color";
		cell.detailTextLabel.text=[self colorForSection:indexPath.section];
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
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
	//CGRect rect=[aTableView rectForRowAtIndexPath:indexPath];
	
	if(indexPath.row==0)
	{
		// show font picker
		// show color picker
		FontPickerViewController * fontPicker=[[FontPickerViewController alloc] initWithNibName:@"NewsletterFormattingView" bundle:nil];
		
		NSArray * fontNames=[NSArray arrayWithObjects:@"Helvetica",@"Trebuchet MS",@"Times New Roman",@"Courier",@"Georgia",nil];
		
		NSMutableArray * fonts=[[[NSMutableArray alloc] init]autorelease];
		
		for(NSString * fontName in fontNames)
		{
			[fonts addObject:[UIFont fontWithName:fontName size:18]];
		}
		fontPicker.fonts=fonts;
		fontPicker.fontNames=fontNames;
		fontPicker.fontSizeNames=[NSArray arrayWithObjects:@"Smaller",@"Small",@"Medium",@"Large",@"Larger",nil];
		fontPicker.fontSizes=[NSArray arrayWithObjects:@"x-small",@"small",@"medium",@"large",@"x-large",nil];
		fontPicker.fontSize=[self fontSizeForSection:indexPath.section];
		
		fontPicker.fontName=[self fontForSection:indexPath.section];
		fontPicker.fontTitle=[self titleForSection:indexPath.section];
		
		fontPicker.delegate=self;
		fontPicker.tag=indexPath.section;
		
		[self.navigationController pushViewController:fontPicker animated:YES];
		
		[fontPicker release];
			
	}
	if(indexPath.row==1)
	{
		// show color picker
		ColorPickerViewController * colorPicker=[[ColorPickerViewController alloc] initWithNibName:@"NewsletterFormattingView" bundle:nil];
		
		colorPicker.colorName=[self colorForSection:indexPath.section];
		colorPicker.colorTitle=[self titleForSection:indexPath.section];
		//colorPicker.colors=[NSArray arrayWithObjects:[UIColor redColor],[UIColor blueColor],[UIColor greenColor],nil];
		//colorPicker.colorNames=[NSArray arrayWithObjects:@"Red",@"Blue",@"Green",nil];
		
		colorPicker.delegate=self;
		colorPicker.tag=indexPath.section;
		
		[self.navigationController pushViewController:colorPicker animated:YES];
		
		[colorPicker release];
	
	}
}

- (void) renderNewsletter
{
	[delegate renderNewsletter];
}

- (void) fontPicker:(FontPickerViewController *)fontPicker pickedFontSize:(NSString *)fontSize
{
	[self setFontSizeForSection:fontPicker.tag fontSize:fontSize];
	//[delegate renderNewsletter];
}

- (void) fontPicker:(FontPickerViewController *)fontPicker pickedFontStyle:(NSString *)fontStyle
{
	//[self setFontSizeForSection:fontPicker.tag fontSize:fontSize];
	//[delegate renderNewsletter];
}
- (void) fontPicker:(FontPickerViewController*)fontPicker pickedFont:(UIFont*)font withName:(NSString*)name
{
	[self setFontForSection:fontPicker.tag font:name];
	//[delegate renderNewsletter];
}

- (void) colorPicker:(ColorPickerViewController*)colorPicker pickedColor:(UIColor*)color withName:(NSString*)name
{
	[self setColorForSection:colorPicker.tag color:name];
	//[delegate renderNewsletter];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[tableView release];
	[newsletter release];
    [super dealloc];
}


@end
