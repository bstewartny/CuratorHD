    //
//  SearchViewController.m
//  Untitled
//
//  Created by Robert Stewart on 4/23/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "SearchViewController.h"
#import "DocumentWebViewController.h"
#import "FeedItem.h"
#import "SearchArguments.h"
#import "InfoNgenSearchClient.h"
#import "SearchResults.h"
#import <QuartzCore/QuartzCore.h>
#import "FacetField.h"
#import "FacetValue.h"
#import "Favorites.h"

#import "NewsletterClient.h"
#import "MetaNameValue.h"
//#import "Search.h"
#import "AutocompleteTextField.h"

@implementation SearchViewController
@synthesize segmentedControl,resultsTable,searchResults,dateFormatter,activityView,activityIndicatorView,results,searchClient,autocompleteTextField;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	searchScope=kSearchScopeHeadlines;
	
	searchScopeFacetNames=[NSArray arrayWithObjects:@"",@"primarycompany",@"topic",nil];
	[searchScopeFacetNames retain];
	
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy h:mm"];
	self.dateFormatter=format;
	[format release];
	
	self.title=@"Search";
	self.navigationItem.title=@"InfoNgen Search";
	
	[self.autocompleteTextField ensureInitialized];
	
	self.autocompleteTextField.textField.delegate=self;
	self.autocompleteTextField.textField.placeholder=@"Search...";
	self.autocompleteTextField.textField.returnKeyType=UIReturnKeySearch;
	self.autocompleteTextField.delegate=self;
	
	
	
	[self.segmentedControl addTarget:self
						 action:@selector(scopeChanged:)
			   forControlEvents:UIControlEventValueChanged];
	
    [super viewDidLoad];
}

- (void)searchChanged:(AutocompleteTextField*)autoCompleteTextField
{
	NSLog(@"searchChanged");
	
	[self update];
}

- (void) scopeChanged:(id)sender
{
	searchScope=[self.segmentedControl selectedSegmentIndex];
	[self update];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	NSLog(textField.text);
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"textFieldShouldReturn");
	
	
	NSLog(textField.text);
	
	[textField resignFirstResponder];
	
	[self update];
	
	return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(searchScope==kSearchScopeHeadlines)
	{
		FeedItem  * item=[self.results objectAtIndex:indexPath.row];
	
		// show search result...
		if(item.url && [item.url length]>0)
		{
			NSLog(@"Opening url...");
		
			DocumentWebViewController * docViewController=[[DocumentWebViewController alloc] initWithNibName:@"DocumentWebView" bundle:nil];
		
			docViewController.item=item;
		
			[self.navigationController pushViewController:docViewController animated:YES];
		
			[docViewController release];
		}
	}
	else 
	{
		if(searchScope==kSearchScopeTrends)
		{
			// undefined...
			
		}
		else {
			
			// do facet drill down (append current facet value to previous query and show headlines)
			
			NSString * facetFieldName=[searchScopeFacetNames objectAtIndex:searchScope];
			
			FacetValue * value=[[[self.searchResults getFacetWithFieldName:facetFieldName] values] objectAtIndex:indexPath.row];
			
			SearchArguments * args=value.args;
			
			//self.searchBar.text=args.query;
			
			self.segmentedControl.selectedSegmentIndex=kSearchScopeHeadlines;
			
			//self.searchBar.selectedScopeButtonIndex=kSearchScopeHeadlines;
			
			searchScope=kSearchScopeHeadlines;
			
			MetaNameValue * metaNameValue=[[MetaNameValue alloc] init];
			
			metaNameValue.name.name=facetFieldName;
			metaNameValue.value=value;
			
			
			[self.autocompleteTextField addItem:metaNameValue display:value.displayValue];
			
			[metaNameValue release];
			
			[self update];
		}
	}	
}

