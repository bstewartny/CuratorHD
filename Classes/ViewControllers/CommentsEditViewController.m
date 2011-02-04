    //
//  CommentsEditViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "CommentsEditViewController.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsletterItemContentView.h"
 

@implementation CommentsEditViewController
@synthesize item,commentsTextView,delegate,tableView,commentsTextColor;

- (IBAction) action:(id)sender
{
	// show action sheet to choose to email item
	UIActionSheet * actionSheet=[[UIActionSheet alloc] initWithTitle:@"Item Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear comments" otherButtonTitles:@"Email Item",nil];
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
	
	[actionSheet release];
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	[self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			
			// clear comments
			commentsTextView.text=nil;
			break;
		case 1:
			// email item
			// show email client
		{
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			
			picker.mailComposeDelegate = self; // <- very important step if you want feedbacks on what the user did with your email sheet
			
			[picker setSubject:self.item.headline];
			
			// Fill out the email body text
			NSString * body;
			
			if(self.item.url && [self.item.url length]>0)
			{
				body=self.item.url;
				body=[body stringByAppendingString:@"\n\n"];
				body=[body stringByAppendingString:self.item.synopsis];
			}
			else 
			{
				body=self.item.synopsis;
			}
			
			if(self.commentsTextView.text && [self.commentsTextView.text length]>0)
			{
				body=[body stringByAppendingString:@"\n\nMy Comments:\n\n"];
				body=[body stringByAppendingString:self.commentsTextView.text];
			}
			
			[picker setMessageBody:body isHTML:NO]; // depends. Mostly YES, unless you want to send it as plain text (boring)
			
			picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
			
			[self presentModalViewController:picker animated:YES];
			
			[picker release];
		}
			break;
			
	}
}
- (IBAction) cancel
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction) dismiss
{
	 
	item.notes=commentsTextView.text;
	
	if(delegate)
	{
		[delegate redraw];
	}
	
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.commentsTextColor=[NewsletterItemContentView colorWithHexString:@"b00027"];
}

- (UITableViewCell *) getCommentsCell
{
	static NSString * identifier=@"getCommentsCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UIImage * quoteImage=[UIImage imageNamed:@"CommentQuoteImage.jpg"];
		
		UIImageView * quoteImageView=[[UIImageView alloc] initWithImage:quoteImage];
		
		quoteImageView.frame=CGRectMake(2, 88, quoteImage.size.width, quoteImage.size.height);
		
		UIView * seperatorView=[[UIView alloc] initWithFrame:CGRectMake(48, 10, 2, 185)];
		seperatorView.backgroundColor=[UIColor grayColor];
		
		UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(52,5, 460, 185)];
		
		textView.backgroundColor=[UIColor clearColor];
		textView.font=[UIFont systemFontOfSize:18];
		
		textView.textColor=self.commentsTextColor;
		textView.text=self.item.notes;
		
		[textView becomeFirstResponder];
		
		self.commentsTextView=textView;
		
		cell.contentView.frame=CGRectMake(0,0, 530, 210);
		
		[cell.contentView addSubview:textView];
		[cell.contentView addSubview:quoteImageView];
		[cell.contentView addSubview:seperatorView];
		[cell.contentView bringSubviewToFront:textView];
		
		[seperatorView release];
		
		[quoteImageView release];
		
		[textView release];
	}
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0:
			return [self getCommentsCell];
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
	
	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 240;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
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
	[item release];
	[commentsTextView release];
	[delegate release];
	[tableView release];
	[commentsTextColor release];
    [super dealloc];
}


@end
