//
//  HTMLImageParser.h
//  Untitled
//
//  Created by Robert Stewart on 6/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTMLImageParser : NSObject {

}

+ (NSArray*) getImageUrlsFromUrl:(NSString*)url;



+ (NSArray*) getImageUrls:(NSString*)html;

@end
