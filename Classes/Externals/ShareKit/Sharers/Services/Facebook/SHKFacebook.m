//
//  SHKFacebook.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/18/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKFacebook.h"
#import "SBJSON.h"

@implementation SHKFacebook
@synthesize facebook;
@synthesize pendingFacebookAction;

- (void)dealloc
{
	[facebook release];
	[super dealloc];
}


#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"Facebook";
}

+ (BOOL)canShareURL
{
	return YES;
}

+ (BOOL)canShareText
{
	return YES;
}

+ (BOOL)canShareImage
{
	return YES;
}

+ (BOOL)canShareOffline
{
	return NO; // TODO - would love to make this work
}

#pragma mark -
#pragma mark Configuration : Dynamic Enable

- (BOOL)shouldAutoShare
{
	return YES; // FBConnect presents its own dialog
}

#pragma mark -
#pragma mark Authentication

- (BOOL)isAuthorized
{	
	NSLog(@"isAuthorized");
	if(facebook==nil)
	{
		Facebook * tmp=[[Facebook alloc] init];
		tmp.accessToken=[SHK getAuthValueForKey:@"accessToken" forSharer:[self sharerId]];
		NSLog(@"set facebook.accessToken=%@",tmp.accessToken);
		tmp.expirationDate=[NSDate distantFuture]; // TODO: get real one...
		self.facebook=tmp;
		[tmp release];
	}
	
	return [facebook isSessionValid];
}

- (void)promptAuthorization
{
	NSLog(@"promptAuthorization");
	self.pendingFacebookAction = SHKFacebookPendingLogin;
	
	[facebook authorize:SHKFacebookKey permissions:[NSArray arrayWithObjects:
													@"read_stream", @"read_mailbox", @"user_notes",@"offline_access",nil] delegate:self];
}

- (void)authFinished:(SHKRequest *)request
{		
	NSLog(@"authFinished");
	
}

+ (void)logout
{
	
}

#pragma mark -
#pragma mark Share API Methods

- (NSString*) jsonParams:(id)params
{
	return [[[[SBJSON alloc] init] autorelease] stringWithObject:params];
}

- (BOOL)send
{			
	if (item.shareType == SHKShareTypeURL)
	{
		self.pendingFacebookAction = SHKFacebookPendingStatus;
		
		NSString* actionLinks = [self jsonParams:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
															   SHKMyAppName,@"text",SHKMyAppURL,@"href", nil], nil]];
		
		// maybe use "caption" and/or "description" params here too?
		NSString* attachment;
		
		if([item.text length]>0)
		{
			attachment = [self jsonParams:[NSDictionary dictionaryWithObjectsAndKeys:
										   item.title ==nil?[item.URL absoluteString]:item.title, @"name",
										   item.text,@"description",
										   [item.URL absoluteString], @"href", nil]];
		}
		else 
		{
			attachment = [self jsonParams:[NSDictionary dictionaryWithObjectsAndKeys:
										   item.title ==nil?[item.URL absoluteString]:item.title, @"name",
										   [item.URL absoluteString], @"href", nil]];
		}
		
		NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   SHKFacebookKey, @"api_key",
									   @"Share on Facebook",  @"user_message_prompt",
									   actionLinks, @"action_links",
									   attachment, @"attachment",
									   nil];
		
		//[facebook dialog:@"links.post" andParams:params andDelegate:self];
		
		[facebook dialog:@"stream.publish"
				andParams:params
			  andDelegate:self];
	
	}
	else if (item.shareType == SHKShareTypeText)
	{
		self.pendingFacebookAction = SHKFacebookPendingStatus;
		
		NSString* actionLinks = [self jsonParams:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
																			SHKMyAppName,@"text",SHKMyAppURL,@"href", nil], nil]];
		
		NSMutableDictionary * dict=[[[NSMutableDictionary alloc] init] autorelease];
		
		if([item.text length]>0)
		{
			[dict setValue:item.text forKey:@"description"];
		}
		
		if([item.title length]>0)
		{
			[dict setValue:item.title forKey:@"name"];
		}
		
		NSMutableDictionary* params;
		
		if([dict count]>0)
		{
			params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					  SHKFacebookKey, @"api_key",
					  @"Share on Facebook",  @"user_message_prompt",
					  actionLinks, @"action_links",
					  [self jsonParams:dict], @"attachment",
					  nil];
		}
		else 
		{
			params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					  SHKFacebookKey, @"api_key",
					  @"Share on Facebook",  @"user_message_prompt",
					  actionLinks, @"action_links",
					  nil];
		}

		[facebook dialog:@"stream.publish"
			   andParams:params
			 andDelegate:self];
		
	}
	else if (item.shareType == SHKShareTypeImage)
	{		
		self.pendingFacebookAction = SHKFacebookPendingImage;
		
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   item.image, @"picture",
									   nil];
		
		[facebook requestWithMethodName:@"photos.upload"
							   andParams:params
						   andHttpMethod:@"POST"
							 andDelegate:self];
	
	}
	
	return YES;
}

- (void)dialogDidComplete:(FBDialog *)dialog
{
	NSLog(@"dialogDidComplete");
	
	if(pendingFacebookAction!=SHKFacebookPendingLogin)
	{
		[self sendDidFinish];
	}
}

- (void)dialogDidNotComplete:(FBDialog *)dialog
{
	NSLog(@"dialogDidNotComplete");
	if(pendingFacebookAction!=SHKFacebookPendingLogin)
	{
		[self sendDidCancel];
	}
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url
{
	return YES;
}


#pragma mark FBSessionDelegate methods

- (void)fbDidLogin
{
	NSLog(@"fbDidLogin");
	if (pendingFacebookAction == SHKFacebookPendingLogin)
	{
		self.pendingFacebookAction = SHKFacebookPendingNone;
		
		// save accesstoken and expiration date...
		NSLog(@"facebook.accessToken=%@",facebook.accessToken);
		NSLog(@"facebook.expirationDate=%@",[facebook.expirationDate description]);
		
		[SHK setAuthValue:facebook.accessToken
				   forKey:@"accessToken"
				forSharer:[self sharerId]];
		
		[self share];
	}
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
	NSLog(@"fbDidNotLogin");
}

- (void)fbDidLogout
{
	NSLog(@"fbDidLogout");
}

#pragma mark FBRequestDelegate methods

- (void)request:(FBRequest*)aRequest didLoad:(id)result 
{
	NSLog(@"request:didLoad");
	
	if (pendingFacebookAction != SHKFacebookPendingLogin)
	{
		[self sendDidFinish];
	}
}

- (void)request:(FBRequest*)aRequest didFailWithError:(NSError*)error 
{
	NSLog(@"request:didFailWithError");
	[self sendDidFailWithError:error];
}





@end
