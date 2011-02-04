//
//  GoogleClientLogin.h
//
//  Created by cameron ring on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  This class implements the client side of Google'a ClientLogin API. For more information:
//  http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html
//

#import <Foundation/Foundation.h>

@interface GoogleClientLogin : NSObject 
{
}

// Try to auth with the passed-in credentials for a particular service:
// username         User's full email address. It must include the domain (i.e. johndoe@gmail.com).
// password         User's password
// service          Name of the Google service you're requesting authorization for. Each service using the Authorization service
//                      is assigned a name value; for example, the name associated with Google Calendar is 'cl'. This parameter is
//                      required when accessing services based on Google Data APIs. For specific service names, refer to the service
//                        documentation.
// source           Short string identifying your application, for logging purposes. This string should take the form:
//                      "companyName-applicationName-versionID".
// captcha          (optional) String entered by the user as an answer to a CAPTCHA challenge.
// captchaToken     (optional) Token representing the specific CAPTCHA challenge. Google supplies this token and the CAPTCHA image URL
//                  in a login failed response with the error code "CaptchaRequired".

+ (NSString*) getAuthKeyWithUsername:(NSString *)username andPassword:(NSString *)password forService:(NSString *)service
						  withSource:(NSString *)source;

@end
