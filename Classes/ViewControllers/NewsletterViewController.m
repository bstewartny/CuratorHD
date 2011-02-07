#import "NewsletterViewController.h"
#import "FeedItem.h"
#import "Newsletter.h"
#import "NewsletterHTMLPreviewViewController.h"
#import "AppDelegate.h"
#import "NewsletterSection.h"
#import "Feed.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterItemContentView.h"
#import "BlankToolbar.h"
#import "ActivityStatusViewController.h"
#import "ImageResizer.h"
#import "ItemFilter.h"
#import "GradientButton.h"
#import "DocumentEditFormViewController.h"
#import "AccountSettingsFormViewController.h"
#import "UserSettings.h"
#import "FeedsViewController.h"
#import "FeedItemDictionary.h"
#import "NewsletterItem.h"
#import "NewsletterHTMLRenderer.h"
#import "BadgedTableViewCell.h"
#import "FormViewController.h"

#define kEditSectionTag 1001
#define kAddSectionTag 1002

@implementation NewsletterViewController
@synthesize newsletterTableView,navPopoverController,editActionToolbar,editMoveButton,addImageButton,addSectionPopover,imagePickerPopover,updateFormViewController,activityStatusViewController,activityIndicatorView,activityView,activityTitleLabel,activityStatusLabel,activityProgressView;

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	// finished changing newsletter title
	if([textField.text length]>0)
	{
		self.newsletter.name=textField.text;
		self.title=self.newsletter.name;
	
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"ReloadData"
		 object:nil];
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	textView.textColor=[UIColor blackColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	// finished changing newsletter title
	
	if([textView.text hasPrefix:@"Tap here to enter newsletter summary"])
	{
		return;
	}
	else 
	{
		self.newsletter.summary=textView.text;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void) actionTouch:(id)sender
{
	if(addSectionPopover!=nil)
	{
		[addSectionPopover dismissPopoverAnimated:YES];
	}
	
	UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Publish Newsletter",@"Show Preview",nil	];
	actionSheet.tag=kPublishPreviewActionSheet;
	[actionSheet showFromBarButtonItem:sender animated:YES];
	[actionSheet release];
}

- (void)viewDidLoad
{
	// set header collapsed by default...
	//newsletterTableView.frame=CGRectMake(0, 32, newsletterTableView.frame.size.width, self.view.bounds.size.height-32); //newsletterTableView.frame.size.height);
	//[self.view bringSubviewToFront:newsletterTableView];
	self.newsletterTableView.allowsSelectionDuringEditing=YES;
	
	selectedIndexPaths=[[NSMutableArray alloc] init];
	
	viewMode=kViewModeHeadlines;
	
	UISegmentedControl * segmentedControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Sections",@"Headlines",@"Synopsis",nil]];
	
	segmentedControl.segmentedControlStyle=UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex=viewMode;
	[segmentedControl addTarget:self
						 action:@selector(toggleViewMode:)
			   forControlEvents:UIControlEventValueChanged];
	[segmentedControl sizeToFit];
	segmentedControl.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	
	self.navigationItem.titleView=segmentedControl;
	
	[segmentedControl release];
	
	// create a toolbar to have two buttons in the right
	BlankToolbar* tools = [[BlankToolbar alloc] initWithFrame:CGRectMake(0, 0, 250, 44.01)];
	
	tools.backgroundColor=[UIColor clearColor];
	tools.opaque=NO;
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
	// create a standard "action" button
	UIBarButtonItem* bi;
	
	// create a spacer to push items to the right
	bi= [[UIBarButtonItem alloc]
						   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
	[bi release];
	
	/*bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTouch:)];
	*/
	
	bi = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStyleDone target:self action:@selector(preview:)];
	[buttons addObject:bi];
	actionButton=bi;

	[bi release];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width=30;
	
	[buttons addObject:bi];
	[bi release];
	 
	// create a standard "edit" button
	bi = [[UIBarButtonItem alloc] init];
	bi.title=@"Edit";
	bi.target=self;
	bi.action=@selector(toggleEditPage:) ;
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	[bi release];

	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	
	[buttons release];
	
	// and put the toolbar in the nav bar
	
	UIBarButtonItem * rightView=[[UIBarButtonItem alloc] initWithCustomView:tools];
	
	self.navigationItem.rightBarButtonItem = rightView;
	
	[rightView release];
	
	[tools release];
	
	UIToolbar * editToolbar=[[UIToolbar alloc] initWithFrame:CGRectMake((self.view.bounds.size.width/2) - (380/2), -45, 380, 45)];
	
	// set color to black, set height bigger?
	editToolbar.autoresizingMask= UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	editToolbar.barStyle=UIBarStyleBlack;
	editToolbar.translucent=YES;
	
	buttons=[[NSMutableArray alloc] init];
	
	GradientButton * deleteButton=[[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
	
	[deleteButton setTitle:@"Delete (0)" forState:UIControlStateNormal];
	
	[deleteButton addTarget:self action:@selector(editActionDelete:) forControlEvents:UIControlEventTouchUpInside];
	
	[deleteButton useRedDeleteStyle];
	
	bi=[[UIBarButtonItem alloc] initWithCustomView:deleteButton];
	
	[buttons addObject:bi];
	[deleteButton release];
	[bi release];
	
	// create a spacer to push items to the right
	bi= [[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
	[bi release];
	
	GradientButton * keepButton=[[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
	
	[keepButton setTitle:@"Keep (0)" forState:UIControlStateNormal];
	
	[keepButton addTarget:self action:@selector(editActionKeep:) forControlEvents:UIControlEventTouchUpInside];
	
	[keepButton useRedDeleteStyle];
	
	bi=[[UIBarButtonItem alloc] initWithCustomView:keepButton];
	
	[buttons addObject:bi];
	[bi release];
	[keepButton release];
	
	// stick the buttons in the toolbar
	[editToolbar setItems:buttons animated:NO];
	
	[buttons release];
	
	self.editActionToolbar=editToolbar;
	
	[editToolbar release];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotification:)
	 name:@"ReloadActionData"
	 object:nil];
}

-(void)handleNotification:(NSNotification *)pNotification
{
	if([pNotification.name isEqualToString:@"ReloadActionData"])
	{
		[newsletterTableView reloadData];
	}
}

-(void) toggleViewMode:(id)sender
{
	if(addSectionPopover!=nil)
	{
		[addSectionPopover dismissPopoverAnimated:YES];
	}
	
	viewMode=[sender selectedSegmentIndex];
	
	[newsletterTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[newsletterTableView reloadData];

	[super viewWillAppear:animated];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// did user send email? if so mark last published date of newsletter to now...
	
	if(result==MFMailComposeResultSent)
	{
		self.newsletter.lastPublished=[NSDate date]; // not sure if we need to convert timezone here...
		
		// if user setting is to clear newsletter after publish, then clear the newsletter of all items...
		if([[[UIApplication sharedApplication] delegate] clearOnPublish])
		{
			[self.newsletter clearAllItems];
			
			[self.newsletterTableView reloadData];
		}
		[self.newsletter save];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) publish
{
	// start publishing

	if(!updating)
	{
		updating=YES;
	
		if([newsletter needsUploadImages])
		{
			// do asyn upload
			[self startActivityView];
		
			// update all the saved searches associated with this page...
			[self performSelectorInBackground:@selector(publishStart) withObject:nil];
		}
		else 
		{
			[self publishEnd];
		}
	}
}

- (void) publishStart
{
	// upload images if required
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[activityTitleLabel performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:NO];
	[activityStatusLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Uploading images..." waitUntilDone:NO];
	
	[self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:0.5] waitUntilDone:NO];
	
	[newsletter uploadImages];
	
	[self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
	
	[pool drain];
	app.networkActivityIndicatorVisible = NO;
	[self performSelectorOnMainThread:@selector(publishEnd) withObject:nil waitUntilDone:NO];
}

- (void) publishEnd
{
	[self endActivityView];
	
	updating=NO;
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	// show email client
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
	picker.mailComposeDelegate = self; // <- very important step if you want feedbacks on what the user did with your email sheet
	
	[picker setSubject:newsletter.name];
		
	// Fill out the email body text
	int maxSynopsisSize=[[[UIApplication sharedApplication] delegate] maxNewsletterSynopsisLength];
	
	NewsletterHTMLRenderer * renderer=[[[NewsletterHTMLRenderer alloc] initWithTemplateName:[[[UIApplication sharedApplication] delegate] newsletterTemplateName] maxSynopsisSize:maxSynopsisSize embedImageData:NO] autorelease];
	
	NSString   *emailBody= [renderer getHTML:self.newsletter];
	
	
	[picker setMessageBody:emailBody isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
	
	picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
	
	[self presentModalViewController:picker animated:YES];
	
	[picker release];
}
- (void) preview:(id)sender
{
	NewsletterHTMLPreviewViewController * previewController=[[NewsletterHTMLPreviewViewController alloc] initWithNibName:@"NewsletterHTMLPreviewView" bundle:nil];
	
	previewController.newsletter=self.newsletter;
	
	[self.navigationController pushViewController:previewController animated:NO];
	
	[previewController release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag==kPublishPreviewActionSheet) 
	{
		if(buttonIndex==0)
		{
			// publish - generate email...
			[self publish];
			
		}
		if(buttonIndex==1)
		{
			[self preview];
		}
	}
	 
	if(actionSheet.tag==kEditLogoImageActionSheet)
	{
		if(buttonIndex==0)
		{
			// choose existing image
			[self addImageTouch:self.addImageButton];
		}
		
		if(buttonIndex==1)
		{
			// delete image
			self.newsletter.logoImage=nil;
	
			[self.newsletter save];
			
			[self.newsletterTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]     withRowAnimation:UITableViewRowAnimationNone];
		}
	}
}

- (void) deleteSelectedRows
{
	NSArray* selectedRows = selectedIndexPaths; 
	
	[self deleteSelectedRowsUsingIndexPaths:selectedRows];
}

- (void) deleteSelectedRowsUsingIndexPaths:(NSArray*)selectedRows
{
	if (selectedRows && [selectedRows count]>0) 
	{
		if(viewMode==kViewModeSections)
		{
			NSArray * sections=[self.newsletter sortedSections];
			
			for(NSIndexPath * indexPath in selectedRows)
			{
				[[sections objectAtIndex:indexPath.row] delete];
			}
			
			[self.newsletter save];
		}
		else
		{
			// delete items
			
			// make sure its grouped by section...
			NSArray * sortedSelections=selectedRows; 
			
			NSArray * sections=[self.newsletter sortedSections];
			
			NSArray * sectionItems=nil;
			
			int prev_section=-1;
			
			for (NSIndexPath * indexPath in sortedSelections)
			{
				if(indexPath.section != prev_section)
				{
					sectionItems=[[sections objectAtIndex:indexPath.section-1] sortedItems];
					
					prev_section=indexPath.section;
				}
				
				[[sectionItems objectAtIndex:indexPath.row] delete];
			}
			
			[self.newsletter save];
		}
			
		[self.newsletterTableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void) deleteNonSelectedRows
{
	NSArray* selectedRows = selectedIndexPaths;  
	
	// get all non-selected rows...
	NSMutableArray * nonSelectedRows=[[NSMutableArray alloc] init];
	
	int section_number=0;
	
	if(viewMode==kViewModeSections)
	{
		int row_number=0;
		for(NewsletterSection * section in [self.newsletter sortedSections])
		{
			NSIndexPath * indexPath=[NSIndexPath indexPathForRow:row_number inSection:section_number+1];
			
			BOOL found=NO;
			
			// make sure not in selected rows...
			for(int i=0;i<[selectedRows count];i++)
			{
				NSIndexPath * path=[selectedRows objectAtIndex:i];
				if(path.section==indexPath.section && path.row==indexPath.row)
				{
					found=YES;
					break;
				}
			}
			
			if(!found)
			{
				[nonSelectedRows addObject:indexPath];
			}	
			row_number++;
		}
	}
	else 
	{
		// get all rows
		for(NewsletterSection * section in [self.newsletter sortedSections])
		{
			int row_number=0;
			for(FeedItem * item in [section sortedItems])
			{
				NSIndexPath * indexPath=[NSIndexPath indexPathForRow:row_number inSection:section_number+1];
				
				BOOL found=NO;
				
				// make sure not in selected rows...
				for(int i=0;i<[selectedRows count];i++)
				{
					NSIndexPath * path=[selectedRows objectAtIndex:i];
					if(path.section==indexPath.section && path.row==indexPath.row)
					{
						found=YES;
						break;
					}
				}
				
				if(!found)
				{
					[nonSelectedRows addObject:indexPath];
				}
				
				row_number++;
			}
			section_number++;
		}
	}
	
	[self deleteSelectedRowsUsingIndexPaths:nonSelectedRows];
	
	[nonSelectedRows release];
}

- (void)renderNewsletter
{
	[newsletterTableView reloadData];
}

- (void) updateProgress:(NSNumber*) progress
{
	activityProgressView.progress=[progress floatValue];
}

-(void) setViewMode:(int)mode
{
	viewMode=mode;
}

- (void) editActionDelete:(id)sender
{
	[self deleteSelectedRows];
	
	[selectedIndexPaths removeAllObjects];
	
	[self setNumRowsSelected:0];
	
	[self.newsletterTableView reloadData];
}

-(void) editActionKeep:(id)sender
{
	[self deleteNonSelectedRows];
	
	// remove selected checkmark from rows (deselect rows)
	[selectedIndexPaths removeAllObjects];
	
	[self setNumRowsSelected:0];
	
	[self.newsletterTableView reloadData];
}

- (IBAction) toggleEditPage:(id)sender
{
	UIBarButtonItem * buttonItem=(UIBarButtonItem*)sender;
	
	if(self.newsletterTableView.editing)
	{
		// hide action toolbar if not nil
		
		[selectedIndexPaths removeAllObjects];
		
		[self.newsletterTableView setEditing:NO animated:YES];
		
		buttonItem.style=UIBarButtonItemStyleBordered;
		buttonItem.title=@"Edit";
		
		CGRect toolbarFrame = editActionToolbar.frame;
		
		toolbarFrame.origin.y=-toolbarFrame.size.height;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		
		editActionToolbar.frame=toolbarFrame;
		 
		[UIView commitAnimations];
		
		[editActionToolbar removeFromSuperview];
		
		[addButton setEnabled:YES];
		[actionButton setEnabled:YES];
		[refreshButton setEnabled:YES];
		
		[self.navigationItem.titleView setEnabled:YES];
		
		[self.newsletterTableView reloadData];
	}
	else
	{
		[selectedIndexPaths removeAllObjects];
		
		[self.newsletterTableView setEditing:YES animated:YES];
		
		[self.newsletterTableView reloadData];
		
		buttonItem.style=UIBarButtonItemStyleDone;
		buttonItem.title=@"Done";
		
		[self setNumRowsSelected:0];
		
		[addButton setEnabled:NO];
		[actionButton setEnabled:NO];
		[refreshButton setEnabled:NO];
		
		[self.navigationItem.titleView setEnabled:NO];
		
		if(viewMode==kViewModeHeadlines || viewMode==kViewModeSynopsis)
		{
			self.editActionToolbar.frame=CGRectMake((self.view.bounds.size.width/2) - (380/2), -45, 380, 45);
			
			[self.view addSubview:self.editActionToolbar];	
		
			[self.view bringSubviewToFront:self.editActionToolbar];
			
			CGRect toolbarFrame = editActionToolbar.frame;
			
			toolbarFrame.origin.y=0;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationBeginsFromCurrentState:YES];
			
			editActionToolbar.frame=toolbarFrame;
		
			[UIView commitAnimations];
		}
	}
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(!updating)
	{
		[self.newsletterTableView reloadData];
	}
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{   
	if(updating) return NO;
	[self.view setNeedsDisplay];
	return YES;
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath 
{
	if(indexPath.section==0) return NO;
	
	if(tableView.editing) 
	{
		return YES;
	}
	else
	{
		if(viewMode==kViewModeSections)
		{
			return (indexPath.row >= [self.newsletter.sections count]);
		}
		else 
		{
			if (indexPath.section > [self.newsletter.sections count]) 
			{
				return NO;
			}
			
			NewsletterSection * section=[self sectionForSectionIndex:indexPath.section]; //   [[self.newsletter sortedSections] objectAtIndex:indexPath.section];
			
			return (indexPath.row >= [section.items count]);
		}
	}
} 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
	// default is 2 - one for newsletter header, and one for "add new section"
    if(viewMode==kViewModeSections)
	{
		return 2;
	}
	else
	{
		if(self.newsletter)
		{
			return [self.newsletter.sections count]+2;
		}
		else
		{
			return 2;
		}
	}
}	

- (void) setNumRowsSelected:(int)numSelected
{
	UIBarButtonItem * deleteButton=[self.editActionToolbar.items objectAtIndex:0];
	UIBarButtonItem * keepButton=[self.editActionToolbar.items objectAtIndex:2];
	
	UIButton * customDeleteButton=[deleteButton customView];
	UIButton * customKeepButton=[keepButton customView];
	
	[customDeleteButton setTitle:[NSString stringWithFormat:@"Delete (%d)",numSelected] forState:UIControlStateNormal];
	[customKeepButton setTitle:[NSString stringWithFormat:@"Keep (%d)",numSelected] forState:UIControlStateNormal];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(section==0)
	{
		return @"Tap to edit header title and description";
	}
	else 
	{
		if(viewMode!=kViewModeSections)
		{
			if(section<=[self.newsletter.sections count])
			{
				NewsletterSection * newsletterSection=[self sectionForSectionIndex:section];
			
				if([newsletterSection.items count]==0)
				{
					return @"No items in this section. Add items from sources or folders.";
				}
			}
		}

		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section==0)
	{
		return @"Newsletter Header";
	}
	
	if(viewMode==kViewModeSections)
	{
		return @"Sections";
	}
	
	if(section<=[self.newsletter.sections count])
	{
		NewsletterSection * newsletterSection=[self sectionForSectionIndex:section]; //   [[self.newsletter sortedSections] objectAtIndex:section];
		return newsletterSection.name;
	}
	else 
	{
		return nil;
		//return @"Add new section...";
	}
}

- (void) formViewDidCancel:(NSInteger)tag
{
	
}

- (void) formViewDidFinish:(NSInteger)tag withValues:(NSArray*)values
{
	if(tag==kEditSectionTag)
	{
		NSString * sectionName=[values objectAtIndex:0];
		NSString * sectionDesc=[values objectAtIndex:1];
		
		if([sectionName length]>0)
		{
			tmpEditSection.name=sectionName;
			tmpEditSection.summary=sectionDesc;
			[tmpEditSection save];
			
			[self.newsletterTableView reloadData];
			
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadData"
			 object:nil];
		}
		return;
	}
	
	if(tag==kAddSectionTag)
	{
		NSString * sectionName=[values objectAtIndex:0];
		NSString * sectionDesc=[values objectAtIndex:1];
		
		if([sectionName length]>0)
		{
			NewsletterSection * newSection=[self.newsletter addSection];
			
			newSection.name=sectionName;
			newSection.summary=sectionDesc;
			
			[self.newsletter save];
			
			[self.newsletterTableView reloadData];
			
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:@"ReloadData"
			 object:nil];
		}
	}
}

- (void) addSection:(id)sender
{
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Add section" tag:kAddSectionTag delegate:self names:[NSArray arrayWithObjects:@"Section name",@"text:Description",nil] andValues:nil];
	
	[self presentModalViewController:formView animated:YES];
	
	[formView release];
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
    UIFont *font;
    if (bold) 
        font = [UIFont boldSystemFontOfSize:fontSize];
    else 
        font = [UIFont systemFontOfSize:fontSize];
    
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
	if(section==0)
	{
		return 1; //newsletter header
	}
	
	if(viewMode==kViewModeSections)
	{
		return [self.newsletter.sections count]+1; // add one to add new section
	}
	else
	{
		if(section > [self.newsletter.sections count])
		{
			return 1; // now rows in add new section section
		}
		
		NewsletterSection * newsletterSection=[self sectionForSectionIndex:section];
		
		return [newsletterSection.items count];//+1; // add one to insert items in that section
	}
}

- (NewsletterSection *)sectionForSectionIndex:(NSInteger)section
{
	// subtract 1 for newsletter header...
	return [[self.newsletter sortedSections] objectAtIndex:section-1];
}

- (void) setWidth:(id)obj width:(CGFloat)width
{
	CGRect rect=[obj frame];
	CGSize size=rect.size;
	size.width=width;
	rect.size=size;
	[obj setFrame:rect];
}

- (UITableViewCell *)tableView:(UITableView *)tableView sectionCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *SectionCellIdentifier = @"sectionCellIdentifier";
	
	BadgedTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:SectionCellIdentifier];
	
	if(cell==nil)
	{
		cell = [[[BadgedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:SectionCellIdentifier] autorelease];
	}
	
	UIColor * nameColor=[UIColor blackColor];
	
	if(indexPath.row >= [newsletter.sections count])
	{
		cell.textLabel.textColor=[UIColor lightGrayColor];
		cell.textLabel.text=@"Tap here to add a new section";
		cell.accessoryView=nil;
		cell.accessoryType=UITableViewCellAccessoryNone;
		cell.editingAccessoryType=UITableViewCellAccessoryNone;
	}
	else
	{
		NewsletterSection * newsletterSection=[[self.newsletter sortedSections] objectAtIndex:indexPath.row];
		cell.textLabel.textColor=nameColor;
		cell.textLabel.text=newsletterSection.name;
		cell.detailTextLabel.text=newsletterSection.summary;
		cell.badgeString=[NSString stringWithFormat:@"%d",[newsletterSection.items count]];
	}
	
	return cell;
}

- (UITableViewCell*)addButtonTableViewCell:(NSString*)text
{
	UITableViewCell* cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	cell.textLabel.textColor=[UIColor lightGrayColor];
	cell.textLabel.text=text;
	cell.editingAccessoryType=UITableViewCellAccessoryNone;
	cell.accessoryView=nil;
	cell.accessoryType=UITableViewCellAccessoryNone;
	return cell;
}

- (UITableViewCell *)addSectionTableViewCell 
{
	return [self addButtonTableViewCell:@"Tap here to add a new section"];
}
/*
- (UITableViewCell *) addItemsToSectionTableViewCell
{
	return [self addButtonTableViewCell:@"Tap here to add selected items to this section"];
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView headlineItemCellForSection:(NewsletterSection*)section row:(NSInteger)row
{
	static NSString *CellIdentifier = @"headlineItemCellIdentifier";
	
	UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	if(tableView.editing)
	{
		cell.selectionStyle=3;//UITableViewCellSelectionStyleGray;
	}
	else	
	{
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
	}
	
	FeedItem * item=(FeedItem *)[[section sortedItems] objectAtIndex:row];
	
	cell.textLabel.text=item.headline;
	cell.detailTextLabel.text=item.synopsis;
	cell.imageView.image=item.image;
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView folderItemCellForSection:(NewsletterSection*)section row:(NSInteger)row
{
	static NSString *CellIdentifier = @"folderItemCellIdentifier";
	
	CGFloat cellWidth=self.newsletterTableView.frame.size.width - 100;
	
	UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	if(tableView.editing)
	{
		cell.selectionStyle=3;//UITableViewCellSelectionStyleGray;
	}
	else	
	{
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
	}
	FeedItem * item=(FeedItem *)[[section sortedItems] objectAtIndex:row];
	
	UIImageView * imageView=[[UIImageView alloc] initWithImage:item.image];
	imageView.frame=CGRectMake(10,10,72,72);
	imageView.contentMode=UIViewContentModeScaleAspectFill;
	imageView.layer.cornerRadius=8;
	imageView.clipsToBounds=YES;
	
	[cell.contentView addSubview:imageView];
	[imageView release];
	
	UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(92, 10, cellWidth - 110, 20)];
	label.font=[UIFont boldSystemFontOfSize:16];
	label.textColor=[UIColor blackColor];
	label.backgroundColor=[UIColor clearColor];
	label.text=item.headline;
	
	[cell.contentView addSubview:imageView];
	[label release];
	
	label=[[UILabel alloc] initWithFrame:CGRectMake(92, 40, cellWidth - 110, 42)];
	label.font=[UIFont systemFontOfSize:14];
	
	label.textColor=[UIColor grayColor];
	label.backgroundColor=[UIColor clearColor];
	label.text=item.synopsis;
	
	[cell.contentView addSubview:imageView];
	[label release];

	//cell.textLabel.text=item.headline;
	//cell.detailTextLabel.text=item.synopsis;
	//cell.imageView.image=item.image;
	
	return cell;
}





- (UITableViewCell *)tableView:(UITableView *)tableView synopsisItemCellForSection:(NewsletterSection*)section row:(NSInteger)row
{
	static NSString *CellIdentifier = @"synopsisItemCellIdentifier";
	
	UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.contentView.autoresizesSubviews=YES;
		NewsletterItemContentView * contentView=[[NewsletterItemContentView alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 4, 4)];
		
		// set view mode...
		contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		contentView.parentController=self;
		contentView.parentTableView=tableView;
		
		[cell.contentView addSubview:contentView];
		[contentView release];
		
		contentView.contentMode=UIViewContentModeRedraw;
	}
	
	if(tableView.editing)
	{
		cell.selectionStyle=3;//UITableViewCellSelectionStyleGray;
	}
	else	
	{
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
	}
	
	FeedItem * item=(FeedItem *)[[section sortedItems] objectAtIndex:row];
	
	NewsletterItemContentView * contentView=(NewsletterItemContentView *)[cell.contentView.subviews objectAtIndex:[cell.contentView.subviews count]-1];
	
	[contentView setViewMode:YES];
	contentView.item=item;
	[contentView setNeedsDisplay];
	[contentView setNeedsLayout];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView itemCellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.section > [self.newsletter.sections count])
	{
		return [self addSectionTableViewCell];
	}
	
	NewsletterSection * newsletterSection=[self sectionForSectionIndex:indexPath.section];
	
	/*if(indexPath.row == [newsletterSection.items count])
	{
		return [self addItemsToSectionTableViewCell];
	}*/
	
	if(viewMode==kViewModeHeadlines)
	{
		return [self tableView:tableView headlineItemCellForSection:newsletterSection row:indexPath.row];
	}
	else 
	{
		if(viewMode==kViewModeSynopsis)
		{
			return [self tableView:tableView synopsisItemCellForSection:newsletterSection row:indexPath.row];
		}
		else 
		{
			// this is an error... should not get here...
			return nil;
		}
	}
}

- (UITableViewCell*)newsletterHeaderCell
{
	UITableViewCell * cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	CGFloat cellWidth=self.newsletterTableView.frame.size.width;
	
	NSLog(@"newsletterTableView.frame=%@",NSStringFromCGRect(self.newsletterTableView.frame));
	
	cellWidth=cellWidth-110;

	// title text field
	UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(14, 10, cellWidth-2, 20)];
	textField.font=[UIFont boldSystemFontOfSize:16];
	textField.text=self.newsletter.name;
	textField.placeholder=@"Tap here to enter newsletter title";
	textField.delegate=self;
	textField.clearButtonMode=UITextFieldViewModeWhileEditing;
	textField.backgroundColor=[UIColor clearColor];
	
	[cell.contentView addSubview:textField];
	
	[textField release];
	
	// image button
	if(self.newsletter.logoImage)
	{
		CGRect newFrame=CGRectMake(10, 35,self.newsletter.logoImage.size.width,self.newsletter.logoImage.size.height);
		
		[self.addImageButton removeFromSuperview];
		
		self.addImageButton=[UIButton buttonWithType:UIButtonTypeCustom];
		
		self.addImageButton.frame=newFrame;
		
		[self.addImageButton setBackgroundImage:self.newsletter.logoImage forState:UIControlStateNormal];
		
		[self.addImageButton addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
		
		[cell.contentView addSubview:self.addImageButton];			
		
	}
	else 
	{
		CGRect newFrame=CGRectMake(10, 35, 88, 88);
		
		// replace old button...
		[self.addImageButton removeFromSuperview];
		
		self.addImageButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		
		[self.addImageButton setTitle:@"Add Image" forState:UIControlStateNormal];
		
		self.addImageButton.frame=newFrame;
		
		[self.addImageButton addTarget:self action:@selector(addImageTouch:) forControlEvents:UIControlEventTouchUpInside];
		
		[cell.contentView addSubview:self.addImageButton];
	}
	
	// description text view
	UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(12+self.addImageButton.frame.size.width+8, 35, cellWidth-(10+self.addImageButton.frame.size.width), 88)];
	//textView.layer.cornerRadius=6;
	///textView.layer.borderColor=[UIColor grayColor];
	//textView.layer.borderWidth=1;
	textView.text=self.newsletter.summary;
	textView.backgroundColor=[UIColor clearColor];
	
	if([textView.text length]==0)
	{
		textView.textColor=[UIColor lightGrayColor];
		textView.text=@"Tap here to enter newsletter summary.";
	}
	
	textView.delegate=self;
	
	[cell.contentView addSubview:textView];
	
	[textView release];
	
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.section==0)
	{
		return [self newsletterHeaderCell];
	}
	
	if(viewMode==kViewModeSections)
	{
		return [self tableView:tableView sectionCellForRowAtIndexPath:indexPath];
	}
	else 
	{
		return [self tableView:tableView itemCellForRowAtIndexPath:indexPath];
	}
}

- (BOOL) tableView:(UITableView*)tableView
canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section==0) return NO;
	
	if(viewMode==kViewModeSections)
	{
		if(indexPath.row < [newsletter.sections count])
		{
			return YES;
		}
		else 
		{
			return NO;
		}
	}
	else 
	{
		if(indexPath.section > [self.newsletter.sections count])
		{
			return NO;
		}
		
		NewsletterSection * newsletterSection=[self sectionForSectionIndex:indexPath.section]; 
		
		if(indexPath.row <[newsletterSection.items count])
		{
			return YES;
		}
		else 
		{
			return NO;
		}
	}
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section==0)
	{
		return 160;
	}
	
	if(viewMode==kViewModeSections)
	{
		return tableView.rowHeight;
	}
	else 
	{
		if(viewMode==kViewModeHeadlines)
		{
			return tableView.rowHeight;
		}
		else 
		{
			if(indexPath.section >[self.newsletter.sections count])
			{
				return tableView.rowHeight;
			}
			
			NewsletterSection * newsletterSection=[self sectionForSectionIndex:indexPath.section];
			
			if(indexPath.row < [newsletterSection.items count])
			{
				FeedItem * item=(FeedItem *)[[newsletterSection sortedItems] objectAtIndex:indexPath.row];
		
				ItemSize itemSize=[NewsletterItemContentView sizeForCell:item viewMode:(viewMode==kViewModeSynopsis) rect:CGRectZero];
		
				return itemSize.size.height;
			}
			else 
			{
				return tableView.rowHeight;
			}
		}
	}
}

- (void)tableView:(UITableView*)tableView 
moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
	  toIndexPath:(NSIndexPath*)toIndexPath
{
	NSUInteger fromRow=[fromIndexPath row];
	NSUInteger toRow=[toIndexPath row];
	
	if(viewMode==kViewModeSections)
	{
		[[self.newsletter feedFetcher] moveItemFromIndex:fromRow toIndex:toRow];
	}
	else
	{
		if(fromIndexPath.section != toIndexPath.section) return;
		
		if(fromIndexPath.section==0 || toIndexPath.section==0) return;
		
		if(fromIndexPath.section > [self.newsletter.sections count]) return;
		
		if(toIndexPath.section > [self.newsletter.sections count]) return;
		
		NewsletterSection * newsletterSection1=[self sectionForSectionIndex:fromIndexPath.section];
		
		[[newsletterSection1 itemFetcher] moveItemFromIndex:fromRow toIndex:toRow];
		
		// adjust selected items
		if([selectedIndexPaths count]>0)
		{
			BOOL moved_selected_item=NO;
			// is moved item in selected rows?
			int moved_selected_item_index=0;
			for (NSIndexPath * selected in selectedIndexPaths)
			{
				if(selected.section==fromIndexPath.section && selected.row==fromIndexPath.row)
				{
					// yes we moved a selected item
					moved_selected_item=YES;
					break;
				}
				moved_selected_item_index++;
			}
			
			if(moved_selected_item)
			{
				// remove it then re-add it...
				[selectedIndexPaths removeObjectAtIndex:moved_selected_item_index];
			}
			
			if(toIndexPath.row < fromIndexPath.row)
			{
				// we moved item up
				// increment row number for every selected item between the dest and source rows
				for(int i=0;i<[selectedIndexPaths count]; i++)
				{
					NSIndexPath * selected = [selectedIndexPaths objectAtIndex:i];
				
					if(selected.section==fromIndexPath.section && selected.section==toIndexPath.section)
					{
						if(selected.row >=toIndexPath.row && selected.row < fromIndexPath.row)
						{
							NSIndexPath * newIndexPath=[NSIndexPath indexPathForRow:selected.row+1 inSection:selected.section];
							[selectedIndexPaths removeObjectAtIndex:i];
							[selectedIndexPaths insertObject:newIndexPath atIndex:i];
						}
					}
				}
			}
			else 
			{
				// we moved item down
				// decrement row number for every selected item between the dest and source rows
				for(int i=0;i<[selectedIndexPaths count]; i++)
				{
					NSIndexPath * selected = [selectedIndexPaths objectAtIndex:i];
					
					if(selected.section==fromIndexPath.section && selected.section==toIndexPath.section)
					{
						if(selected.row <= toIndexPath.row && selected.row > fromIndexPath.row)
						{
							NSIndexPath * newIndexPath=[NSIndexPath indexPathForRow:selected.row-1 inSection:selected.section];
							
							[selectedIndexPaths removeObjectAtIndex:i];
							[selectedIndexPaths insertObject:newIndexPath atIndex:i];
						}
					}
				}
			}
			
			if(moved_selected_item)
			{
				[selectedIndexPaths addObject:toIndexPath];
			}
		}
	}
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void) tableView:(UITableView*)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section==0) return;
	
	if(viewMode==kViewModeSections)
	{
		if(indexPath.row >=[[self.newsletter sections] count])
		{
			// insert new section
			[self addSection:nil];
		}
		else 
		{
			// delete section
			[[[self.newsletter sortedSections] objectAtIndex:indexPath.row] delete];
			[self.newsletter save];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
	else 
	{
		if(indexPath.section > [self.newsletter.sections count])
		{
			[self addSection:nil];
			return;
		}
		
		NewsletterSection * section=[self sectionForSectionIndex:indexPath.section];  
		
		if (indexPath.row == [section.items count])
		{
			// insert items to section
			[self insertSelectedItemsToSection:section atIndexPath:indexPath inTableView:tableView];
		}
		else 
		{
			if (indexPath.row == [section.items count]+1)
			{
				// insert new section
				[self addSection:nil];
			}
			else 
			{
				// delete item
				[[[section sortedItems] objectAtIndex:indexPath.row] delete];
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			}
		}
	}
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"didSelectRowAtIndexPath");
	if(indexPath.section==0) return;
	
	if(tableView.editing && (viewMode!=kViewModeSections))
	{
		if(indexPath.section > [self.newsletter.sections count])
		{
			[self addSection:nil];
			return;
		}
		
		[selectedIndexPaths addObject:indexPath];
		// get total # of currently selected items...
		[self setNumRowsSelected:[selectedIndexPaths count]];
	}
	else 
	{
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		if(viewMode==kViewModeSections)
		{
			if(indexPath.row >= [self.newsletter.sections count])
			{
				[self addSection:nil];
			}
			else 
			{
				NewsletterSection * section=[[self.newsletter sortedSections] objectAtIndex:indexPath.row];
				[self editSection:section];
			}
		}
		else 
		{
			if(indexPath.section > [self.newsletter.sections count])
			{
				[self addSection:nil];
				return;
			}
			
			NewsletterSection * section=[self sectionForSectionIndex:indexPath.section];
			
			if(indexPath.row ==[section.items count])
			{
				[self insertSelectedItemsToSection:section atIndexPath:indexPath inTableView:tableView];
			}
			else 
			{
				[self editItemAtIndexPath:indexPath];
			}
		}
	}
}

