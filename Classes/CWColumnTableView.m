//
//  CWColumnTableView.m
//  CWUIKit
//  Created by Fredrik Olsson 
//
//  Copyright (c) 2011, Jayway AB All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Jayway AB nor the names of its contributors may 
//       be used to endorse or promote products derived from this software 
//       without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL JAYWAY AB BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "CWColumnTableView.h"
#import "CWTableViewCellBackgroundView.h"
#import "CWGeometry.h"

@interface CWColumnTableView () 

-(void)setupDefaultValues;

-(NSInteger)indexToSelectForSuggestedIndex:(NSInteger)index;
-(NSInteger)actualVisualPositionForPosition:(NSInteger)position;

-(CGRect)rectForPositionAtIndex:(NSInteger)position;

-(NSInteger)firstVisiblePosition;
-(NSInteger)lastVisiblePosition;
-(void)updateInternalCellCaches;
-(void)offerCellToReuseQueue:(CWColumnTableViewCell*)cell;

@end


@implementation CWColumnTableView


#pragma mark --- Properties

@synthesize style = _style;
@synthesize dataSource = _dataSource;
@dynamic delegate;
@synthesize numberOfColumns = _numberOfColumns;
@synthesize rowHeight = _rowHeight;
@synthesize minimumColumnWidth = _minimumColumnWidth;
@synthesize separatorStyle = _separatorStyle;
@synthesize separatorColor = _separatorColor;
@synthesize editing = _editing;
@synthesize minimumNumberOfRows = _minimumNumberOfRows;
@synthesize backgroundView = _backgroundView;
@synthesize tiledBackgroundImage = _tiledBackgroundImage;

-(void)setDataSource:(id<CWColumnTableViewDataSource>)dataSource;
{
	_dataSource = dataSource;
    _columnTableViewFlags.dataSourceHasCanMove = [dataSource respondsToSelector:@selector(columnTableView:canMovePositionAtIndex:)];
    _columnTableViewFlags.dataSourceHasMovePosition = [dataSource respondsToSelector:@selector(columnTableView:movePositionAtIndex:toIndex:)];
}

-(void)setDelegate:(id <CWColumnTableViewDelegate>)delegate;
{
	[super setDelegate:delegate];
    _columnTableViewFlags.delegateHasWillSelectPosition = [delegate respondsToSelector:@selector(columnTableView:willSelectPositionAtIndex:)];
    _columnTableViewFlags.delegateHasDidSelectPosition = [delegate respondsToSelector:@selector(columnTableView:didSelectPositionAtIndex:)];
    _columnTableViewFlags.delegateHasWillDeselectPosition = [delegate respondsToSelector:@selector(columnTableView:willDeselectPositionAtIndex:)];
    _columnTableViewFlags.delegateHasDidDeselectPosition = [delegate respondsToSelector:@selector(columnTableView:didDeselectPositionAtIndex:)];
	_columnTableViewFlags.delegateHasTargetIndexForMove = [delegate respondsToSelector:@selector(columnTableView:targetIndexForMoveFromPositionAtIndex:toProposedIndex:)];
    _columnTableViewFlags.delegateHasWillDisplayCell = [delegate respondsToSelector:@selector(columnTableView:willDisplayCell:forPositionAtIndex:)];
    _columnTableViewFlags.delegateHasBackgroundForRow = [delegate respondsToSelector:@selector(columnTableView:backgroundViewForRowAtIndex:)];
}

-(void)setMinimumNumberOfRows:(NSInteger)rows;
{
    if (_minimumNumberOfRows != rows) { 
		_minimumNumberOfRows = rows;
		[self setNeedsLayout];
    }
}

-(BOOL)isTracking;
{
	return _trackedTouch != nil || [super isTracking];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated;
{
	if (_editing != editing) {
    	_editing = editing;
        for (CWColumnTableViewCell* cell in [self visibleCells]) {
        	[cell setEditing:editing animated:animated];
        }
    }
}

-(void)setEditing:(BOOL)editing;
{
	[self setEditing:editing animated:NO];
}

-(NSInteger)numberOfRows;
{
    NSInteger rows = ([self numberOfPositions] + (self.numberOfColumns - 1)) / self.numberOfColumns;
	return MAX(1, rows);
}

-(NSInteger)numberOfColumns;
{
	if (_minimumColumnWidth != 0.0f) {
        NSInteger count = UIEdgeInsetsInsetRect(self.bounds, self.contentInset).size.width / _minimumColumnWidth;
        return MAX(1, count);
    } else {
    	return _numberOfColumns;
    }
}

-(void)setNumberOfColumns:(NSInteger)columns;
{
	_numberOfColumns = columns;
    [self setNeedsLayout];
}

-(void)setMinimumColumnWidth:(CGFloat)minWidth;
{
	_minimumColumnWidth = minWidth;
	[self setNeedsLayout];
}

-(void)setStyle:(UITableViewStyle)style;
{
	_style = style;
    switch (style) {
        case UITableViewStyleGrouped:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                self.backgroundColor = [UIColor groupTableViewBackgroundColor];
            } else {
				self.backgroundColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.89f alpha:1.0f];
            }
            break;
        default:
            self.backgroundColor = [UIColor whiteColor];
            break;
    }
}

