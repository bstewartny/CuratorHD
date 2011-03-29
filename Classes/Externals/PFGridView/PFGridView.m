//
//  PFGridView.m
//  PFGridView
//
//  Created by YJ Park on 3/8/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFGridView.h"
#import "PFGridView+Internal.h"
#import "PFGridViewSection+Internal.h"

@implementation PFGridView
@synthesize dataSource;
@synthesize delegate;
@synthesize headerHeight;
@synthesize cellHeight;
@synthesize directionalLockEnabled;
@synthesize snapToGrid;
@synthesize snapToGridAnamationDuration;
@synthesize selectMode;
@synthesize selectAnimated;
@synthesize selectAnamationDuration;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    sections = [[NSMutableArray alloc] init];
    cellQueues = [[NSMutableDictionary alloc] init];
    headerHeight = 44.0f;
    cellHeight = 44.0f;    
    
    snapToGridAnamationDuration = 0.1f;
    selectAnamationDuration = 0.2f;
    selectAnimated = YES;
    
    [self setupGestures];
}

- (void)dealloc
{
    [sections release];
    [cellQueues release];
    [selectedCellIndexPath release];
    [super dealloc];
}

#pragma mark - public methods;
- (void)reloadData {
    [self reloadSections];
    [self setNeedsDisplay];
}

- (PFGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    PFGridViewCell *result = nil;

    NSMutableArray *queue = [cellQueues objectForKey:identifier];
    if (queue) {
        result = [[[queue lastObject] retain] autorelease];
        if (result) {
            [queue removeLastObject];
        }
    }

    return result;
}

- (PFGridViewSection *)section:(NSUInteger)sectionIndex {
    PFGridViewSection *result = nil;
    if (sectionIndex < sections.count) {
        result = [sections objectAtIndex:sectionIndex];
    }
    return result;
}

- (PFGridViewCell *) cellForColAtIndexPath:(PFGridIndexPath *)indexPath {
    PFGridViewCell *result = nil;
    PFGridViewSection *section = [self section:indexPath.section];
    if (section) {
        result = [section cellInView:section.gridView forColAtIndexPath:indexPath];
    }
    return result;
}

- (PFGridViewCell *) headerForColAtIndexPath:(PFGridIndexPath *)indexPath {
    PFGridViewCell *result = nil;
    PFGridViewSection *section = [self section:indexPath.section];
    if (section) {
        result = [section cellInView:section.headerView forColAtIndexPath:indexPath];
    }
    return result;    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (selectMode == PFGridViewSelectModeNone) {
        return NO;
    }
    return YES;
}

#pragma mark - seletion
- (PFGridIndexPath *)indexPathForSelectedCell {
    return selectedCellIndexPath;
}

- (void)selectCellAtIndexPath:(PFGridIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(PFGridViewScrollPosition)scrollPosition {
    if (indexPath == nil || [indexPath isEqual:selectedCellIndexPath]) return;

    if (selectedCellIndexPath) {
        if (delegate && [delegate respondsToSelector:@selector(gridView:didDeselectCellAtIndexPath:)]) {
            [delegate gridView:self didDeselectCellAtIndexPath:selectedCellIndexPath];
        }
        [selectedCellIndexPath release];
        selectedCellIndexPath = nil;
    }
    
    selectedCellIndexPath = [indexPath retain];
    
    if (delegate && [delegate respondsToSelector:@selector(gridView:didDeselectCellAtIndexPath:)]) {
        [delegate gridView:self didSelectCellAtIndexPath:selectedCellIndexPath];
    }
    [self scrollToCellAtIndexPath:selectedCellIndexPath animated:animated scrollPosition:scrollPosition];
}


@end