- (FeedItem*) itemAtIndexPath:(NSIndexPath*)indexPath
{
	NewsletterSection * newsletterSection=[self sectionForSectionIndex:indexPath.section];
	
	FeedItem * item=(FeedItem *)[[newsletterSection sortedItems] objectAtIndex:indexPath.row];
	
	return item;
}

- (void) editItemAtIndexPath:(NSIndexPath*)indexPath
{
	[self editItem:[self itemAtIndexPath:indexPath]];
}

- (void) editItem:(FeedItem*)item
{
	DocumentEditFormViewController *controller = [[DocumentEditFormViewController alloc] initWithNibName:@"DocumentEditFormView" bundle:nil];
	
	controller.item=item;
	
	controller.delegate=self;
	
	[controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[controller setModalPresentationStyle:UIModalPresentationPageSheet];
	
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void) editSection:(NewsletterSection*)section
{
	[tmpEditSection release];
	tmpEditSection=[section retain];
	
	FormViewController * formView=[[FormViewController alloc] initWithTitle:@"Edit section" tag:kEditSectionTag delegate:self names:[NSArray arrayWithObjects:@"Section name",@"text:Description",nil] andValues:[NSArray arrayWithObjects:section.name,section.summary,nil]];
	
	[self presentModalViewController:formView animated:YES];
	
	[formView release];
}

- (void) insertSelectedItemsToSection:(NewsletterSection*)section atIndexPath:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{
	FeedItemDictionary * selectedItems=[[[UIApplication sharedApplication] delegate] selectedItems];
	
	if([selectedItems count]>0)
	{
		NSMutableArray * indexPaths=[NSMutableArray new];
		NSInteger newRow=indexPath.row;
		
		for(FeedItem * item in selectedItems.items)
		{
			[section addFeedItem:item];
			NSIndexPath * newIndexPath=[NSIndexPath indexPathForRow:newRow inSection:indexPath.section];
			newRow=newRow+1;
			[indexPaths addObject:newIndexPath];
		}
		[section save];
		
		if([indexPaths count]>0)
		{
			[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
		}
		[indexPaths release];
		
		[selectedItems removeAllItems];
		
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"ReloadData"
		 object:nil];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section==0) return;
	
	if(tableView.editing)
	{
		if(indexPath.section > [self.newsletter.sections count])
		{
			return;
		}
		
		for(int i=0;i<[selectedIndexPaths count];i++)
		{
			NSIndexPath * path=[selectedIndexPaths objectAtIndex:i];
			if(path.section==indexPath.section && path.row==indexPath.row)
			{
				[selectedIndexPaths removeObjectAtIndex:i];
				break;
			}
		}
		
		// get total # of currently selected items...
		[self setNumRowsSelected:[selectedIndexPaths count]];
	}
}

- (void) redraw
{
	[self.newsletterTableView reloadData];
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ReloadData"
	 object:nil];
}