- (BOOL) isUpdating
{
	return updating;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if(updating) return NO;
	return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * headline_identifier=@"headlineIdentifier";
	static NSString * facet_identifier=@"facetIdentifier";
	
	UITableViewCell * cell;
	if(searchScope==kSearchScopeHeadlines)
	{
		cell=[tableView dequeueReusableCellWithIdentifier:headline_identifier];
	
		if(cell==nil)
		{
			cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:headline_identifier] autorelease];
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			 
			[cell.imageView setImage:[UIImage imageNamed:@"star_off.png"]];
		}
			
		FeedItem * item=[self.results objectAtIndex:indexPath.row];
		
		UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
		
		button.frame=CGRectMake(0,0,32,32);
		
		button.tag=indexPath.row;
		 
		[cell.contentView addSubview:button];
		
		Favorites * favorites=[[[UIApplication sharedApplication] delegate] favorites];
		
		if([favorites containsItem:item])
		{
			[button setImage:[UIImage imageNamed:@"star_on.png"] forState:UIControlStateNormal];
		}
		else 
		{
			[button setImage:[UIImage imageNamed:@"star_off.png"] forState:UIControlStateNormal];
		}
		
		[button addTarget:self action:@selector(favoritesTouch:) forControlEvents:UIControlEventTouchUpInside];
		
		cell.textLabel.text=item.headline;
		cell.textLabel.textColor=[[[UIApplication sharedApplication] delegate] headlineColor];
		
		NSString *dateString = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:item.date],[item relativeDateOffset]];
		
		cell.detailTextLabel.text=dateString;
	}
	else 
	{
		cell=[tableView dequeueReusableCellWithIdentifier:facet_identifier];
		
		if(cell==nil)
		{
			cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:facet_identifier] autorelease];
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		}
		
		FacetValue * value=[[[self.searchResults getFacetWithFieldName:[searchScopeFacetNames objectAtIndex:searchScope]] values] objectAtIndex:indexPath.row];
		cell.textLabel.text=value.displayValue;
		cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",value.count];
	}
	
	return cell;
}

