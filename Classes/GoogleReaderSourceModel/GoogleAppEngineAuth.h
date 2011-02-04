//
//  GoogleAppEngineAuth.h
//  whaleops
//
//  Created by cameron ring on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "GoogleClientLogin.h"


// GoogleAppEngineAuth is a GoogleClientLoginDelegate because we need to do some more work after getting the auth
// cookie to get the app engine auth cookie
@interface GoogleAppEngineAuth : NSObject 
{
}



// Try to auth with the passed-in credentials for Google App Engine:
// username     User's full email address. It must include the domain (i.e. johndoe@gmail.com).
// password     User's password
// source       Short string identifying your application, for logging purposes. This string should take the form:
//              "companyName-applicationName-versionID".
// captcha          (optional) String entered by the user as an answer to a CAPTCHA challenge.
// captchaToken     (optional) Token representing the specific CAPTCHA challenge. Google supplies this token and the CAPTCHA image URL
//                  in a login failed response with the error code "CaptchaRequired".

+ (NSString*)getAuthCookieWithAppURL:(NSString*)appURL andUsername:(NSString *)username andPassword:(NSString *)password withSource:(NSString *)source;


@end
