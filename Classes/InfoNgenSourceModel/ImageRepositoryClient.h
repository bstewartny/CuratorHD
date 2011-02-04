//
//  ImageRepositoryClient.h
//  Untitled
//
//  Created by Robert Stewart on 5/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kImageRepositoryURL @"http://ipad.infongen.com/Services/ipad/fs/$/ipadimages/"

@interface ImageRepositoryClient : NSObject 
{
	
}

+ (NSString*) putImage:(UIImage*) image;
+ (NSString*) putImage2:(UIImage*)image withPath:(NSString*)path;

@end
