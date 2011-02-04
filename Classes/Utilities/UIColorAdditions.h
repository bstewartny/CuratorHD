#import <Foundation/Foundation.h>

@interface UIColor (UIColorAdditions) 

+ (UIColor *)searchForColorByName:(NSString *)cssColorName;
+ (NSArray* )cssColorNames;

@end
