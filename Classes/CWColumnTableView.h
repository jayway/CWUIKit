//
//  CWColumnTableView.h
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


#import <UIKit/UIKit.h>
#import "CWColumnTableViewCell.h"

@protocol CWColumnTableViewDataSource;

@class CWColumnTableView;

/*!
 * @abstract Delegate protocol for responding to CWColumnTableView actions.
 *
 * @discussion A delegate can also help with reordering cells, and prepare
 *             last minutute custmizations to cells.
 */
@protocol CWColumnTableViewDelegate <UIScrollViewDelegate>

@optional
/*!
 * @abstract Tell the delegate that the column table view is about to select a position.
 *
 * @discussion Implementations should return the index provided to go ahead with proposed selection.
 *             Return any other index to select an alternate position, or NSNotFound to cancel selection.
 */
-(NSInteger)columnTableView:(CWColumnTableView*)columnTableView willSelectPositionAtIndex:(NSInteger)index;

/*!
 * @abstract Tell the delegate that the column table view has selected a position.
 */
-(void)columnTableView:(CWColumnTableView*)columnTableView didSelectPositionAtIndex:(NSInteger)index;

/*!
 * @abstract Tell the delegate that the column table view will deselct a position.
 *
 * @discussion Implementations should return the index provided to go ahead with proposed deselection.
 *             CWColumnTableView do not support multiple selections, so returning an alternate index is not supported.
 *             Returning NSNotFound will cancel the deselection.
 */
-(NSInteger)columnTableView:(CWColumnTableView*)columnTableView willDeselectPositionAtIndex:(NSInteger)index;

/*!
 * @abstract Tell the delegate that the column table view has deselected a position.
 */
-(void)columnTableView:(CWColumnTableView*)columnTableView didDeselectPositionAtIndex:(NSInteger)index;

/*!
 * @abstract Ask the delegate to return a new index to propose a new target for moving a position.
 *
 * @discussion Implementing this method allows the delegate to forbid placements of surten positions,
 *             for example moving and data position above a surten header position. 
 */
-(NSInteger)columnTableView:(CWColumnTableView*)columnTableView targetIndexForMoveFromPositionAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestIndex;

/*!
 * @abstract Tell the delegate thhat the column table view is about to display a particular position.
 *
 * @discussion The table view sends this message just before displaying the cell. Use this callback to
 *             to override state-based properties set by the column table view. For example a
 *             custom background view.
 */
-(void)columnTableView:(CWColumnTableView*)columnTableView willDisplayCell:(CWColumnTableViewCell*)cell forPositionAtIndex:(NSInteger)index;


/*!
 * @abstract Provide a background view for the row 
 */
-(UIView*)columnTableView:(CWColumnTableView*)columnTableView backgroundViewForRowAtIndex:(NSInteger)index;


@end


/*!
 * @abstract CWColumnTableView works like an UITableView with added support for multiple columns.
 *
 * @discussion Column table view do not have support for hiarchical data, meaning all information
 *             is contained in a single section.
 *             Where table view uses an NSIndexPath to identify a piece of information, column
 *             table view uses a NSInteger position index.
 *
 *             Column table view is designed both in it's API and it's visual appearance to
 *             mimic a UIKit table view as closely as possible. A CWColumnTableView table view 
 *             configured with a single column is indistinguishable from a a UITableView.
 */