-(void)setBackgroundView:(UIView *)view;
{
	if (_backgroundView) {
    	[_backgroundView removeFromSuperview];
    }
    _backgroundView = view;
    if (view) {
    	[self insertSubview:view atIndex:0];
    }
    [self setNeedsLayout];
}

-(void)setTiledBackgroundImage:(UIImage *)image;
{
    [_tiledBackgroundImage release];
    _tiledBackgroundImage = [image retain];
	if (image) {
    	UIView* view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)] autorelease];
        view.backgroundColor = [UIColor colorWithPatternImage:image];
        self.backgroundView = view;
    } else {
    	self.backgroundView = nil;	
    }
}


#pragma mark --- View livecycle

-(void)setupDefaultValues;
{
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    self.style = UITableViewStylePlain;
    self.rowHeight = 44.f;
    self.numberOfColumns = 2;
    _numberOfPositions = NSNotFound;
    self.alwaysBounceVertical = YES;
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorColor = [UIColor colorWithWhite:0.67f alpha:1.00f];
    _selectedIndex = NSNotFound;
    _highlightedIndex = NSNotFound;
    _sourceIndexForMove = NSNotFound;
    _destIndexForMove = NSNotFound;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
{
	self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultValues];
        self.style = style;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
	self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaultValues];
    }
    return self;
}

- (void)dealloc {
	if (_resuseableCells!=nil) {
		[_resuseableCells release];
		_resuseableCells = nil;
	}
	if (_visibleCells!=nil) {
		[_visibleCells release];
		_visibleCells = nil;
	}
	if (_indexesToInsertedAnimatedAtLayout!=nil) {
		[_indexesToInsertedAnimatedAtLayout release];
		_indexesToInsertedAnimatedAtLayout = nil;
	}
	if (_cellBeingMoved!=nil) {
		[_cellBeingMoved release];
		_cellBeingMoved = nil;
	}
    [_tiledBackgroundImage release];
    [super dealloc];
}

#pragma mark --- Public methods

-(NSInteger)positionIndexForCell:(CWColumnTableViewCell*)cell;
{
	NSInteger position = [_visibleCells indexOfObjectIdenticalTo:cell];
    if (position != NSNotFound) {
		position += _firstVisibleCell;        
    }
    return position;
}

-(NSInteger)positionIndexForCellAtPoint:(CGPoint)point;
{
    NSInteger numberOfPositions = [self numberOfPositions];
    if (numberOfPositions > 0) {
        UIEdgeInsets insets = self.contentInset;
        point.y -= (insets.top);
        point.x -= (insets.left);
        CGFloat width = floorf((self.frame.size.width - (insets.left + insets.right)) / self.numberOfColumns);
        int row = point.y / (self.rowHeight);
        int col = point.x / (width);
        if (col >= 0 && col < self.numberOfColumns) {
        	int position = col + row * self.numberOfColumns;
            if (position >= 0 && position < numberOfPositions) {
	            return position;
            }
        }
    }
    return NSNotFound;
}

-(NSInteger)numberOfPositions;
{
    if (_numberOfPositions == NSNotFound) {
		_numberOfPositions = [self.dataSource numberOfPositionsInColumnTableView:self];
    }
    return _numberOfPositions;
}

-(UIView*)backgroundViewForRowIndex:(NSInteger)rowIndex;
{
	if (!_backgroundRowViews) {
		_backgroundRowViews = [[NSMutableArray alloc] initWithCapacity:2];
	}
	if (rowIndex < [_backgroundRowViews count]) {
		return [_backgroundRowViews objectAtIndex:rowIndex];
	} else if (_columnTableViewFlags.delegateHasBackgroundForRow) {
		UIView* rowBackgroundView = [self.delegate columnTableView:self backgroundViewForRowAtIndex:rowIndex];
		[_backgroundRowViews insertObject:rowBackgroundView atIndex:rowIndex];
		return rowBackgroundView;
	}
	return nil;
}

