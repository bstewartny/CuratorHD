    //
//  TumblrPostViewController.m
//  Untitled
//
//  Created by Robert Stewart on 6/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TumblrPostViewController.h"
#import "TumblrClient.h"
#import "FeedAccount.h"
#import "FeedItem.h"
#import <QuartzCore/QuartzCore.h>
#import "HTMLImageParser.h"

#import "UserSettings.h"

@implementation TumblrPostViewController
@synthesize item,tableView,scrollView,postType,titleTextField,urlTextField,bodyTextView,tagsTextField,textButton,linkButton,quoteButton,photoButton,videoButton;

 

- (void)viewDidLoad
{
	/*scrollView.backgroundColor=[UIColor whiteColor];
	scrollView.layer.shadowColor=[UIColor blackColor].CGColor;
	scrollView.layer.shadowOpacity=1.0;
	scrollView.layer.shadowRadius=5.0;
	scrollView.layer.shadowOffset=CGSizeMake(0,3);
	scrollView.clipsToBounds=NO;*/
	
	CGFloat width=self.scrollView.frame.size.width;
	width=550;
	/*
	CGFloat spacer=width/5;
	CGFloat x=spacer/2 - 32;
	
	textButton.frame=CGRectMake(x, 5, 64, 64);
	x=x+spacer;
	
	linkButton.frame=CGRectMake(x, 5, 64, 64);
	x=x+spacer;
	
	quoteButton.frame=CGRectMake(x, 5, 64, 64);
	x=x+spacer;
	
	photoButton.frame=CGRectMake(x, 5, 64, 64);
	x=x+spacer;
	
	videoButton.frame=CGRectMake(x, 5, 64, 64);
	x=x+spacer;
	

	switch(postType)
	{
		case TumblrPostTypeRegular:
			[self highlightButton:textButton];
			break;
		case TumblrPostTypeLink:
			[self highlightButton:linkButton];
			break;
		case TumblrPostTypeQuote:
			[self highlightButton:quoteButton];
			break;
		case TumblrPostTypePhoto:
			[self highlightButton:photoButton];
			break;
		case TumblrPostTypeVideo:
			[self highlightButton:videoButton];
			break;
	}*/
}

- (void) highlightButton:(UIButton*)button
{
	[self unHighlightButton:textButton];
	[self unHighlightButton:linkButton];
	[self unHighlightButton:quoteButton];
	[self unHighlightButton:photoButton];
	[self unHighlightButton:videoButton];
	
	
	
	button.layer.shadowColor=[UIColor blackColor].CGColor;
	button.layer.shadowOpacity=1.0;
	button.layer.shadowRadius=5.0;
	button.layer.shadowOffset=CGSizeMake(0,3);
	button.clipsToBounds=NO;
}

- (void) unHighlightButton:(UIButton*)button
{
	
	button.layer.shadowColor=[UIColor clearColor].CGColor;
	button.layer.shadowOpacity=0.0;
	button.layer.shadowRadius=0.0;
	button.layer.shadowOffset=CGSizeMake(0,0);
	//button.clipsToBounds=NO;
}

- (IBAction) doText:(id)sender
{
	NSLog(@"doText");
	[self highlightButton:sender];
	 
	
	
	
	postType=TumblrPostTypeRegular;
	[self.tableView reloadData];
}
- (IBAction) doLink:(id)sender
{
	NSLog(@"doLink");
	[self highlightButton:sender];
	
	postType=TumblrPostTypeLink;
	[self.tableView reloadData];
}
- (IBAction) doQuote:(id)sender
{
	NSLog(@"doQuote");
	[self highlightButton:sender];
	
	postType=TumblrPostTypeQuote;
	[self.tableView reloadData];
}
- (IBAction) doPhoto:(id)sender
{
	NSLog(@"doPhoto");

	[self highlightButton:sender];
	
	NSArray * images=[HTMLImageParser getImageUrls:self.item.origSynopsis];
	for(NSString * image in images)
	{
		NSLog(@"Found image: %@",image);
	}
	
	postType=TumblrPostTypePhoto;
	[self.tableView reloadData];
}
- (IBAction) doVideo:(id)sender
{
	NSLog(@"doVideo");
	[self highlightButton:sender];
	
	postType=TumblrPostTypeVideo;
	[self.tableView reloadData];
}

