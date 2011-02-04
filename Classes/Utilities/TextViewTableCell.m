    //
//  TextViewTableCell.m
//  Untitled
//
//  Created by Robert Stewart on 2/24/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TextViewTableCell.h"


@implementation TextViewTableCell
@synthesize textView;

- (void)dealloc
{
    //  We're performing a delayed release here to give delegate notification 
    //  messages time to propagate. Specifically, MyDetailController implements
    //  the -textFieldDidEndEditing: delegate method, which is sent by an
    //  instance of NSNotificationCenter during the next event cycle. Without
    //  the delay, the textField would get released before the message is sent.
    //  But the textField is an argument to that method, so the method would 
    //  be passed an invalid reference, which would be likely to crash the app.
    //
    [textView performSelector:@selector(release)
					withObject:nil
					afterDelay:1.0];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier];
    
    if (self == nil)
    { 
        return nil;
    }
    
	CGRect rect=CGRectMake(10.0, 10.0, 640.0, 200.0);
	
	UITextView * _textView=[[UITextView alloc] initWithFrame:rect];
	
     
    //  Set the keyboard's return key label to 'Next'.
    //
    //[_textField setReturnKeyType:UIReturnKeyNext];
    
    //  Make the clear button appear automatically.
    //[_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    //[_textField setBackgroundColor:[UIColor whiteColor]];
    //[_textField setOpaque:YES];
    
	[_textView setBackgroundColor:[UIColor clearColor]];
	 
	//[_textView setOpaque:NO];
	
    [[self contentView] addSubview:_textView];
    self.textView=_textView;
    
    [_textView release];
    
    return self;
}

//  Disable highlighting of currently selected cell.
//
- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated 
{
    [super setSelected:selected animated:NO];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}



@end