-(CWColumnTableViewCell*)cellForPositionAtIndex:(NSInteger)position;
{
	if (position < 0 || position >= [self numberOfPositions]) {
    	[NSException raise:NSInvalidArgumentException format:@"Position %d ouside of range 0..%d", [self numberOfPositions] - 1];
    } else {
        if (position == _sourceIndexForMove && _cellBeingMoved != nil) {
        	return _cellBeingMoved;
        }
        [self updateInternalCellCaches];
 		NSInteger lookupIndex = position - _firstVisibleCell;
        if (lookupIndex >= 0 && lookupIndex < [_visibleCells count]) {
            BOOL isNewCell = [_indexesToInsertedAnimatedAtLayout containsIndex:position];
            BOOL animationsEnabled = [UIView areAnimationsEnabled];
        	CWColumnTableViewCell* cell = [_visibleCells objectAtIndex:lookupIndex];
            [UIView setAnimationsEnabled:NO];
            if ([cell isKindOfClass:[NSNull class]]) {
            	cell = [self.dataSource columnTableView:self cellForPositionAtIndex:position];
                cell.tableViewStyle = self.style;
                cell.separatorColor = self.separatorColor;
                cell.separatorStyle = self.separatorStyle;
                [cell setEditing:[self isEditing] animated:NO];
                [_visibleCells replaceObjectAtIndex:lookupIndex withObject:cell];
            }
            if (_columnTableViewFlags.delegateHasWillDisplayCell) {
                [self.delegate columnTableView:self willDisplayCell:cell forPositionAtIndex:position];
            }
            (void)cell.backgroundView;
            (void)cell.selectedBackgroundView;
            [cell setSelected:position == _selectedIndex];
            NSInteger actualVisualPosition = [self actualVisualPositionForPosition:position];
            CGRect frame = [self rectForPositionAtIndex:actualVisualPosition];
            if (isNewCell) {
                cell.frame = frame;
				cell.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                cell.alpha = 0;
                [UIView setAnimationsEnabled:animationsEnabled];
            	cell.alpha = 1;
                cell.transform = CGAffineTransformIdentity;
            } else {
                [UIView setAnimationsEnabled:animationsEnabled];
                cell.frame = frame;
            }
            return cell;
        }
    }
    return nil;
}

-(CWColumnTableViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier;
{
	NSMutableArray* cellsForIdentifier = [_resuseableCells objectForKey:identifier];
    id cell = [cellsForIdentifier lastObject];
    if (cell) {
    	[[cell retain] autorelease];
		[cellsForIdentifier removeLastObject];
		if ([cellsForIdentifier count] == 0) {
			[_resuseableCells removeObjectForKey:identifier];
		}
        [cell prepareForReuse];
    }
    return cell;
}

-(NSArray*)visibleCells;
{
    return [_visibleCells filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) 
             { 
                 return [evaluatedObject isKindOfClass:[CWColumnTableViewCell class]];
             }]];
}

