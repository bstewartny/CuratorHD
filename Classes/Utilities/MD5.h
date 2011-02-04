//
//  MD5.h
//  Untitled
//
//  Created by Robert Stewart on 8/17/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (InfoNgen_MD5)
- (NSString *) md5;
@end

@interface NSData (InfoNgen_MD5)
- (NSString*)md5;
@end
