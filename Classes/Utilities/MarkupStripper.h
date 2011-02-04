#import <Foundation/Foundation.h>


@interface MarkupStripper : NSObject {
	NSDictionary * tags;
	NSDictionary * codes;
}

- (NSString*) stripMarkup:(NSString*)s;
- (NSString*) stripMarkupSummary:(NSString*)s maxLength:(int)maxLength;

@end