-(void)reloadData;
{
    _numberOfPositions = NSNotFound;
    for (CWColumnTableViewCell* cell in _visibleCells) {
    	[self offerCellToReuseQueue:cell];
    }
	[_visibleCells release];
    _visibleCells = nil;
    _lastFirstVisiblePosition = NSNotFound;
    _lastLastVisiblePosition = NSNotFound;
    _lastSize = CGSizeZero;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

-(BOOL)didPerformLayoutSubviews;
{
	return _didPerformLayoutSubviews;
}


#pragma mark --- Highlight helpers

-(void)setHighlighted:(BOOL)highlighted forPositionAtIndex:(NSInteger)position;
{
    if (position != NSNotFound) {
		CWColumnTableViewCell* cell = [self cellForPositionAtIndex:position];
        [cell setHighlighted:highlighted animated:YES];
        _highlightedIndex = highlighted ? position : NSNotFound;
    }
}

#pragma mark --- Move helpers

-(NSInteger)actualVisualPositionForPosition:(NSInteger)position;
{
	if (_cellBeingMoved && _sourceIndexForMove != _destIndexForMove) {
		if (_destIndexForMove < _sourceIndexForMove) {
        	if (position >= _destIndexForMove && position < _sourceIndexForMove) {
            	position++;
            }
        } else {
        	if (position <= _destIndexForMove && position > _sourceIndexForMove) {
            	position--;
            }
        }
    }
    return position;
}

-(NSInteger)sourceIndexForMoveAtIndex:(NSInteger)index;
{
	if (_columnTableViewFlags.dataSourceHasMovePosition) {
        if (_columnTableViewFlags.dataSourceHasCanMove) {
			if (![self.dataSource columnTableView:self canMovePositionAtIndex:index]) {
            	return NSNotFound;
            }
        }
        return index;
    }
    return NSNotFound;
}

-(void)beginMovingPosition;
{
	[self setHighlighted:NO forPositionAtIndex:_sourceIndexForMove];
    self.scrollEnabled = NO;
	_cellBeingMoved = [[self cellForPositionAtIndex:_sourceIndexForMove] retain];
    [self bringSubviewToFront:_cellBeingMoved];
    
    [UIView beginAnimations:@"MoveBack" context:NULL];
    _cellBeingMoved.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    _cellBeingMoved.alpha = 0.75f;
    [UIView commitAnimations];
}

-(void)insertCellBeingMovedAtIndex:(NSInteger)destIndex;
{
    [UIView beginAnimations:@"MoveBack" context:NULL];
    _cellBeingMoved.transform = CGAffineTransformIdentity;
	_cellBeingMoved.frame = [self rectForPositionAtIndex:destIndex];
    _cellBeingMoved.alpha = 1.0f;
	[UIView commitAnimations];
    if (destIndex != _sourceIndexForMove) {
        [self.dataSource columnTableView:self movePositionAtIndex:_sourceIndexForMove toIndex:_destIndexForMove];
        _sourceIndexForMove -= _firstVisibleCell;
        _destIndexForMove -= _firstVisibleCell;
        [_visibleCells removeObjectAtIndex:_sourceIndexForMove];
        [_visibleCells insertObject:_cellBeingMoved atIndex:_destIndexForMove];
    }
    [self setNeedsLayout];
    _lastSize = CGSizeZero;
    [_cellBeingMoved release];
    _cellBeingMoved = nil;
	_sourceIndexForMove = _destIndexForMove = NSNotFound;
    self.scrollEnabled = YES;
}


#pragma mark --- Manage subviews

-(void)layoutSubviews;
{
	_didPerformLayoutSubviews = NO;
    NSInteger firstVisiblePosition = [self firstVisiblePosition];
    NSInteger lastVisiblePosition = [self lastVisiblePosition];
    CGSize size = self.bounds.size;
	UIEdgeInsets insets = self.contentInset;

    if (_backgroundView) {
        CGRect frame;
        if (_tiledBackgroundImage) {
            CGSize size = self.bounds.size;
            CGFloat tileHeight = _tiledBackgroundImage.size.height;
            size.height = (floorf(size.height / tileHeight) + 2) * tileHeight;
            CGPoint offset = self.contentOffset;
            offset.y = floorf(offset.y / tileHeight) * tileHeight;
            frame.origin = offset;
            frame.size = size;
        } else {
            frame = self.bounds;
        }
	    _backgroundView.frame = frame;
    	[self sendSubviewToBack:_backgroundView];
    }
    
	int minNumberOfRows = MAX(self.numberOfRows, self.minimumNumberOfRows);	
	for (int rowIndex = 0; rowIndex < minNumberOfRows; rowIndex++) {
		if (_columnTableViewFlags.delegateHasBackgroundForRow) {
			UIView* backgroundView = [self backgroundViewForRowIndex:rowIndex];
			if ([backgroundView superview] == nil) {
				[self insertSubview:backgroundView atIndex:0];
			}
			backgroundView.frame = CGRectMake(0, (rowIndex)*self.rowHeight + insets.top, self.bounds.size.width, self.rowHeight);
		}					
	}
	
	for (int index = minNumberOfRows; index < [_backgroundRowViews count]; index++) {
		[[_backgroundRowViews objectAtIndex:index] removeFromSuperview];
	}
	
    BOOL shouldDoLayout = _cellBeingMoved != nil || firstVisiblePosition != _lastFirstVisiblePosition || lastVisiblePosition != _lastLastVisiblePosition || !CGSizeEqualToSize(_lastSize, size);
	
    if (shouldDoLayout) {
        _didPerformLayoutSubviews = YES;
		_lastFirstVisiblePosition = firstVisiblePosition;
        _lastLastVisiblePosition = lastVisiblePosition;
        _lastSize = size;
        if (lastVisiblePosition != NSNotFound) {
            int lastPosition = [self numberOfPositions] - 1;
            int lastRow = ([self numberOfPositions] - 1) / self.numberOfColumns;
            int lastCol = self.numberOfColumns - 1;

            UIEdgeInsets insets = self.contentInset;
            CGSize contentSize = CGSizeMake(self.bounds.size.width - (insets.left + insets.right), (lastRow + 1) * self.rowHeight + (insets.top + insets.bottom));
            self.contentSize = contentSize;
			
            for (int position = firstVisiblePosition; position <= [self lastVisiblePosition]; position++) {
                if (_cellBeingMoved != nil && position == _sourceIndexForMove) {
                	continue;
                }
                CWColumnTableViewCell* cell = [self cellForPositionAtIndex:position];
                NSInteger actualVisualPosition = [self actualVisualPositionForPosition:position];
                if ([cell superview] == nil) {
                    [self addSubview:cell];
                }
                int row = actualVisualPosition / self.numberOfColumns;
                int col = actualVisualPosition % self.numberOfColumns;


                CWRectEdge edges = 0;
                if (row == 0) {
                    edges |= CWRectEdgeTop;
                }
                if (row == lastRow || (actualVisualPosition + self.numberOfColumns > lastPosition)) {
                    edges |= CWRectEdgeBottom;
                }
                if (col == 0) {
                    edges |= CWRectEdgeLeft;
                }
                if (col == lastCol || actualVisualPosition == lastPosition) {
                    edges |= CWRectEdgeRight;
                }
                
                id backgroundView = cell.backgroundView;
                if ([backgroundView isKindOfClass:[CWTableViewCellBackgroundView class]]) {
                    [backgroundView setFreeEdges:edges];
                }
                backgroundView = cell.selectedBackgroundView;
                if ([backgroundView isKindOfClass:[CWTableViewCellBackgroundView class]]) {
                    [backgroundView setFreeEdges:edges];
                }
            }
            if (_cellBeingMoved) {
                CWColumnTableViewCell* cell = _cellBeingMoved;
                [self bringSubviewToFront:cell];
            	CGRect frame = [self rectForPositionAtIndex:_sourceIndexForMove];
                CGPoint center = CWCGRectCenter(frame);
                CGSize distance = CWCGPointDictance(_sourcePointForMove, _currentPointForMove);
                center.x += distance.width;
                center.y += distance.height;
                cell.center = center;
                CWRectEdge edges = CWRectEdgeAllEdges;
                id backgroundView = cell.backgroundView;
                if ([backgroundView isKindOfClass:[CWTableViewCellBackgroundView class]]) {
                    [backgroundView setFreeEdges:edges];
                }
                backgroundView = cell.selectedBackgroundView;
                if ([backgroundView isKindOfClass:[CWTableViewCellBackgroundView class]]) {
                    [backgroundView setFreeEdges:edges];
                }
            }                
        }
    }
    [_indexesToInsertedAnimatedAtLayout release];
    _indexesToInsertedAnimatedAtLayout = nil;
}

#pragma mark --- Manage touches


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if (_trackedTouch == nil) {
        _trackedTouch = [[touches anyObject] retain];
        CGPoint point = [_trackedTouch locationInView:self];
        NSInteger position = [self positionIndexForCellAtPoint:point];
        _sourceIndexForMove = _destIndexForMove = [self sourceIndexForMoveAtIndex:position];
        if (_sourceIndexForMove != NSNotFound) {
            _sourcePointForMove = _currentPointForMove = point;
            NSTimeInterval triggerDelay = [self isEditing] ? 0.2 : 1.0;
            [self performSelector:@selector(beginMovingPosition) withObject:nil afterDelay:triggerDelay];
        }
        if (_columnTableViewFlags.delegateHasWillSelectPosition) {
            position = [self.delegate columnTableView:self willSelectPositionAtIndex:position]; 
        }
        [self setHighlighted:YES forPositionAtIndex:position];
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if ([touches containsObject:_trackedTouch]) {
        if (_sourceIndexForMove != NSNotFound) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self 
                                                     selector:@selector(beginMovingPosition) 
                                                       object:nil];
            if (_cellBeingMoved) {
                [self insertCellBeingMovedAtIndex:_sourceIndexForMove];
                goto insertDone;
            }
        }
        [self setHighlighted:NO forPositionAtIndex:_highlightedIndex];
    insertDone:
        [_trackedTouch release];
        _trackedTouch = nil;
    }
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if ([touches containsObject:_trackedTouch]) {
        if (_sourceIndexForMove != NSNotFound) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self 
                                                     selector:@selector(beginMovingPosition) 
                                                       object:nil];
            if (_cellBeingMoved) {
                [self insertCellBeingMovedAtIndex:_destIndexForMove];
				goto insertDone;
            }
        }
        if (_highlightedIndex != NSNotFound) {
            [self selectPositionAtIndex:_highlightedIndex animated:YES];
        }
        [self setHighlighted:NO forPositionAtIndex:_highlightedIndex];
    insertDone:
        [_trackedTouch release];
        _trackedTouch = nil;
    }
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if ([touches containsObject:_trackedTouch]) {
        [self setHighlighted:NO forPositionAtIndex:_highlightedIndex];
        if (_cellBeingMoved) {
            _currentPointForMove = [_trackedTouch locationInView:self];
            NSInteger proposedIndex = [self positionIndexForCellAtPoint:_currentPointForMove];
            proposedIndex = MIN(proposedIndex, [self numberOfPositions] - 1);
            if (_columnTableViewFlags.delegateHasTargetIndexForMove) {
                proposedIndex = [self.delegate columnTableView:self targetIndexForMoveFromPositionAtIndex:_sourceIndexForMove toProposedIndex:proposedIndex];
            }
            if (proposedIndex != _destIndexForMove) {
                _destIndexForMove = proposedIndex;
            }
            [UIView beginAnimations:@"MovePositions" context:NULL];
            [self layoutSubviews];
            [UIView commitAnimations];
        }
    }
    [super touchesMoved:touches withEvent:event];
}


