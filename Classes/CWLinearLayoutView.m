//
//  CWLinearLayoutView.m
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

#import "CWLinearLayoutView.h"

@interface CWLinearLayoutView ()

@property(nonatomic, readonly, retain) NSMutableArray* managedSubviewsData;

@end


@interface CWLinearLayoutSubviewData : NSObject <NSCoding> {
@private
    UIView* _view;
    CWLinearLayoutRule _rule;
    CGFloat _space;
}

@property(nonatomic, retain) UIView* view;
@property(nonatomic, assign) CWLinearLayoutRule rule;
@property(nonatomic, assign) CGFloat space;

+(CWLinearLayoutSubviewData*)subviewWithView:(UIView*)view rule:(CWLinearLayoutRule)rule space:(CGFloat)space;

@end


@implementation CWLinearLayoutView

#pragma mark --- Properties

@synthesize padding = _padding;

-(void)setPadding:(CGFloat)padding;
{
	if (padding != _padding) {
    	_padding = padding;
        [self setNeedsLayout];
    }
}

-(NSArray*)managedSubviews;
{
	return [self valueForKeyPath:@"managedSubviewsData.view"];
}

-(NSMutableArray*)managedSubviewsData;
{
	if (_managedSubviews == nil) {
    	_managedSubviews = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return _managedSubviews;
}

#pragma mark --- Life cycle

-(instancetype)initWithCoder:(NSCoder *)aDecoder;
{
	self = [super initWithCoder:aDecoder];
    if (self) {
    	_managedSubviews = [[aDecoder decodeObjectForKey:@"views"] retain];
        self.padding = [aDecoder decodeFloatForKey:@"padding"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
	[super encodeWithCoder:aCoder];
    [aCoder encodeObject:_managedSubviews forKey:@"views"];
    [aCoder encodeFloat:self.padding forKey:@"padding"];
}

- (void)dealloc;
{
    [_managedSubviews release];
    [super dealloc];
}

#pragma mark --- Managed subviews

-(void)addManagedSubview:(UIView*)view rule:(CWLinearLayoutRule)rule space:(CGFloat)space;
{
	[self insertManagedSubview:view atIndex:[self.managedSubviewsData count] rule:rule space:space];    
}

-(void)insertManagedSubview:(UIView*)view atIndex:(NSUInteger)index rule:(CWLinearLayoutRule)rule space:(CGFloat)space;
{
    CWLinearLayoutSubviewData* subview = [CWLinearLayoutSubviewData subviewWithView:view rule:rule space:space];
	[self.managedSubviewsData addObject:subview];
    if (view) {
        [self addSubview:view];
    }
    [self setNeedsLayout];
}

-(void)removeManagedSubviewAtIndex:(NSUInteger)index;
{
	CWLinearLayoutSubviewData* subview = (self.managedSubviewsData)[index];
    [subview.view removeFromSuperview];
    [self.managedSubviewsData removeObjectAtIndex:index];
    [self setNeedsLayout];
}

#pragma mark --- Layout

-(void)setupWidths:(CGFloat*)pWidths forFixedAndExactSubviewsInTotalWidth:(CGFloat*)pTotalWidth;
{
    NSUInteger count = [self.managedSubviewsData count];
	for (int index = 0; index < count; index++) {
		CWLinearLayoutSubviewData* subview = (self.managedSubviewsData)[index];
        if (subview.rule == CWLinearLayoutRuleFixed) {
			CGFloat width = subview.space <= 0 ? subview.view.bounds.size.width : subview.space;
            pWidths[index] = width;
            (*pTotalWidth) -= width;
        }
        if (subview.rule == CWLinearLayoutRuleExactFit) {
        	CGFloat width = [subview.view sizeThatFits:CGSizeMake(self.bounds.size.width, self.bounds.size.height)].width;
            pWidths[index] = width;
            (*pTotalWidth) -= width;
        }
    }
}

-(void)setupWidths:(CGFloat*)pWidths forMaxFitsubviewsInTotalWidth:(CGFloat*)pTotalWidth;
{
    NSUInteger count = [self.managedSubviewsData count];
	for (int index = 0; index < count; index++) {
		CWLinearLayoutSubviewData* subview = (self.managedSubviewsData)[index];
        if (subview.rule == CWLinearLayoutRuleMaxFit) {
        	CGFloat width = [subview.view sizeThatFits:CGSizeMake(*pTotalWidth, self.bounds.size.height)].width;
            pWidths[index] = width;
            (*pTotalWidth) -= width;
        }
    }
}

-(void)setupWidths:(CGFloat*)pWidths forFlexibleSubviewsInTotalWidth:(CGFloat*)pTotalWidth;
{
    NSUInteger count = [self.managedSubviewsData count];
    CGFloat totalFlex = 0;
	for (int index = 0; index < count; index++) {
		CWLinearLayoutSubviewData* subview = (self.managedSubviewsData)[index];
        if (subview.rule == CWLinearLayoutRuleFlexible) {
            totalFlex += subview.space;
        }
    }
	for (int index = 0; index < count; index++) {
		CWLinearLayoutSubviewData* subview = (self.managedSubviewsData)[index];
        if (subview.rule == CWLinearLayoutRuleFlexible) {
            CGFloat width = (*pTotalWidth) * (subview.space / totalFlex);
        	pWidths[index] = width;
        }
    }
    *pTotalWidth = 0;
}

-(void)layoutSubviewsWithWidths:(CGFloat*)widths;
{
	CGFloat originX = 0;
    NSUInteger count = [self.managedSubviewsData count];
    for (int index = 0; index < count; index++) {
		CWLinearLayoutSubviewData* subview = (self.managedSubviewsData)[index];
        if (subview.view) {
			CGRect frame = subview.view.frame;
			frame.origin.x = originX;
            frame.size.width = widths[index];
            frame = CGRectIntegral(frame);
            subview.view.frame = frame;
        }
        originX += (widths[index] + self.padding);
    }
}

-(void)layoutSubviews;
{
    NSUInteger count = [self.managedSubviewsData count];
    if (count > 0) {
        CGFloat widths[count];
        for (int index = 0; index < count; index++) {
        	widths[index] = 0;
        }
		CGRect bounds = self.bounds;
    	CGFloat totalWidth = bounds.size.width - (count - 1) * self.padding;
		[self setupWidths:widths forFixedAndExactSubviewsInTotalWidth:&totalWidth];
        if (totalWidth > 0) {
        	[self setupWidths:widths forMaxFitsubviewsInTotalWidth:&totalWidth];
        }
        if (totalWidth > 0) {
        	[self setupWidths:widths forFlexibleSubviewsInTotalWidth:&totalWidth];
        }
		[self layoutSubviewsWithWidths:widths];
    }
}

@end

@implementation CWLinearLayoutSubviewData

@synthesize view = _view;
@synthesize rule = _rule;
@synthesize space = _space;

+(CWLinearLayoutSubviewData*)subviewWithView:(UIView*)view rule:(CWLinearLayoutRule)rule space:(CGFloat)space;
{
	CWLinearLayoutSubviewData* subview = [[[self alloc] init] autorelease];
    subview.view = view;
    subview.rule = rule;
    subview.space = space;
    return subview;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder;
{
	self = [self init];
    if (self) {
    	self.view = [aDecoder decodeObjectForKey:@"view"];
        self.rule = [aDecoder decodeIntForKey:@"rule"];
        self.space = [aDecoder decodeFloatForKey:@"space"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.view forKey:@"view"];
    [aCoder encodeInt:self.rule forKey:@"rule"];
    [aCoder encodeFloat:self.space forKey:@"space"];
}

-(void)dealloc;
{
	[_view release];
    [super dealloc];
}

@end

