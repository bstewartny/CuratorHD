//
//  TumblrClient.m
//  Untitled
//
//  Created by Robert Stewart on 11/30/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TumblrClient.h"
#import "SHK.h"
#import "SHKConfig.h"
#import "SHKTumblr.h"

@implementation TumblrClient

- (NSArray *)shareFormFieldsForType:(SHKShareType)type{
    NSMutableArray *baseArray = [NSMutableArray arrayWithObjects:
								 [SHKFormFieldSettings label:SHKLocalizedString(@"Tags")
														 key:@"tags"
														type:SHKFormFieldTypeText
													   start:item.tags],
								 [SHKFormFieldSettings label:SHKLocalizedString(@"Slug")
														 key:@"slug"
														type:SHKFormFieldTypeText
													   start:nil],
								 [SHKFormFieldSettings label:SHKLocalizedString(@"Private")
														 key:@"private"
														type:SHKFormFieldTypeSwitch
													   start:SHKFormFieldSwitchOff],
								 [SHKFormFieldSettings label:SHKLocalizedString(@"Send to Twitter")
														 key:@"twitter"
														type:SHKFormFieldTypeSwitch
													   start:SHKFormFieldSwitchOff],
								 nil
								 ];
    if([item shareType] == SHKShareTypeImage){
        [baseArray insertObject:[SHKFormFieldSettings label:SHKLocalizedString(@"Caption")
                                                        key:@"caption"
                                                       type:SHKFormFieldTypeText
                                                      start:nil] 
                        atIndex:0];
    }else{
        [baseArray insertObject:[SHKFormFieldSettings label:SHKLocalizedString(@"Title")
                                                        key:@"title"
                                                       type:SHKFormFieldTypeText
                                                      start:item.title]
                        atIndex:0];
    }
    return baseArray;
}

- (BOOL)send{		
	if ([self validateItem]) {
        if([item shareType] == SHKShareTypeText || [item shareType] == SHKShareTypeURL){
            NSMutableString *params = [NSMutableString stringWithFormat:@"email=%@&password=%@", 
                                       SHKEncode([self getAuthValueForKey:@"email"]),
                                       SHKEncode([self getAuthValueForKey:@"password"])];
            
            //set send to twitter param
            if([item customBoolForSwitchKey:@"twitter"]){
                [params appendFormat:@"&send-to-twitter=auto"];
            }else{
                [params appendFormat:@"&send-to-twitter=no"];
            }
            
            //set tags param
            NSString *tags = [item tags];
            if(tags){
                [params appendFormat:@"&tags=%@",[item tags]];
            }
            
            //set slug param
            NSString *slug = [item customValueForKey:@"slug"];
            if(slug){
                [params appendFormat:@"&slug=%@", slug];
            }
            
            //set private param
            if([item customBoolForSwitchKey:@"private"]){
                [params appendFormat:@"&private=1"];
            }else{
                [params appendFormat:@"&private=0"];
            }
            
            //set type param
            if ([item shareType] == SHKShareTypeURL){
                [params appendString:@"&type=link"];
                [params appendFormat:@"&url=%@",SHKEncodeURL([item URL])];
                if([item title]){
                    [params appendFormat:@"&name=%@", SHKEncode([item title])];   
                }
            }else{
                [params appendString:@"&type=regular"];
                if([item title]){
                    [params appendFormat:@"&title=%@", SHKEncode([item title])];
                }
                [params appendFormat:@"&body=%@", SHKEncode([item text])];
            }
            self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:kTumblrWriteURL]
                                                     params:params
                                                   delegate:self
                                         isFinishedSelector:@selector(sendFinished:)
                                                     method:@"POST"
                                                  autostart:YES] autorelease];
        }
        else if([item shareType] == SHKShareTypeImage){
            
            NSData *imageData = UIImageJPEGRepresentation([item image], 0.9);
            NSMutableURLRequest *aRequest = [[[NSMutableURLRequest alloc] init] autorelease];
            [aRequest setURL:[NSURL URLWithString:kTumblrWriteURL]];
            [aRequest setHTTPMethod:@"POST"];
            NSString *boundary = @"0xKhTmLbOuNdArY";
            //NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [aRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            /*
             now lets create the body of the post
             */
            NSMutableData *body = [NSMutableData data];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                              dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"email\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[self getAuthValueForKey:@"email"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                              dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"password\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[self getAuthValueForKey:@"password"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                              dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"type\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"photo" dataUsingEncoding:NSUTF8StringEncoding]];
			
            if([item tags]){
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                                  dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"tags\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[item tags] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            if([item customValueForKey:@"caption"]){
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                                  dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"caption\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[item customValueForKey:@"caption"] dataUsingEncoding:NSUTF8StringEncoding]];
				
            }
            if([item customValueForKey:@"slug"]){
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                                  dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"slug\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[item customValueForKey:@"slug"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                              dataUsingEncoding:NSUTF8StringEncoding]];
            if([item customBoolForSwitchKey:@"private"]){
                [body appendData:[@"Content-Disposition: form-data; name=\"private\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]];
            }else{
                [body appendData:[@"Content-Disposition: form-data; name=\"private\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"0" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] 
                              dataUsingEncoding:NSUTF8StringEncoding]];
            if([item customBoolForSwitchKey:@"twitter"]){
                [body appendData:[@"Content-Disposition: form-data; name=\"twitter\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"auto" dataUsingEncoding:NSUTF8StringEncoding]];
            }else{
                [body appendData:[@"Content-Disposition: form-data; name=\"twitter\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"no" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"data\"; filename=\"upload.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Transfer-Encoding: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // setting the body of the post to the reqeust
            [aRequest setHTTPBody:body];
            [NSURLConnection connectionWithRequest:aRequest delegate:self];
        }
		
		
		// Notify delegate
		[self sendDidStart];
		
		return YES;
	}
	
	return NO;
}


@end
