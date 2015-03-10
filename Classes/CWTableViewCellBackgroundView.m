//
//  CWTableViewCellBackgroundView.m
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


#import "CWTableViewCellBackgroundView.h"
#import <CoreGraphics/CoreGraphics.h>

UIRectCorner CWRectCornerFromRectEdge(CWRectEdge edge) {
	UIRectCorner corners = 0;
    if (edge & CWRectEdgeTop) {
        if (edge & CWRectEdgeLeft) {
	    	corners |= UIRectCornerTopLeft;
        }
        if (edge & CWRectEdgeRight) {
			corners |= UIRectCornerTopRight;            
        }
    }
    if (edge & CWRectEdgeBottom) {
        if (edge & CWRectEdgeLeft) {
	    	corners |= UIRectCornerBottomLeft;
        }
        if (edge & CWRectEdgeRight) {
			corners |= UIRectCornerBottomRight;            
        }
    }
    return corners;
}

@implementation CWTableViewCellBackgroundView

#pragma mark --- Properties

@synthesize tableViewStyle = _tableViewStyle;
@synthesize separatorStyle = _separatorStyle;
@synthesize inset = _inset;
@synthesize freeEdges = _freeEdges;
@synthesize roundedCornerRadii = _roundedCornerRadii;
@synthesize topGradientColor = _topGradientColor;
@synthesize bottomGradientColor = _bottomGradientColor;
@synthesize separatorColor = _separatorColor;
@synthesize etchedSeparatorColor = _etchedSeparatorColor;


-(void)setFreeEdges:(CWRectEdge)edges;
{
    if (_freeEdges != edges) {
		_freeEdges = edges;
    	[self setNeedsDisplay];
    }
}

-(void)setNeedsDisplayInRect:(CGRect)rect;
{
	[super setNeedsDisplayInRect:rect];
}

-(void)setNeedsDisplay;
{
	[super setNeedsDisplay];
}


+(CWTableViewCellBackgroundView*)backgroundViewWithTableViewStyle:(UITableViewStyle)tableViewStyle separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;
{
	CWTableViewCellBackgroundView* view = [[[self alloc] initWithTableViewStyle:tableViewStyle 
                                                                 separatorStyle:separatorStyle] autorelease];
	switch (tableViewStyle) {
		case UITableViewStyleGrouped:
        	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            	view.topGradientColor = [UIColor colorWithWhite:0.97f alpha:1.00f];
            }
            view.roundedCornerRadii = CGSizeMake(10, 10);
            // Intentional fallthrough
        default:
            switch (separatorStyle) {
                case UITableViewCellSeparatorStyleSingleLineEtched:
					view.etchedSeparatorColor = [UIColor colorWithWhite:0.88f alpha:1];                    
                    // Intentional fallthrough
            	case UITableViewCellSeparatorStyleSingleLine:
                    view.separatorColor = [UIColor colorWithWhite:0.67f alpha:1];
                    break;
                default:
                    break;
            }
    }
    return view;
}

+(CWTableViewCellBackgroundView*)highlightedBackgroundViewWithTableViewStyle:(UITableViewStyle)tableViewStyle separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;
{
	CWTableViewCellBackgroundView* view = [[[self alloc] initWithTableViewStyle:tableViewStyle 
                                                                 separatorStyle:separatorStyle] autorelease];
	view.topGradientColor = [UIColor colorWithRed:0.02f green:0.55f blue:0.96f alpha:1.00f];
	view.bottomGradientColor = [UIColor colorWithRed:0.00f green:0.36f blue:0.90f alpha:1.00f];
	switch (tableViewStyle) {
		case UITableViewStyleGrouped:
            view.roundedCornerRadii = CGSizeMake(10, 10);
            //view.inset = UIEdgeInsetsMake(1, 1, 1, 1);
            break;
        default:
            switch (separatorStyle) {
                case UITableViewCellSeparatorStyleSingleLineEtched:
					view.etchedSeparatorColor = [UIColor colorWithWhite:0.88f alpha:1];                    
                    // Intentional fallthrough
            	case UITableViewCellSeparatorStyleSingleLine:
                    view.separatorColor = [UIColor colorWithWhite:0.67f alpha:1];
                    break;
                default:
                    break;
            }
    }
    view.alpha = 0;
	return view;
}

-(instancetype)initWithTableViewStyle:(UITableViewStyle)tableViewStyle separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;
{
	self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        self.opaque = NO;
        self.clearsContextBeforeDrawing = NO;
        self.backgroundColor = [UIColor clearColor];
    	self.tableViewStyle = tableViewStyle;
        self.separatorStyle = separatorStyle;
        self.topGradientColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    CGContextRef c = UIGraphicsGetCurrentContext();
	rect = UIEdgeInsetsInsetRect(rect, self.inset);
    UIRectCorner corners = CWRectCornerFromRectEdge(self.freeEdges);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:self.roundedCornerRadii];
    [path addClip];
    if (_bottomGradientColor) {
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)@[(id)_topGradientColor.CGColor, (id)_bottomGradientColor.CGColor], (CGFloat[]){0.0f, 1.0f});
        CGContextDrawLinearGradient(c, gradient, rect.origin, CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
		CGGradientRelease(gradient);
		CGColorSpaceRelease(space);
    } else {
        [_topGradientColor setFill];
        [path fill];
    }
    CGRect drawRect = rect;
    if (self.freeEdges & CWRectEdgeBottom) {
    	drawRect.size.height--;
    }
    if (self.freeEdges & CWRectEdgeRight) {
    	drawRect.size.width--;
    }
    path = [UIBezierPath bezierPathWithRoundedRect:drawRect byRoundingCorners:corners cornerRadii:self.roundedCornerRadii];
	switch (self.separatorStyle) {
		case UITableViewCellSeparatorStyleSingleLineEtched:
            // Intentional fallthrough
		case UITableViewCellSeparatorStyleSingleLine:
            [path applyTransform:CGAffineTransformMakeTranslation(0.5f, 0.5f)];
            [_separatorColor setStroke];
            [path stroke];
            break;
        default:
            break;
    }
}

- (void)dealloc;
{
    [_topGradientColor release];
    [_bottomGradientColor release];
    [_separatorColor release];
    [_etchedSeparatorColor release];
    [super dealloc];
}


@end