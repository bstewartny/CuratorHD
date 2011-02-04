//
//  UserSettings.h
//  Untitled
//
//  Created by Robert Stewart on 2/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserSettings : NSObject {

}

+ (void) saveSetting:(NSString*)key value:(NSString*)valueString;

+ (NSString *)getSetting:(NSString*)key;

@end