@interface CWColumnTableView : UIScrollView {
@private
    UITableViewStyle _style;
	id<CWColumnTableViewDataSource> _dataSource;
    NSInteger _numberOfColumns;
    CGFloat _rowHeight;
    CGFloat _minimumColumnWidth;
    UITableViewCellSeparatorStyle _separatorStyle;
    UIColor* _separatorColor;
    NSInteger _numberOfPositions;
    NSMutableDictionary* _resuseableCells;
    NSMutableArray* _visibleCells;
    NSInteger _firstVisibleCell;
    NSInteger _lastVisibleCell;
    NSInteger _selectedIndex;
    NSInteger _highlightedIndex;
    CGSize _lastSize;
    NSInteger _lastFirstVisiblePosition;
	NSInteger _lastLastVisiblePosition;
    BOOL _didPerformLayoutSubviews;
    UIEdgeInsets _overriddenContentInset;
    NSIndexSet* _indexesToInsertedAnimatedAtLayout;
    NSMutableIndexSet* _deferedReloadIndexes;
    NSMutableIndexSet* _deferedDeleteIndexes;
    NSMutableIndexSet* _deferedInsertIndexes;
    NSInteger _updateCount;
    BOOL _editing;
    UITouch* _trackedTouch;
    NSInteger _sourceIndexForMove;
    NSInteger _destIndexForMove;
    CGPoint _sourcePointForMove;
    CGPoint _currentPointForMove;
    CWColumnTableViewCell* _cellBeingMoved;
	NSMutableArray* _backgroundRowViews;
	NSInteger _minimumNumberOfRows;
    UIView* _backgroundView;
    UIImage* _tiledBackgroundImage;
    struct {
    	unsigned int delegateHasWillSelectPosition:1;
    	unsigned int delegateHasDidSelectPosition:1;
    	unsigned int delegateHasWillDeselectPosition:1;
    	unsigned int delegateHasDidDeselectPosition:1;
        unsigned int delegateHasTargetIndexForMove:1;
        unsigned int delegateHasWillDisplayCell:1;
    	unsigned int delegateHasBackgroundForRow:1;
		unsigned int dataSourceHasCanMove:1;
		unsigned int dataSourceHasMovePosition:1;
    } _columnTableViewFlags;
}

/*!
 * @abstract The style of the column table view.
 * @discussion All styles supported by UITableView are supported.
 */
@property (nonatomic, assign) UITableViewStyle style;

/*!
 * @abstract The object that acts as the receivers data source.
 */
@property (nonatomic, assign) IBOutlet id<CWColumnTableViewDataSource> dataSource;

/*!
 * @abstract The object that acts as the receivers delegate.
 */
@property (nonatomic, assign) IBOutlet id<CWColumnTableViewDelegate> delegate;

/*!
 * @abstract The number of columns to display.
 *
 * @discussion Default is 2 columns. Setting the number of columns in an animation block
 *             will animate to the new layout. Use for example from willAnimateRotationToInterfaceOrientation:duration:
 *             to change between different number of columns in portrait and landscape mode.
 */
@property (nonatomic, assign) NSInteger numberOfColumns;

/*!
 * @abstract Query for the current number of rows.
 */
@property (nonatomic, readonly, assign) NSInteger numberOfRows;

/*!
 * @abstract The row height.
 * 
 * @discussion Default is 44 points.
 */
@property (nonatomic, assign) CGFloat rowHeight;


/*!
 * @abstract A minumum column width to use, or 0.0f to respect numberOfRows property.
 *
 * @discussion Setting minumum column width to greater than 0 will result in a
 *             dynamic number of column by fitting as many columns as possible
 *             into current bounds and still respect the minimum requested width.
 */
@property (nonatomic, assign) CGFloat minimumColumnWidth; 

/*!
 * @abstract The style of lines separating the column table view cells.
 * @discussion All styles supported by UITableView are supported.
 */
@property (nonatomic, assign) UITableViewCellSeparatorStyle separatorStyle;

/*!
 * @abstract The color of the lines separating the column table view cells.
 * @discussion Default is a light gray (67% white).
 */
@property (nonatomic, retain) UIColor* separatorColor;

/*!
 * @abstract Determine whether the receiver is in editing mode.
 * @discussion Is compatible with a UIViewControllers editButonItem.
 *             Use custom CWColumnTableViewCells for visually representing
 *             editing mode. The timeout for hold-to move a position is
 *             drastically reduced in editing mode.
 */
@property (nonatomic, getter=isEditing, assign) BOOL editing;


/*!
 * @abstract The minumum number of rows that will be presented
 * @discussion	Default is zero. Set this to show rows even if the 
 *				column table view is empty.
 */
@property (nonatomic, assign) NSInteger minimumNumberOfRows;


/*!
 * @abstract A static background view behind cells and row background views.
 */
@property (nonatomic, retain) UIView* backgroundView;


/*!
 * @abstract An image to tile and scroll behind contents
 */
@property (nonatomic, retain) UIImage* tiledBackgroundImage;


/*!
 * @abstract Set editing mode, optionally in an animated fashion.
 */
-(void)setEditing:(BOOL)editing animated:(BOOL)animated;


/*!
 * @abstract The designated initializer.
 */
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;

/*!
 * @abstract Return the position index for a cell, or NSNotFound if not currently visible.
 */
-(NSInteger)positionIndexForCell:(CWColumnTableViewCell*)cell;

/*!
 * @abstract Return the position index for a point, or NSNotFound if no cell at target point.
 */
