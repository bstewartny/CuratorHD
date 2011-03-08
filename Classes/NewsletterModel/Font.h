//
//  Font.h
//  Curator
//
//  Created by Robert Stewart on 3/8/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontValue : NSObject
{
	NSString * name;
	NSString * value;
}

@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * value;

+ (FontValue*) withName:(NSString*)name andValue:(NSString*)value;

@end

@interface Font : NSObject <NSCopying,NSCoding>{
	NSString * family;
	NSString * weight;
	NSString * style;
	NSString * color;
	NSString * size;
} 

@property(nonatomic,retain) NSString * family;
@property(nonatomic,retain) NSString * weight;
@property(nonatomic,retain) NSString * style;
@property(nonatomic,retain) NSString * color;
@property(nonatomic,retain) NSString * size;

- (NSString*) cssStyle;

- (id) copyWithZone: (NSZone *) zone;
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

- (id) initWithFamily:(NSString*)family weight:(NSString*)weight style:(NSString*)style size:(NSString*)size color:(NSString*)color;

@end