- (void) redraw:(FeedItem*)item
{
	[self redraw];
}

-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {

	if(indexPath.section==0)
	{
		return UITableViewCellEditingStyleNone;
	}
	
	if(viewMode==kViewModeSections)
	{
		if(indexPath.row < [self.newsletter.sections count])
		{
			return UITableViewCellEditingStyleDelete;
		}
		else 
		{
			return UITableViewCellEditingStyleInsert;
		}
	}
	else
	{
		if(indexPath.section > [self.newsletter.sections count])
		{
			return UITableViewCellEditingStyleInsert;
		}
		
		NewsletterSection * section=[self sectionForSectionIndex:indexPath.section];
		
		if(indexPath.row < [section.items count])
		{
			return 3; // style value for multi-select delete checkboxes - not 100% if this is ok to use or not...
		}
		else 
		{
			return UITableViewCellEditingStyleInsert;
		}
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if(sourceIndexPath.section==0 || proposedDestinationIndexPath.section==0)
	{
		return sourceIndexPath;
	}
	
	// do NOT allow to move items between sections - it will complicated tracking moved selected items (see code inside moveRowAtIndexPath).
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
		// cant move item below the add items button...
		if(viewMode==kViewModeSections)
		{
			if(proposedDestinationIndexPath.row < [newsletter.sections count])
			{
				return proposedDestinationIndexPath;
			}
			else 
			{
				return sourceIndexPath;
			}	
		}
		else 
		{
			NewsletterSection * section=[self sectionForSectionIndex:sourceIndexPath.section];
			
			if(proposedDestinationIndexPath.row < [section.items count])
			{
				return proposedDestinationIndexPath;
			}
			else 
			{
				return sourceIndexPath;
			}
		}
	}
}

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc 
{
    barButtonItem.title = @"Sources";
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.navPopoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.navPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
{
}

- (void) scrollToSection:(NSString*)sectionName
{
	// get section by name
	int section_number=0;
	
	for(NewsletterSection * section in [self.newsletter sortedSections])
	{
		if([section.name isEqualToString:sectionName])
		{
			break;
		}
		section_number++;
	}
	
	NSIndexPath * indexPath=[NSIndexPath indexPathForRow:NSNotFound inSection:section_number];
	
	[self.newsletterTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)imageTouched:(id)sender
{
	UIView * button=(UIView*)sender;
	
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	actionSheet.tag=kEditLogoImageActionSheet;
	[actionSheet addButtonWithTitle:@"Choose Existing Image"];
	[actionSheet addButtonWithTitle:@"Delete Image"];
	[actionSheet showFromRect:button.frame inView:self.view animated:YES];
	
	[actionSheet release];
}

- (void) addImageTouch:(id)sender
{
	UIImagePickerController * picker=[[UIImagePickerController alloc] init];
	
	picker.allowsEditing = YES;
	
	picker.delegate=self;
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	else
	{
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
		{
			picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		}
		else
		{
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			}
			else 
			{
				[picker release];
				return;
			}
		}
	}
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
	
	self.imagePickerPopover=popover;
	
	UIView * button=(UIView*)sender;
	
	[popover presentPopoverFromRect:[button convertRect:button.frame toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	[picker release];
	
	[popover release];
}
 
- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
    // Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [imagePickerPopover dismissPopoverAnimated:YES];

	image=[ImageResizer resizeImageIfTooBig:image maxWidth:222.0 maxHeight:118.0];
	
	self.newsletter.logoImage=image;
	
	[self.newsletterTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]     withRowAnimation:UITableViewRowAnimationNone];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [imagePickerPopover dismissPopoverAnimated:YES];
}

- (void)startActivityView
{
	activityView = [[UIView alloc] initWithFrame:[[self view] bounds]];
	[activityView setBackgroundColor:[UIColor blackColor]];
	[activityView setAlpha:0.5];
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[[self view] addSubview:activityView];
	
	UIView * subView=[[UIView alloc] initWithFrame:CGRectMake(activityView.center.x-300/2, activityView.center.y-150/2, 300, 150)];
	
	[subView setBackgroundColor:[UIColor blackColor]];
	[subView setAlpha:2.10];
	
	[[subView layer] setCornerRadius:24.0f];
	[[subView layer] setMasksToBounds:YES];
	
	[activityView addSubview:subView];
	
	activityTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(110, 40, 180, 20)];
	activityStatusLabel=[[UILabel alloc] initWithFrame:CGRectMake(110, 65, 180, 20)];
	
	activityStatusLabel.textColor=[UIColor whiteColor];
	activityTitleLabel.textColor=[UIColor whiteColor];
	activityStatusLabel.backgroundColor=[UIColor clearColor];
	activityTitleLabel.backgroundColor=[UIColor clearColor];
	
	activityProgressView=[[UIProgressView alloc] initWithFrame:CGRectMake(110,95,180,20)];
	
	activityProgressView.backgroundColor=[UIColor clearColor];
	 
	activityStatusLabel.text=@"";
	activityTitleLabel.text=@"";
	
	[subView addSubview:activityIndicatorView];
	[subView addSubview:activityTitleLabel];
	[subView addSubview:activityStatusLabel];
	[subView addSubview:activityProgressView];
	[activityIndicatorView setFrame:CGRectMake (20,40, 80, 80)];
	[activityIndicatorView startAnimating];
	
	[subView release];
}

-(void)endActivityView
{
	[activityIndicatorView stopAnimating];
	[activityView removeFromSuperview];
}

- (void) release
{
	[super release];
}

- (id) retain
{
	return [super retain];
}

- (void)dealloc 
{
	[tmpEditSection release];
	tmpEditSection=nil;
	[newsletterTableView release];
	[editMoveButton release];
	[addImageButton release];
	//[titleTextField  release];
	//[descriptionTextField release];
	[addSectionPopover release];
	[imagePickerPopover release];
	[activityStatusViewController release];
	//[dateLabel release];
	[activityIndicatorView release];
	[activityView release];
	[activityTitleLabel release];
	[activityStatusLabel release];
	[activityProgressView release];
	[editActionToolbar release];
	[selectedIndexPaths release];
	//[collapseHeaderButton release];
	[navPopoverController release];
	[super dealloc];
}

@end
