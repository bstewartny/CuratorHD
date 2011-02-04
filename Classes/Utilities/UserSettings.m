//
//  UserSettings.m
//  Untitled
//
//  Created by Robert Stewart on 2/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings

+ (void) saveSetting:(NSString*)key value:(NSString*)valueString
{
	NSUserDefaults * defaults=[NSUserDefaults standardUserDefaults];
	
	if(defaults)
	{
		[defaults setObject:valueString forKey:key];
		[defaults synchronize];
	}

}

+ (NSString *)getSetting:(NSString*)key
{
	NSLog(@"UserSettings.getSetting: %@",key);
	
	NSUserDefaults * defaults=[NSUserDefaults standardUserDefaults];
	NSString * val=nil;
	if(defaults)
	{
		val=[defaults objectForKey:key];
	}
	
	if(val==nil)
	{
		NSString * path=[[NSBundle mainBundle] bundlePath];
		NSString * settingsPath=[path stringByAppendingPathComponent:@"Settings.bundle"];
		NSString * plistFile=[settingsPath stringByAppendingPathComponent:@"Root.plist"];
		
		NSDictionary * dict=[NSDictionary dictionaryWithContentsOfFile:plistFile];
		NSArray * array=[dict objectForKey:@"PreferenceSpecifiers"];
		NSDictionary *item;
		for(item in array)
		{
			NSString * keyValue=[item objectForKey:@"Key"];
			
			id defaultValue=[item objectForKey:@"DefaultValue"];
			
			if(keyValue && defaultValue)
			{
				[defaults setObject:defaultValue forKey:keyValue];
				if ([keyValue compare:key]==NSOrderedSame) {
					val=defaultValue;
				}
			}
		}
		[defaults synchronize];
	}
	
	NSLog(@"Setting value is: %@",val);
	
	if(val==nil) return @"";
	
	return val;
}


@end
