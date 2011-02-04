//
//  MetaNameValue.h
//  Untitled
//
//  Created by Robert Stewart on 4/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetaName  : NSObject <NSCoding, NSCopying>
{
	NSString * name;
	NSString * shortName;
	NSString * displayName;
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * shortName;
@property(nonatomic,retain) NSString * displayName;

@end

@interface MetaValue  : NSObject <NSCoding, NSCopying>
{
	NSString * value;
	NSString * shortValue;
	NSString * displayValue;
	//NSString * description;
}
@property(nonatomic,retain) NSString * value;
@property(nonatomic,retain) NSString * shortValue;
@property(nonatomic,retain) NSString * displayValue;
//@property(nonatomic,retain) NSString * description;

@end

@interface MetaNameValue : NSObject <NSCoding, NSCopying> {
	MetaName * name;
	MetaValue * value;
}
@property(nonatomic,retain) MetaName * name;
@property(nonatomic,retain) MetaValue * value;

@end