#pragma mark --- Managing selections

-(NSInteger)indexToSelectForSuggestedIndex:(NSInteger)index;
{
	if (_columnTableViewFlags.delegateHasWillSelectPosition) {
    	return [self.delegate columnTableView:self willSelectPositionAtIndex:index];
    }
    return index;
}

-(NSInteger)indexOfSelectedPosition;
{
	return _selectedIndex;
}

-(void)selectPositionAtIndex:(NSInteger)index animated:(BOOL)animated;
{
    index = [self indexToSelectForSuggestedIndex:index];
    if (index != NSNotFound && index != _selectedIndex) {
        if (_selectedIndex != NSNotFound) {
            [self deselectPositionAtIndex:_selectedIndex animated:animated];
        }
		[[self cellForPositionAtIndex:index] setSelected:YES animated:animated];
        _selectedIndex = index;
        if (_columnTableViewFlags.delegateHasDidSelectPosition) {
			[self.delegate columnTableView:self didSelectPositionAtIndex:index];            
        }
    }
}

-(void)deselectPositionAtIndex:(NSInteger)index animated:(BOOL)animated;
{
    if (index != NSNotFound) {
        if (_columnTableViewFlags.delegateHasWillDeselectPosition) {
        	[self.delegate columnTableView:self willDeselectPositionAtIndex:index];
        }
		[[self cellForPositionAtIndex:index] setSelected:NO animated:animated];
        if (_columnTableViewFlags.delegateHasDidDeselectPosition) {
        	[self.delegate columnTableView:self didDeselectPositionAtIndex:index];
        }
    }
    _selectedIndex = NSNotFound;
}

