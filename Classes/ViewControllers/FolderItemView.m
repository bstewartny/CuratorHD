#import "FolderItemView.h"


@implementation FolderItemView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

 CGContextRef context=UIGraphicsGetCurrentContext();
 
 // draw seperator line
 CGContextSetLineWidth(context,1);
 
 CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
 
 CGContextMoveToPoint(context,0,84);
 
 CGContextAddLineToPoint(context,rect.size.width,84);
 
 CGContextStrokePath(context);
 }


- (void)dealloc {
    [super dealloc];
}


@end