- (void) favoritesTouch:(id)sender
{
	Favorites * favorites=[[[UIApplication sharedApplication] delegate] favorites];
	
	FeedItem * item=[self.results objectAtIndex:[sender tag]];
	
	if([favorites containsItem:item])
	{
		[sender setImage:[UIImage imageNamed:@"star_off.png"] forState:UIControlStateNormal];
		[favorites removeItem:item];
	}
	else 
	{
		[sender setImage:[UIImage imageNamed:@"star_on.png"] forState:UIControlStateNormal];
		[favorites addItem:item];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(updating) return 0;
	
	if(searchScope==kSearchScopeHeadlines)
	{
		return [self.results count];
	}
	else 
	{
		return [[[self.searchResults getFacetWithFieldName:[searchScopeFacetNames objectAtIndex:searchScope]] values] count];
	}
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

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	NSLog(@"searchBarTextDidEndEditing");
	[searchBar resignFirstResponder];
	[self update];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
	NSLog(@"searchBarResultsListButtonClicked");
	[searchBar resignFirstResponder];
	
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	NSLog(@"selectedScopeButtonIndexDidChange");
	
	 
	/*UIButton * button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	/..,b\
	 
	 
	 
	 
	 
	 
	   utton.frame=CGRectMake(4, 4, 100, 25);
	
	button.titleLabel.text=@"scope";
	
	[[[self.searchBar subviews] objectAtIndex:0] addSubview:button];
	*/

	
	searchScope=selectedScope;
	[searchBar resignFirstResponder];
	[self update];	
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSLog(@"searchBarSearchButtonClicked");
	[searchBar resignFirstResponder];
	
}


- (void) suggestBegin:(NSString*)searchText
{
	NSLog(@"suggestBegin");
	
	/*[NSThread sleepForTimeInterval:0.5];
	
	// get matching suggestions from database
	NSString * text=searchBar.text;
	
	// only do it if text has not changed since this event was scheduled...
	if([searchText isEqualToString:text])
	{
		// get matches
		NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
		
		NSLog(@"getting matches...");
		
		// lookup matching entities...
		NSArray * matches=[[[UIApplication sharedApplication] delegate] lookupByName:nil displayValue:searchText];
		
		NSLog(@"got matches");
		
		if(matches && [matches count]>0)
		{
			// show suggestions to user if still matched...
			text=searchBar.text;
		
			if([searchText isEqualToString:text])
			{
				[self performSelectorOnMainThread:@selector(suggestEnd:) withObject:matches waitUntilDone:NO];
			}
			else 
			{
				[matches release];
			}

		}
		
		[pool drain];
	}*/
}

- (void) suggestEnd:(NSArray*)matches
{
	NSLog(@"suggestEnd");
	
	// display suggestions to user in popover
	for(MetaNameValue * match in matches)
	{
		NSLog(match.value.displayValue);
	}
	
	[matches release];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSLog(@"textDidChange");
		
	// start timer and then when timer expires lookup matching entities on different thread
	if(searchText && [searchText length]>1)
	{
		[self performSelectorInBackground:@selector(suggestBegin:) withObject:searchText];
	}
	
}


- (IBAction) search:(id)sender
{
	[self update];
}

- (void) update
{
	// show activity indicator
	
	// do update on background thread
	
	if(!updating)
	{
		updating=YES;
		
		[self startActivityView];
		
		// update all the saved searches associated with this page...
		[self performSelectorInBackground:@selector(updateStart) withObject:nil];
	}
}

- (NSString*) currentQuery
{
	NSMutableString * tmp=[[NSMutableString alloc] init];
	
	for (AutocompleteItem * item in self.autocompleteTextField.items)
	{
		if(item.excluded)
		{
			[tmp appendFormat:@" -(%@:%@)",[[item.value name] name],[[item.value value] value]];
		}
		else 
		{
			if(item.required)
			{
				[tmp appendFormat:@" +(%@:%@)",[[item.value name] name],[[item.value value] value]];
			}
			else 
			{
				[tmp appendFormat:@" (%@:%@)",[[item.value name] name],[[item.value value] value]];
			}
		}
	}
	
	if([self.autocompleteTextField.textField.text length]>0)
	{
		[tmp appendFormat:@" +(%@)",self.autocompleteTextField.textField.text];
	}
	
	NSString * query=[NSString stringWithFormat:@"+(%@)",tmp];
	
	[tmp release];
	
	return query;
	
}

- (void) updateStart
{
	// run end update on UI thread
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	// execute search...
	//[self.savedSearch update];
	
	NSString * query=[self currentQuery];
	
	NSLog(@"query: %@",query);
	
	SearchArguments * args=[[SearchArguments alloc] initWithQuery:query];
	
	args.startDate=[NSDate dateWithTimeIntervalSinceNow:-(60*60*24*7)];
	
	if(searchScope!=kSearchScopeHeadlines)
	{
		args.facetFields=[NSArray arrayWithObjects:[searchScopeFacetNames objectAtIndex:searchScope],nil];
		// for facets we dont need to return records
		// NOTE: we should make this 0 to avoid sorting, etc. but there is current bug on backend that defaults to 10 if its 0...
		args.pageSize=1;
	}
	
	// we dont need synopsis yet...
	args.fieldNames=[NSArray arrayWithObjects:@"subject",@"date",@"uri",@"clusterid",nil];
	
	self.searchResults=[searchClient search:args];
	
	if(self.searchResults)
	{
		self.results=searchResults.results;
	
		
		
		// resolve meta names
		
		[[[UIApplication sharedApplication] delegate] resolveMetaNames:searchResults];
		
		
		/*if(self.results.facets && [self.results.facets count]>0)
		{
			// create flat array of values
			NSMutableArray * tmp=[[NSMutableArray alloc] init];
			
			for(FacetField * facetField in self.results.facets)
			{
				for(FacetValue * facetValue in facetField.values)
				{
					[tmp addObject:facetValue.metaNameValue];
				}
			}
			
			// resolve metanames using newsletter API for now...
			//NewsletterAPI * newsletterAPI = [[[UIApplication sharedApplication] delegate] newsletterAPI];
			
			//[newsletterAPI ResolveMetaNames:tmp useRemoteIfNotInCache:YES];

			[tmp release];
		}*/
	}
	else 
	{
		self.results=nil;
	}
	
	[pool drain];
	
	app.networkActivityIndicatorVisible = NO;
	
	[self performSelectorOnMainThread:@selector(endUpdate) withObject:nil waitUntilDone:NO];
}

- (void) endUpdate
{
	updating=NO;
	
	// hide acitivity indicator
	[self endActivityView];
	
	// reload table
	[resultsTable reloadData];
}

- (void) startActivityView
{
	activityView = [[UIView alloc] initWithFrame:[[self view] bounds]];
	[activityView setBackgroundColor:[UIColor blackColor]];
	[activityView setAlpha:0.5];
	[[self view] addSubview:activityView];
	
	UIView * subView=[[UIView alloc] initWithFrame:CGRectMake(activityView.center.x-100/2, activityView.center.y-100/2, 100, 100)];
	
	[subView setBackgroundColor:[UIColor blackColor]];
	[subView setAlpha:2.10];
	
	[[subView layer] setCornerRadius:24.0f];
	[[subView layer] setMasksToBounds:YES];
	
	[activityView addSubview:subView];
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	[activityIndicatorView setFrame:CGRectMake (20,20, 60, 60)];
	
	[subView addSubview:activityIndicatorView];
	
	[activityIndicatorView startAnimating];
	
	[subView release];
}

-(void)endActivityView
{
	[activityIndicatorView stopAnimating];
	[activityView removeFromSuperview];
}

- (void)dealloc {
	//[searchBar release];
	[resultsTable release];
	[dateFormatter release];
	[activityView release];
	[activityIndicatorView release];
	[results release];
	[searchClient release];
	[searchResults release];
	[searchScopeFacetNames release];
	[autocompleteTextField release];
	[segmentedControl release];
    [super dealloc];
}

@end
