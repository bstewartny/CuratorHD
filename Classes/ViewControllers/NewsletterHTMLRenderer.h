//
//  NewsletterHTMLRenderer.h
//  Untitled
//
//  Created by Robert Stewart on 11/15/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemHTMLRenderer.h"

@class Newsletter;

@interface NewsletterHTMLRenderer : ItemHTMLRenderer {
	NSString * templateName;
	NSInteger pageWidth;
}
@property(nonatomic) NSInteger pageWidth;
@property(nonatomic,retain) NSString * templateName;
- (id) initWithTemplateName:(NSString*)templateName maxSynopsisSize:(int)maxSynopsisSize embedImageData:(BOOL)embedImageData;

- (NSString*) getHTML:(Newsletter*)newsletter;
- (NSString*) getHTMLPreview:(Newsletter*) newsletter maxItems:(int)maxItems;

@end
