//
//  AutocompleteTextField.h
//  Untitled
//
//  Created by Robert Stewart on 5/13/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kAutocompleteItemHeight 22
#define kAutocompleteItemFontSize 12

@interface AutocompleteItem:NSObject
{
	NSObject * value;
	NSString * display;
	UIButton * button;
	BOOL required;
	BOOL excluded;
}

@property(nonatomic,retain) NSObject * value;
@property(nonatomic,retain) NSString * display;
@property(nonatomic,retain) UIButton * button;
@property(nonatomic) BOOL required;
@property(nonatomic) BOOL excluded;

@end

@interface AutocompleteTextField : UIView <UIActionSheetDelegate>{
	UITextField * textField;
	UIScrollView * scrollView;
	UIButton * addButton;
	NSMutableArray * items;
	id delegate;
}

@property(nonatomic,retain) UITextField * textField;
@property(nonatomic,retain) UIScrollView * scrollView;
@property(nonatomic,retain) UIButton * addButton;
@property(nonatomic,retain) NSMutableArray * items;
@property(nonatomic,assign) id delegate;

- (void) ensureInitialized;

- (void) addItem:(NSObject*) value display:(NSString*)display;

@end

@interface NSObject (AutocompleteTextFieldDelegate) 
- (void)searchChanged:(AutocompleteTextField*)autocompleteTextField;
@end