#pragma mark --- Manage positions deletion

-(void)beginUpdates;
{
	if (_updateCount == 0) {
        _updateCount = 2;
        _deferedReloadIndexes = [[NSMutableIndexSet alloc] init];
        _deferedDeleteIndexes = [[NSMutableIndexSet alloc] init];
        _deferedInsertIndexes = [[NSMutableIndexSet alloc] init];
    } else {
    	_updateCount++;
    }
}

-(void)endUpdates;
{
	_updateCount--;
    if (_updateCount == 1) {
        NSUInteger prevLastVisibleCell = _lastVisibleCell;
    	[self reloadPositionsAtIndexes:_deferedReloadIndexes];
        [self deletePositionsAtIndexes:_deferedDeleteIndexes animated:YES];
        [self insertPositionsAtIndexes:_deferedInsertIndexes animated:YES];
        if (_numberOfPositions != NSNotFound) {
            NSInteger targetNumberOfPositions = _numberOfPositions;
        	targetNumberOfPositions -= [_deferedDeleteIndexes count];
            targetNumberOfPositions += [_deferedInsertIndexes count];
            _numberOfPositions = NSNotFound;
            if (targetNumberOfPositions != [self numberOfPositions]) {
                [NSException raise:NSInternalInconsistencyException 
                            format:@"Expected %d positions after deleting %d and inserting %d positions, was %d", 
                 targetNumberOfPositions, [_deferedDeleteIndexes count], [_deferedInsertIndexes count], [self numberOfPositions]];
            }
        }
        [_deferedReloadIndexes release], _deferedReloadIndexes = nil;
        [_deferedDeleteIndexes release], _deferedDeleteIndexes = nil;
        [_deferedInsertIndexes release], _deferedInsertIndexes = nil;
        _updateCount = 0;
        _lastSize = CGSizeZero;
        if (prevLastVisibleCell != NSNotFound && prevLastVisibleCell != _lastVisibleCell) {
        	NSInteger deltaRows = (_lastVisibleCell - prevLastVisibleCell) / _numberOfColumns;
            if (deltaRows != 0) {
            	CGPoint contentOffset = self.contentOffset;
                contentOffset.y += deltaRows * _rowHeight;
                self.contentOffset = contentOffset;
            }
        }
        [self layoutSubviews];
    }
}

-(void)insertPositionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
{
    if (_updateCount > 1) {
    	[_deferedInsertIndexes addIndexes:indexes];
        return;
    }
    _indexesToInsertedAnimatedAtLayout = [indexes copy];
    if (_firstVisibleCell != NSNotFound && _lastVisibleCell != NSNotFound) {
        if (_updateCount == 0) {
            NSInteger targetNumberOfPositions = _numberOfPositions == NSNotFound ? [self numberOfPositions] : _numberOfPositions + [indexes count];
            _numberOfPositions = NSNotFound;
            if (targetNumberOfPositions != [self numberOfPositions]) {
                [NSException raise:NSInternalInconsistencyException 
                            format:@"Expected %d positions after inserting %d positions, was %d", targetNumberOfPositions, [indexes count], [self numberOfPositions]];
            }
        }
		for (NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
	        if (index < _firstVisibleCell) {
                _firstVisibleCell++;
                _lastVisibleCell++;
            } else if (index <= _lastVisibleCell) {
                [self offerCellToReuseQueue:[_visibleCells lastObject]];
                if ([_visibleCells count]!=0) {
                    [_visibleCells removeLastObject];
                }
				[_visibleCells insertObject:[NSNull null] atIndex:index - _firstVisibleCell];
            } else {
                // Do nothing.
            }
        }
        if (animated) {
        	[UIView beginAnimations:@"InsertPositions" context:NULL];
        }
        if (_updateCount == 0) {
            _lastSize = CGSizeZero;
            [self layoutSubviews];  
        }
        if (animated) {
        	[UIView commitAnimations];
        }
    } else {
        NSLog(@"No known cells, just do reload");
		[self reloadData];        
    }
}