-(NSInteger)positionIndexForCellAtPoint:(CGPoint)point;

/*!
 * @abstract Return the number of positions.
 */
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger numberOfPositions;

/*!
 * @abstract Return the cell for a position index, or nil if position index is not visible.
 */
-(CWColumnTableViewCell*)cellForPositionAtIndex:(NSInteger)position;

/*!
 * @abstract Returns a reusable cell object located by its identifier.
 * @discussion Uses same logic as UITableView.
 */
-(CWColumnTableViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier;

/*!
 * @abstract Return the position index of the selection position, or NSNotFound if no selection.
 */
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger indexOfSelectedPosition;

/*!
 * @abstract Select position at index.
 */
-(void)selectPositionAtIndex:(NSInteger)index animated:(BOOL)animated;

/*!
 * @abstract Deselect position at index.
 */
-(void)deselectPositionAtIndex:(NSInteger)index animated:(BOOL)animated;

/*!
 * @abstract Begin a batch of animated insert, deletes and reloads.
 *
 * @discussion The logic for batched inserts are identical to how UITableView
 *			   handles batches. That is all inserts, deletes and reloads are
 *			   are queued until endUpdates, at which time the updates are
 *             performed in this order:
 *				1. All reloads atomically - reload indexes refer to the original indexes.
 *			    2. All deletes atomically - delete indexes refers to the original indexes.
 *              3. All inserts atomically - insert indexes refers to indexes as they are after any deletes in the batch.
 *              4. The number of objects in the model is asserted to match the number of deletes and inserts.
 */
-(void)beginUpdates;

/*!
 * @abstract End and commit a batch of animated inserts, deleted and reloads.
 */
-(void)endUpdates;

/*!
 * @abstract Insert new positions at the indexes identified by the index set.
 */
-(void)insertPositionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

/*!
 * @abstract Delete the positions at the indexes identified by the index set.
 */
-(void)deletePositionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

/*!
 * @abstract Reload the positions at the indexes identified by the index set.
 */
-(void)reloadPositionsAtIndexes:(NSIndexSet*)indexes;

/*!
 * @abstract Scroll the receiver if needed until a particulat position index is fully visible on screen.
 */
-(void)scrollToPositionAtIndex:(NSInteger)index animated:(BOOL)animated;

/*!
 * @abstract Return an array with all currently visible cells.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *visibleCells;

/*!
 * @abstract Invalidate all data, and reload from data source.
 */
-(void)reloadData;

/*!
 * @abstract Query if the last call to layoutSubviews did result in a new layout.
 * 
 * @discussion Only valid to call from withing layoutSubview after calling the super implementaion
 *             in a subclass of CWColumnTableView.
 *             Use to determine if new layout is needed for sub-classes with complex view hiarchies.
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL didPerformLayoutSubviews;

@end


/*!
 * @abstract Data source protocol for CWColumnTableView.
 * 
 * @discussion The data source is implemented by the mediator between the applications
 *             data model and a column table view.
 *             The required methods are used to provide the column table view with
 *             CWColumnTableViewCells to display, and the number of positions to display.
 *             The optional methods can be implemented to support drag and drop reordering.
 */
@protocol CWColumnTableViewDataSource <NSObject>

@required
/*!
 * @abstract Ask the data source for the number of positions in the data model.
 */
-(NSInteger)numberOfPositionsInColumnTableView:(CWColumnTableView*)columnTableView;

/*!
 * @abstract Ask the data source for a cell to represent a position index from the data source.
 *
 * @discussion This method is frequently called and must be fast with low overhead.
 *             Same rules as for UITableView applies!
 */
-(CWColumnTableViewCell*)columnTableView:(CWColumnTableView*)columnTableView cellForPositionAtIndex:(NSInteger)index;

@optional
/*!
 * @abstract Ask the data source whether a given position can be moved.
 *
 * @discussion By defuault all positions are movable if columnTableView:movePositionAtIndex:toIndex:
 *             is implemented.
 */
-(BOOL)columnTableView:(CWColumnTableView*)columnTableView canMovePositionAtIndex:(NSInteger)index;

/*!
 * @abstract Tells the data source to move a postion from one index to another in the data model.
 *
 * @discussion This message is sent when the user have moved a position. Only method that must
 *             be implemented to support re-ordering.
 */
-(void)columnTableView:(CWColumnTableView*)columnTableView movePositionAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destIndex;

@end
