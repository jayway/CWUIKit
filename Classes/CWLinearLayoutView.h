//
//  CWLinearLayoutView.h
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


typedef NS_ENUM(NSInteger, CWLinearLayoutRule) {
	CWLinearLayoutRuleFixed = 0,		//! A fixed space, use specified space, or views bounds if space is 0.0f.
	CWLinearLayoutRuleExactFit = 1,		//! Use exactly -[sizeThatFits:] space.
	CWLinearLayoutRuleMaxFit = 2,		//! Use -[sizeThatFits:] or less.
	CWLinearLayoutRuleFlexible = 3		//! Use a fraction of remaining space, space specifies importance. Aflexible view with 1.0 spave will get twice the space compared to a 0.5 view.
} ;

/*!
 * @abstract The CWLinearLayoutView provide support for automated layout of subviews.
 *
 * @discussion Subview as laid out lineary from left to right. Only the widths of 
 *			   the subviews are ever touched.
 *             Each subview is laidout using a rule, and space for the Fixed and 
 *             Flexible rules. The psace is ignored for subviews under the 
 *             ExactFit and MaxFit rules.
 *
 *			   Interface Builder plug-ins are not supported for iOS decuments, 
 *             therefor some manual setup is needed. This manual setup consist
 *             of explicitly setting subviews as managed subviews.
 *             Example:
 *             -(void)viewDidLoad {
 *			       [super viewDidLoad];
 *                 [self.layoutView addManagedSubview:self.label rule:CWLinearLayoutRuleExactFit space:0.0f];
 *                 [self.layoutView addManagedSubview:self.button rule:CWLinearLayoutRuleFlexible space:1.0f];
 *             }
 */
@interface CWLinearLayoutView : UIView {
@private
    NSMutableArray* _managedSubviews;
    CGFloat _padding;
}

/*!
 * @abstract Padding in points between subviews. Default is 0.0f.
 */
@property(nonatomic, assign) CGFloat padding;


/*!
 * @abstract The receivers emidiate managed subviews. Might be a subset of the subviews.
 * @discussion The order of managed subviews is not the same as the order of subviews.
 *			   The order of managed subviews only specify the layout order from left to right,
 *			   not the z-order of drawing.
 */
@property(nonatomic, readonly, copy) NSArray* managedSubviews;

/*!
 * @abstract Add a subview.
 * @discussion Shorthand for -[insertManagedSubview:atIndex:rule:space] at the very end.
 */
-(void)addManagedSubview:(UIView*)view rule:(CWLinearLayoutRule)rule space:(CGFloat)space;

/*!
 * @abstract Insert a managed subview at specified index.
 * @discussion View can be nill if rule is Flexible, this will insert a flexible space.
 *			   View will be added as subview to receiver, this might change the subviews actual index if
 *			   it already is a subview of the receiver.
 */
-(void)insertManagedSubview:(UIView*)view atIndex:(NSUInteger)index rule:(CWLinearLayoutRule)rule space:(CGFloat)space;

/*!
 *	@abstract Remove a managed subview at specified index.
 *  @discussion The removed managed subview will be removed from the receiver.
 */
-(void)removeManagedSubviewAtIndex:(NSUInteger)index;

@end