-(void)deletePositionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
{
    if (_updateCount > 1) {
    	[_deferedDeleteIndexes addIndexes:indexes];
        return;
    }
    if (_firstVisibleCell != NSNotFound && _lastVisibleCell != NSNotFound) {
        if (animated) {
        	[UIView beginAnimations:@"DeletePositions" context:NULL];
        }
        if (_updateCount == 0) {
            NSInteger targetNumberOfPositions = _numberOfPositions == NSNotFound ? [self numberOfPositions] : _numberOfPositions - [indexes count];
            _numberOfPositions = NSNotFound;
            if (targetNumberOfPositions != [self numberOfPositions]) {
                [NSException raise:NSInternalInconsistencyException 
                            format:@"Expected %d positions after deleting %d positions, was %d", targetNumberOfPositions, [indexes count], [self numberOfPositions]];
            }
        }
		for (NSUInteger index = [indexes lastIndex]; index != NSNotFound; index = [indexes indexLessThanIndex:index]) {
	        if (index < _firstVisibleCell) {
                _firstVisibleCell--;
            } else if (index <= _lastVisibleCell) {
                CWColumnTableViewCell* cell = [_visibleCells objectAtIndex:index - _firstVisibleCell];
                if (animated) {
                    cell.alpha = 0.0;
                	cell.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                    [cell performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
                } else {
                	[self offerCellToReuseQueue:cell];
                }
				[_visibleCells removeObjectAtIndex:index - _firstVisibleCell];
                [_visibleCells addObject:[NSNull null]];
            } else {
                // Do nothing.
            }
        }
		while (_lastVisibleCell >= _numberOfPositions) {
        	[_visibleCells removeLastObject];
            _lastVisibleCell--;
        }
        if (_updateCount == 0) {
        	_lastSize = CGSizeZero;
			[self layoutSubviews];
        }
        if (animated) {
        	[UIView commitAnimations];
        }
    } else {
        NSLog(@"No known cells, just do reload");
		[self reloadData];        
    }
}

-(void)reloadPositionsAtIndexes:(NSIndexSet*)indexes;
{
    if (_updateCount > 1) {
    	[_deferedReloadIndexes addIndexes:indexes];
        return;
    }
	if (_firstVisibleCell != NSNotFound && _lastVisibleCell != NSNotFound) {
        for (NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
            if (index >= _firstVisibleCell && index <= _lastVisibleCell) {
                CWColumnTableViewCell* cell = [_visibleCells objectAtIndex:index - _firstVisibleCell];
                [self offerCellToReuseQueue:cell];
				[_visibleCells replaceObjectAtIndex:index - _firstVisibleCell withObject:[NSNull null]];
            }
        }
        if (_updateCount == 0) {
        	_lastSize = CGSizeZero;
        	[self layoutSubviews];
        }
    } else {
        NSLog(@"No known cells, just do reload");
		[self reloadData];        
    }
}


#pragma mark --- Scrolling the column table view

-(void)scrollToPositionAtIndex:(NSInteger)index animated:(BOOL)animated;
{
	CGRect targetRect = [self rectForPositionAtIndex:index];
    CGPoint offset = self.contentOffset;
    CGFloat distance = MIN(targetRect.origin.y - offset.y, 0);
    if (distance == 0) {
    	distance = MAX((targetRect.origin.y + targetRect.size.height) - (offset.y + self.bounds.size.height), 0);
    }
    if (distance != 0) {
        offset.y += distance;
    	[self setContentOffset:offset animated:animated];
    }
}

#pragma mark --- Private helpers

-(void)setContentInset:(UIEdgeInsets)insets;
{
    _overriddenContentInset = insets;
	_overriddenContentInset = insets;
    _lastFirstVisiblePosition = NSNotFound;
    [self setNeedsLayout];
}

-(UIEdgeInsets)contentInset;
{
    UIEdgeInsets insets = _overriddenContentInset;
    if (self.style == UITableViewStyleGrouped) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            insets = UIEdgeInsetsMake(insets.top + 30, insets.left + 44, insets.bottom + 30, insets.right + 44);
            //			insets = UIEdgeInsetsMake(30, 44, 30, 44);            
        } else {
            insets = UIEdgeInsetsMake(insets.top + 10, insets.left + 10, insets.bottom + 10, insets.right + 10);
            //			insets = UIEdgeInsetsMake(10, 10, 10, 10);            
        }
    }
	return insets;
}