- (IBAction) cancel
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction) dismiss
{
	post=[[TumblrPost alloc] initWithType:TumblrPostTypeRegular];
	
	post.type=postType;
	
	switch(postType)
	{
		case TumblrPostTypeRegular:
			post.title=self.titleTextField.text;
			post.body=self.bodyTextView.text;
			break;
		case TumblrPostTypeLink:
			post.link_name=self.titleTextField.text;
			post.link_url=self.urlTextField.text;
			post.link_description=self.bodyTextView.text;
			break;
		case TumblrPostTypeQuote:
			post.quote=self.bodyTextView.text;
			post.quote_source=self.urlTextField.text;
			break;	
		case TumblrPostTypePhoto:
			//post.photo_source=self.photoSourceTextField.text;
			post.photo_caption=self.bodyTextView.text;
			post.photo_click_through_url=self.urlTextField.text;
			break;
		case TumblrPostTypeVideo:
			//post.video_embed=self.videoEmbed;
			post.video_caption=self.bodyTextView.text;
			post.video_title=self.titleTextField.text;
			break;
	}
	
	/*if([self.tagsTextField.text length]>0)
	{
		post.tags=[self.tagsTextField.text componentsSeparatedByString:@","];
	}*/
	
	[self update];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"heightForRowAtIndexPath");
	switch(postType)
	{
		case TumblrPostTypeRegular:
		{
			switch(indexPath.section)
			{
				case 0:
					return 44;
				case 1:
					return 240;
			}
		}
		case TumblrPostTypeLink:
		{
			switch(indexPath.section)
			{
				case 0:
					return 44;
				case 1:
					return 44;
				case 2:
					return 240;
			}
		}		
		case TumblrPostTypeQuote:
		{
			switch(indexPath.section)
			{
				case 0:
					return 44;
				case 1:
					return 240;
			}
		}		
		case TumblrPostTypePhoto:
		{
			switch(indexPath.section)
			{
				case 0:
					return 44;
				case 1:
					return 44;
				case 2:
					return 240;
			}
		}
		case TumblrPostTypeVideo:
		{
			switch(indexPath.section)
			{
				case 0:
					return 44;
				case 1:
					return 44;
				case 2:
					return 240;
			}
		}
	}
}

- (UITableViewCell *) getTitleCell
{
	static NSString * identifier=@"getTitleCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,60,30)];
		label.text=@"Title:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(70,14,450,22)];
		textField.backgroundColor=[UIColor clearColor];
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		textField.keyboardType=UIKeyboardTypeEmailAddress;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		textField.text=self.item.headline;
		
		self.titleTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}

- (UITableViewCell *) getUrlCell
{
	static NSString * identifier=@"getUrlCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,60,30)];
		label.text=@"Link:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(70,14,450,22)];
		textField.backgroundColor=[UIColor clearColor];
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		textField.keyboardType=UIKeyboardTypeEmailAddress;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		textField.text=self.item.url;
		
		self.urlTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}

- (UITableViewCell *) getTagsCell
{
	static NSString * identifier=@"getTagsCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(10,10,100,30)];
		label.text=@"Tags:";
		label.textColor=[UIColor grayColor];
		label.font=[UIFont systemFontOfSize:18];
		label.backgroundColor=[UIColor clearColor];
		UITextField * textField=[[UITextField alloc] initWithFrame:CGRectMake(105,14,300,22)];
		textField.backgroundColor=[UIColor clearColor];
		textField.font=[UIFont boldSystemFontOfSize:18];//:18];
		textField.keyboardType=UIKeyboardTypeEmailAddress;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		
		self.tagsTextField=textField;
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:textField];
		
		[textField release];
		[label release];
	}
	
	return cell;
}

