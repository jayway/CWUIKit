//
//  CWCalloutView.m
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

#import "CWCalloutView.h"

#define kCWCalloutViewHeight (70.f)
#define kCWCalloutViewCapHeight (57.f)
#define kCWCalloutViewContentHeight (48.f)
#define kCWCalloutViewTitleTopInset (4.f)
#define kCWCalloutViewTitleSideInsets (10.f)
#define kCWCalloutViewCapWidth (17.f)
#define kCWCalloutViewMiddleWidth (41.f)
#define kCWCalloutViewTitleHeight (19.f)
#define kCWCalloutViewSubtitleHeight (17.f)
#define kCWCalloutViewAccessoryPadding (4.0f)

CGSize CWCalloutViewMinimumSize = {(CGFloat)(kCWCalloutViewCapWidth * 2 + kCWCalloutViewMiddleWidth), (CGFloat)kCWCalloutViewHeight};

@implementation CWCalloutView

#pragma mark --- Properties

@synthesize leftAccessoryView = _leftAccessoryView;
@synthesize rightAccessoryView = _rightAccessoryView;


-(NSString*)title;
{
	return _titleLabel.text;
}

-(void)setTitle:(NSString*)title;
{
	_titleLabel.text = title;
}

-(NSString*)subtitle;
{
	return _subtitleLabel.text;
}

-(void)setSubtitle:(NSString*)subtitle;
{
	_subtitleLabel.text = subtitle;
}

-(void)setLeftAccessoryView:(UIView*)view;
{
	if (_leftAccessoryView != view) {
		[_leftAccessoryView removeFromSuperview];
		_leftAccessoryView = view;
        if (view) {
			[self addSubview:view];
        }
    }
}

-(void)setRightAccessoryView:(UIView*)view;
{
	if (_rightAccessoryView != view) {
		[_rightAccessoryView removeFromSuperview];
		_rightAccessoryView = view;
        if (view) {
			[self addSubview:view];
        }
    }
}

#pragma mark --- Life cycle

-(void)setupPropertiesForLabel:(UILabel*)label;
{
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, -1);
    label.textAlignment = UITextAlignmentCenter;
    label.lineBreakMode = UILineBreakModeTailTruncation;
}

-(void)setupInternalState;
{
	_backgroundViews[0] =  [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"CWUIKitResources.bundle/calloutview_left.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:28] 
                                              highlightedImage:nil] autorelease];
    _backgroundViews[1] =  [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"CWUIKitResources.bundle/calloutview_middle.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:28] 
                                              highlightedImage:nil] autorelease];
    _backgroundViews[2] =  [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"CWUIKitResources.bundle/calloutview_right.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:28] 
                                              highlightedImage:nil] autorelease];
    for (int i = 0; i < 3; i++) {
    	[self addSubview:_backgroundViews[i]];
    }

    _titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 21)] autorelease];
    [self setupPropertiesForLabel:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 21)] autorelease];
    [self setupPropertiesForLabel:_subtitleLabel];
    _subtitleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [self addSubview:_subtitleLabel];

    [self setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame;
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, kCWCalloutViewCapWidth * 2 + kCWCalloutViewMiddleWidth, kCWCalloutViewHeight)])) {
		[self setupInternalState];
        frame.size.width = MAX(CWCalloutViewMinimumSize.width, frame.size.width);
        frame.size.height = MAX(CWCalloutViewMinimumSize.height, frame.size.height);
        self.frame = frame;
    }
    return self;
}

-(void)layoutSubviews;
{
    CGFloat width = self.bounds.size.width;
    CGFloat leftCapWidth = floorf((width - kCWCalloutViewMiddleWidth) / 2);
    CGRect frame = CGRectMake(0, 0, leftCapWidth, kCWCalloutViewCapHeight);
    _backgroundViews[0].frame = frame;
    
	frame = CGRectMake(leftCapWidth, 0, kCWCalloutViewMiddleWidth, kCWCalloutViewHeight);
    _backgroundViews[1].frame = frame;
    
    frame = CGRectMake(leftCapWidth + kCWCalloutViewMiddleWidth, 0, width - (leftCapWidth + kCWCalloutViewMiddleWidth), kCWCalloutViewCapHeight);
    _backgroundViews[2].frame = frame;
    
    frame = CGRectMake(kCWCalloutViewTitleSideInsets, kCWCalloutViewTitleTopInset, width - kCWCalloutViewTitleSideInsets * 2, kCWCalloutViewTitleHeight);
	if (_leftAccessoryView) {
    	CGRect leftFrame = frame;
        leftFrame.size = _leftAccessoryView.bounds.size;
        leftFrame.origin.y = floorf((kCWCalloutViewContentHeight - leftFrame.size.height) / 2);
        _leftAccessoryView.frame = leftFrame;
        frame.origin.x += (leftFrame.size.width + kCWCalloutViewAccessoryPadding);
        frame.size.width -= (leftFrame.size.width + kCWCalloutViewAccessoryPadding);
    }
	if (_rightAccessoryView) {
    	CGRect rightFrame = frame;
        rightFrame.size = _rightAccessoryView.bounds.size;
        rightFrame.origin.x = (frame.origin.x + frame.size.width) - rightFrame.size.width;
        rightFrame.origin.y = floorf((kCWCalloutViewContentHeight - rightFrame.size.height) / 2);
        _rightAccessoryView.frame = rightFrame;
        frame.size.width -= (rightFrame.size.width + kCWCalloutViewAccessoryPadding);
    }
    
    _titleLabel.frame = frame;

    frame.origin.y += kCWCalloutViewTitleHeight;
    frame.size.height = kCWCalloutViewSubtitleHeight;
	_subtitleLabel.frame = frame;
}


#pragma mark --- Public API
-(void)showFromAnchorPoint:(CGPoint)anchorPoint inView:(UIView*)view animated:(BOOL)animated;
{
    CGSize size = self.bounds.size;
	CGRect frame = CGRectMake(anchorPoint.x - floorf(size.width / 2), anchorPoint.y - size.height, size.width, size.height);
    self.frame = frame;
    if (self.superview == nil) {
        view.clipsToBounds = NO;
        [view addSubview:self];
    	if (animated && !_isAnimatingIn) {
 			self.alpha = 0;
            [UIView beginAnimations:@"Show" context:NULL];
            _isAnimatingIn = YES;
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(showAnimationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.2];
            self.alpha = 1;        
            [UIView commitAnimations];
        }
    }
}

-(void)dismissAnimated:(BOOL)animated;
{
    if (!_isAnimatingOut) {
        if (animated) {
            [UIView beginAnimations:@"Dismiss" context:NULL];
            _isAnimatingOut = YES;
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
            self.alpha = 0;
            [UIView commitAnimations];
        } else {
            [self removeFromSuperview];
        }
    }
}
    
- (void)showAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
	_isAnimatingIn = NO;    
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    _isAnimatingOut = NO;    
	[self dismissAnimated:NO];
}

@end