-(CGRect)rectForPositionAtIndex:(NSInteger)position;
{
	int row = position / self.numberOfColumns;
    int col = position % self.numberOfColumns;
    UIEdgeInsets insets = self.contentInset;
    CGFloat contentWidth = self.bounds.size.width - (insets.left + insets.right);
    CGFloat width = floorf(contentWidth / self.numberOfColumns);
    CGRect frame = CGRectMake(col * width + insets.left, row * self.rowHeight + insets.top, width, self.rowHeight - (self.style == UITableViewStyleGrouped ? 0 : 1));
    return frame;
}

-(NSInteger)firstVisiblePosition;
{
    if ([self numberOfPositions] > 0) {
        CGPoint offset = self.contentOffset;
        offset.y -= self.contentInset.top;
        int row = offset.y / (self.rowHeight);
        int position = row * self.numberOfColumns;
        position = MAX(0, MIN(position, [self numberOfPositions] - 1));
        return position;
    } else {
    	return NSNotFound;
    }
}

-(NSInteger)lastVisiblePosition;
{
    if ([self numberOfPositions] > 0) {
        CGPoint offset = self.contentOffset;
        offset.y += self.frame.size.height;
        offset.y -= self.contentInset.top;
        int row = offset.y / (self.rowHeight);
        int position = row * self.numberOfColumns + (self.numberOfColumns - 1);
        position = MAX(0, MIN(position, [self numberOfPositions] - 1));
        return position;
    } else {
    	return NSNotFound;
    }
}

-(void)updateInternalCellCaches;
{
	NSInteger firstVisibleCell = [self firstVisiblePosition];
    NSInteger lastVisibleCell = [self lastVisiblePosition];
	if (firstVisibleCell > _lastVisibleCell || lastVisibleCell < _firstVisibleCell) {
		for (CWColumnTableViewCell* cell in _visibleCells) {
			[self offerCellToReuseQueue:cell];
		}
		[_visibleCells release];
		_visibleCells = nil;
	}
	if (_visibleCells) {
		if (firstVisibleCell < _firstVisibleCell) {
			for (int i = 0; i < (_firstVisibleCell - firstVisibleCell); i++) {
				[_visibleCells insertObject:[NSNull null] atIndex:0];
			}
			_firstVisibleCell = firstVisibleCell;
		}
		if (firstVisibleCell > _firstVisibleCell) {
			for (int i = 0; i < (firstVisibleCell - _firstVisibleCell); i++) {
				[self offerCellToReuseQueue:[_visibleCells objectAtIndex:0]];
				[_visibleCells removeObjectAtIndex:0];
			}
			_firstVisibleCell = firstVisibleCell;
		}
        if (lastVisibleCell > _lastVisibleCell) {
        	for (int i = 0; i < (lastVisibleCell - _lastVisibleCell); i++) {
            	[_visibleCells addObject:[NSNull null]];
            }
            _lastVisibleCell = lastVisibleCell;
        }
        if (lastVisibleCell < _lastVisibleCell) {
            for (int i = 0; i < (_lastVisibleCell - lastVisibleCell); i++) {
            	[self offerCellToReuseQueue:[_visibleCells lastObject]];
                [_visibleCells removeLastObject];
            }
            _lastVisibleCell = lastVisibleCell;
        }
    } else {
    	_visibleCells = [[NSMutableArray alloc] initWithCapacity:(lastVisibleCell - firstVisibleCell) + 1];
		for (int i = 0; i < (lastVisibleCell - firstVisibleCell) + 1; i++) {
        	[_visibleCells addObject:[NSNull null]];
        }
        _firstVisibleCell = firstVisibleCell;
        _lastVisibleCell = lastVisibleCell;
    }
}

-(void)offerCellToReuseQueue:(CWColumnTableViewCell*)cell;
{
	if (!_resuseableCells) {
		_resuseableCells = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
    // This is needed because _visibleCells has NSNull for unfetched cells.
    if ([cell isKindOfClass:[CWColumnTableViewCell class]]) {
        if (cell.reuseIdentifier) {
			NSMutableArray* cellsForIdentifier = [_resuseableCells objectForKey:cell.reuseIdentifier];
			if (!cellsForIdentifier) {
				cellsForIdentifier = [[[NSMutableArray alloc] initWithCapacity:self.numberOfColumns] autorelease];
			}
            NSUInteger maxCells = ceilf(self.bounds.size.height / self.rowHeight + 1) * self.numberOfColumns;
			if ([cellsForIdentifier count] < maxCells) {
				[cellsForIdentifier addObject:cell];
			}
            [_resuseableCells setObject:cellsForIdentifier forKey:cell.reuseIdentifier];        
        }
        [cell removeFromSuperview];
    }
}

@end