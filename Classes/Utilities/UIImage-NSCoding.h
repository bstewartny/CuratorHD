//
//  UIImage-NSCoding.h
//  Untitled
//
//  Created by Robert Stewart on 2/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

//  UIImage-NSCoding.h

#import <Foundation/Foundation.h>

@interface UIImageNSCopying <NSCopying>
	
- (id) copyWithZone: (NSZone *) zone;

@end





@interface UIImageNSCoding <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end