- (UITableViewCell *) getCommentsCell
{
	static NSString * identifier=@"getCommentsCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UIImage * quoteImage=[UIImage imageNamed:@"CommentQuoteImage.jpg"];
		
		UIImageView * quoteImageView=[[UIImageView alloc] initWithImage:quoteImage];
		
		quoteImageView.frame=CGRectMake(2, 88, quoteImage.size.width, quoteImage.size.height);
		
		UIView * seperatorView=[[UIView alloc] initWithFrame:CGRectMake(48, 10, 2, 185)];
		seperatorView.backgroundColor=[UIColor grayColor];
		
		UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(52,5, 460, 185)];
		
		textView.backgroundColor=[UIColor clearColor];
		textView.font=[UIFont systemFontOfSize:18];
		
		textView.text=self.item.notes;
		
		[textView becomeFirstResponder];
		
		self.bodyTextView=textView;
		
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

- (UITableViewCell *) getBodyCell
{
	static NSString * identifier=@"getBodyCell";
	
	UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if(cell==nil)
	{
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		
		UITextView * textView=[[UITextView alloc] initWithFrame:CGRectMake(5,5, 460, 185)];
		
		textView.backgroundColor=[UIColor clearColor];
		textView.font=[UIFont systemFontOfSize:18];
		
		//textView.textColor=self.commentsTextColor;
		textView.text=self.item.synopsis;
		
		[textView becomeFirstResponder];
		
		self.bodyTextView=textView;
		
		cell.contentView.frame=CGRectMake(0,0, 530, 210);
		
		[cell.contentView addSubview:textView];
		 
		[cell.contentView bringSubviewToFront:textView];
		
		[textView release];
	}
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"cellForRowAtIndexPath");
	
	switch(postType)
	{
		case TumblrPostTypeRegular:
		{
			switch(indexPath.section)
			{
				case 0:
					return [self getTitleCell];
				case 1:
					return [self getCommentsCell];
			}
		}
		case TumblrPostTypeLink:
		{
			switch(indexPath.section)
			{
				case 0:
					return [self getTitleCell];
				case 1:
					return [self getUrlCell];
				case 2:
					return [self getCommentsCell];
			}
		}		
		case TumblrPostTypeQuote:
		{
			switch(indexPath.section)
			{
				case 0:
					return [self getUrlCell];
				case 1:
					return [self getCommentsCell];
			}
		}		
		case TumblrPostTypePhoto:
		{
			switch(indexPath.section)
			{
				case 0:
					return [self getTitleCell];
				case 1:
					return [self getUrlCell];
				case 2:
					return [self getCommentsCell];
			}
		}
		case TumblrPostTypeVideo:
		{
			switch(indexPath.section)
			{
				case 0:
					return [self getTitleCell];
				case 1:
					return [self getUrlCell];
				case 2:
					return [self getCommentsCell];
			}
		}
	}
 }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"numberOfRowsInSection");
	
	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSLog(@"numberOfSectionsInTableView");
	
	switch(postType)
	{
		case TumblrPostTypeRegular:
			return 2;
		case TumblrPostTypeLink:
			return 3;
		case TumblrPostTypeQuote:
			return 2;
		case TumblrPostTypePhoto:
			return 2;
		case TumblrPostTypeVideo:
			return 2;
		default:
			return 0;
	}
}

- (void) doUpdate
{
	if(post==nil) return; // should not happen...
	
	NSLog(@"Sending post to tumblr...");
	
	NSString * username=[UserSettings getSetting:@"tumblr.username"];
	NSString * password=[UserSettings getSetting:@"tumblr.password"];
	
	TumblrClient * client=[[TumblrClient alloc] initWithUsername:username password:password];
		
	[client post:post];
	
	[post release];
	
	[client release];

	NSLog(@"Sent post to tumblr...");
}

- (void) afterUpdate
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
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
	[titleTextField release];
	[urlTextField release];
	[bodyTextView release];
	[tagsTextField release];
	[tableView release];
	
	[textButton release];
	[linkButton release];
	[quoteButton release];
	[photoButton release];
	[videoButton release];
	[scrollView release];
	
	
    [super dealloc];
}


@end
