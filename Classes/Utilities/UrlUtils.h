//
//  UrlUtils.h
//  Untitled
//
//  Created by Robert Stewart on 8/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UrlUtils : NSObject {

}
+ (NSString*) hostFromUrl:(NSString*)url;
+ (UIImage*) faviconFromUrl:(NSString*)url imageCache:(NSMutableDictionary*)imageCache;

@end
