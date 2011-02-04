//
//  UIImage-NSCoding.m
//  Untitled
//
//  Created by Robert Stewart on 2/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

//
//  UIImage-NSCoding.m

#import "UIImage-NSCoding.h"
#define kEncodingKey        @"UIImage"

@implementation UIImage(NSCopying)
- (id) copyWithZone: (NSZone *) zone
{
    return [[UIImage allocWithZone: zone] initWithCGImage: self.CGImage];
}
@end


@implementation UIImage(NSCoding)
- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        NSData *data = [decoder decodeObjectForKey:kEncodingKey];
        self = [self initWithData:data];
    }
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSData *data = UIImagePNGRepresentation(self);
    [encoder encodeObject:data forKey:kEncodingKey];
}
@end
