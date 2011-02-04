//
//  DocumentImage.m
//  Untitled
//
//  Created by Robert Stewart on 2/19/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "DocumentImage.h"


@implementation DocumentImage
@synthesize src,width,height,area,image;

- (UIImage *) getImage
{
	NSURL *url = [NSURL URLWithString:self.src];
	NSData *data = [NSData dataWithContentsOfURL:url];
	if(data)
	{
		UIImage *img = [[UIImage alloc] initWithData:data];
		
		return img;
	}
	return nil;
}

- (void)dealloc {
	[src release];
	[image release];
	[super dealloc];
}

@end
