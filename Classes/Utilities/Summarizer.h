//
//  Summarizer.h
//  Untitled
//
//  Created by Robert Stewart on 5/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextSegment : NSObject
{
	NSString * text;
	CGFloat weight;
}
@property(nonatomic,retain) NSString * text;
@property(nonatomic) CGFloat weight;
@end

@interface Summarizer : NSObject {

}
- (NSString*) summarizeBody:(NSString*)body withHeadline:(NSString*)headline;

- (NSString*) summarizeText:(NSString*)text keyWords:(NSArray*)keyWords;


@end
