//
//  CWColumnTableViewCell.m
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


#import "CWColumnTableViewCell.h"
#import "CWTableViewCellBackgroundView.h"
#import <CoreGraphics/CoreGraphics.h>

@interface CWColumnTableViewCell ()

@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIView *currentAccessoryView;

@end

@implementation CWColumnTableViewCell


#pragma mark --- Properties

@synthesize style = _style;
@synthesize tableViewStyle = _tableViewStyle;
@synthesize separatorStyle = _separatorStyle;
@synthesize separatorColor = _separatorColor;
@synthesize reuseIdentifier = _reuseIdentified;
@synthesize contentView = _contentView;
@synthesize backgroundView = _backgroundView;
@synthesize selectedBackgroundView = _selectedBackgroundView;
@synthesize accessoryView = _accessoryView;
@synthesize selected = _selected;
@synthesize highlighted = _highlighted;
@synthesize editing = _editing;

-(void)setBackgroundView:(UIView*)view;
{
    _backgroundViewForcedNil = view == nil;
    if (view) {
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.frame = self.bounds;
        [self insertSubview:view atIndex:0];
    }
    [_backgroundView removeFromSuperview];
    [_backgroundView autorelease];
    _backgroundView = [view retain];
}

-(UIView*)backgroundView;
{
	if (_backgroundView == nil && !_backgroundViewForcedNil && _tableViewStyle == UITableViewStyleGrouped) {
        CWTableViewCellBackgroundView* view = [CWTableViewCellBackgroundView backgroundViewWithTableViewStyle:self.tableViewStyle 
                                                                                               separatorStyle:self.separatorStyle];
        view.separatorColor = self.separatorColor;
        self.backgroundView = view;
    }
    return _backgroundView;
}

-(void)setSelectedBackgroundView:(UIView*)view;
{
    _selectedBackgroundViewForcedNil = view == nil;
    if (view) {
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.frame = self.bounds;
        BOOL inverted = _highlighted || _selected;
        view.alpha =  inverted ? 1 : 0;
        [self insertSubview:view belowSubview:_contentView];
    }
    [_selectedBackgroundView removeFromSuperview];
    [_selectedBackgroundView autorelease];
    _selectedBackgroundView = [view retain];
}

-(UIView*)selectedBackgroundView;
{
    if (_selectedBackgroundView == nil && !_selectedBackgroundViewForcedNil) {
        CWTableViewCellBackgroundView* view = [CWTableViewCellBackgroundView highlightedBackgroundViewWithTableViewStyle:self.tableViewStyle 
                                                                                                          separatorStyle:self.separatorStyle];
        view.separatorColor = self.separatorColor;
        self.selectedBackgroundView = view;
    }
    return _selectedBackgroundView;
}

-(UILabel*)textLabel;
{
	if (_textLabel == nil) {
    	_textLabel = [self defaultTextLabel];
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

-(UIImageView*)imageView;
{
	if (_imageView == nil) {
    	_imageView = [self defaultImageView];
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

-(UILabel*)detailTextLabel;
{
	if (_detailTextLabel == nil) {
    	_detailTextLabel = [self defaultDetailTextLabel];
        [self.contentView addSubview:_detailTextLabel];
    }
    return _detailTextLabel;
}

-(void)setSelected:(BOOL)selected;
{
	[self setSelected:selected animated:NO];
}

-(void)setHighlighted:(BOOL)highlighted;
{
	[self setHighlighted:highlighted animated:NO];
}

- (void)prepareForReuse;
{
	
}

#pragma mark --- View life cycle

-(void)setupDefaultValues;
{
    _contentView = [[UIView alloc] initWithFrame:self.frame];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.opaque = NO;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_contentView];
    self.backgroundColor = [UIColor clearColor];
}

-(void)awakeFromNib;
{
	[self setupDefaultValues];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
{
	self = [self initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        _style = style;
        _reuseIdentified = [reuseIdentifier copy];
        [self setupDefaultValues];
    }
    return self;
}

- (void)dealloc;
{
    [_backgroundView release];
    [_selectedBackgroundView release];
	[_reuseIdentified release];
    [super dealloc];
}

#pragma mark --- Manage accessory view

-(UIView*)currentAccessoryView;
{
	UIView* view = _accessoryView;
    if (view != _currentAccessoryView) {
    	[_currentAccessoryView removeFromSuperview];
        _currentAccessoryView = view;
        [self addSubview:view];
    }
    return _currentAccessoryView;
}

-(void)setAccessoryView:(UIView *)view;
{
	if (_accessoryView != view) {
    	[_accessoryView autorelease];
        _accessoryView = [view retain];
        [self setNeedsLayout];
    }
}

#pragma mark --- Manage selection and highlight

-(void)updateInvertedState:(BOOL)inverted forViewRecursivly:(UIView*)view;
{
	if ([view respondsToSelector:@selector(setHighlighted:)]) {
    	[(id)view setHighlighted:inverted];
    }
    for (UIView* subview in view.subviews) {
        [self updateInvertedState:inverted forViewRecursivly:subview];
    }
}

-(void)updateInvertedStateAsNeededAnimated:(BOOL)animated;
{
    if (animated) {
    	[UIView beginAnimations:@"HighlightCell" context:NULL];
        [UIView setAnimationDuration:0.1];
    }
    BOOL inverted = _highlighted || _selected;
    [self updateInvertedState:inverted forViewRecursivly:self.contentView];
    _selectedBackgroundView.alpha =  inverted ? 1 : 0;
    if (_textLabel) {
    	_textLabel.textColor = inverted ? [UIColor lightTextColor] : [self textLabelTextColor];
    }
    if (_detailTextLabel) {
		_detailTextLabel.textColor = inverted ? [UIColor lightTextColor] : [self detailTextLabelTextColor];        
    }
    if (animated) {
    	[UIView commitAnimations];
    }    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated;
{
    _selected = selected;
    [self updateInvertedStateAsNeededAnimated:animated];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
	_highlighted = highlighted;    
    [self updateInvertedStateAsNeededAnimated:animated];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated;
{
    if (_editing != editing) {
		_editing = editing;    
    	[self updateInvertedStateAsNeededAnimated:animated];
    }
}

#pragma mark --- Layout subviews

-(void)layoutSubviews;
{
    CGRect contentFrame = [self rectForContentView];
    _contentView.center = CGPointMake(contentFrame.origin.x + contentFrame.size.width / 2, 
                                      contentFrame.origin.y + contentFrame.size.height / 2);
    contentFrame.origin = CGPointZero;
    _contentView.bounds = contentFrame;
    //_contentView.frame = [self rectForContentView];
	[self currentAccessoryView].frame = [self rectForAccessoryView];
	if (_textLabel) {
    	_textLabel.frame = [self rectForTextLabel];
    }
    if (_imageView) {
    	_imageView.frame = [self rectForImageView];
    }
    if (_detailTextLabel) {
    	_detailTextLabel.frame = [self rectForDetailTextLabel];
    }
}

@end


@implementation CWColumnTableViewCell (CWSubviewOverrides)

-(UIColor*)textLabelTextColor;
{
	switch (self.style) {
        case UITableViewCellStyleValue2:
            return [UIColor colorWithRed:0.32f green:0.40f blue:0.57f alpha:1.00f];
    	default:
            return [UIColor darkTextColor];
    }
}

-(UIColor*)detailTextLabelTextColor;
{
	switch (self.style) {
		case UITableViewCellStyleValue1:
            return [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.00f];
        case UITableViewCellStyleSubtitle:
            return [UIColor colorWithWhite:0.50f alpha:1.00f];
    	default:
            return [UIColor darkTextColor];
    }
}


-(UILabel*)defaultTextLabel;
{
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [self textLabelTextColor];
    switch (self.style) {
		case UITableViewCellStyleValue2:
            label.font = [UIFont boldSystemFontOfSize:12.0f];
            label.textAlignment = UITextAlignmentRight;
            break;
        default:
            label.font = [UIFont boldSystemFontOfSize:17.0f];
            break;
    }
    return label;
}

-(UIImageView*)defaultImageView;
{
	CGRect smallRect = CGRectMake(0, 0, 25, 25);
	UIImageView* imageView = [[[UIImageView alloc] initWithFrame:smallRect] autorelease];
    return imageView;
}

-(UILabel*)defaultDetailTextLabel;
{
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [self detailTextLabelTextColor];
    switch (self.style) {
		case UITableViewCellStyleValue1:
            label.font = [UIFont systemFontOfSize:17.0f];
            label.textAlignment = UITextAlignmentRight;
            break;
        case UITableViewCellStyleValue2:
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            break;
        case UITableViewCellStyleSubtitle:
            label.font = [UIFont systemFontOfSize:14.0f];
            break;
        default:
            break;
    }
    return label;
}

@end


@implementation CWColumnTableViewCell (CWLayoutOverrides)

-(CGRect)rectForMainTextLabel:(BOOL)isMainTextLabel;
{
    CGRect bounds = _contentView.bounds;
    bounds = CGRectInset(bounds, 10, 0);
    CGRect imageRect = [self rectForImageView];
    if (imageRect.size.width > 0) {
        bounds.origin.x += imageRect.size.width + imageRect.origin.x;
        bounds.size.width -= imageRect.size.width + imageRect.origin.x;
    }
    CGSize size = _textLabel ? [_textLabel sizeThatFits:_textLabel.bounds.size] : CGSizeZero;
    CGSize detailSize = _detailTextLabel ? [_detailTextLabel sizeThatFits:_detailTextLabel.bounds.size] : CGSizeZero;
    CGRect rect = CGRectMake(bounds.origin.x, 0, size.width, size.height);        
    CGRect detailRect = CGRectMake(bounds.origin.x, 0, detailSize.width, detailSize.height);        
    switch (self.style) {
        case UITableViewCellStyleDefault:
            detailRect = CGRectZero;
            rect.size.width = bounds.size.width;
            rect.origin.y = (bounds.size.height - rect.size.height) / 2 + bounds.origin.y;
            break;
        case UITableViewCellStyleValue1:
        case UITableViewCellStyleValue2:
            rect.origin.y = (bounds.size.height - rect.size.height) / 2 + bounds.origin.y;
            detailRect.origin.y = (bounds.size.height - detailRect.size.height) / 2 + bounds.origin.y;
            if (self.style == UITableViewCellStyleValue1) {
                CGFloat fraction = bounds.size.width / (rect.size.width + detailRect.size.width);
                rect.size.width *= fraction;
            } else {
                rect.size.width = bounds.size.width / 4;
            }
            detailRect.origin.x = rect.origin.x + rect.size.width;
            detailRect.size.width = bounds.size.width - rect.size.width;
            break;
        case UITableViewCellStyleSubtitle:
            rect.size.width = detailRect.size.width = bounds.size.width;
            rect.origin.y = (bounds.size.height - (rect.size.height + detailRect.size.height)) / 2 + bounds.origin.y;
            detailRect.origin.y = rect.origin.y + rect.size.height;
            break;
    }
    rect = CGRectIntegral(rect);
    detailRect = CGRectIntegral(detailRect);
    return isMainTextLabel ? rect : detailRect;
}

-(CGRect)rectForTextLabel;
{
    if (_textLabel) {
        return [self rectForMainTextLabel:YES];
    }
    return CGRectZero;
}

-(CGRect)rectForImageView;
{
	if (_imageView && _imageView.image) {
        CGRect bounds = _contentView.bounds;
        CGSize size = _imageView.image.size;
		if (size.height > _contentView.bounds.size.height) {
			CGFloat factor = _contentView.bounds.size.height / size.height;
            size.height *= factor;
            size.width *= factor;
        }
        CGRect frame = CGRectMake(0, (bounds.size.height - size.height) / 2, size.width, size.height);
        frame = CGRectIntegral(frame);
        return frame;
    }
    return CGRectZero;
}

-(CGRect)rectForDetailTextLabel;
{
    if (_detailTextLabel) {
        return [self rectForMainTextLabel:NO];
    }
    return CGRectZero;
}

-(CGRect)rectForContentView;
{
	CGRect frame = self.bounds;
    CGRect accessoryRect = [self rectForAccessoryView];
    if (accessoryRect.size.width > 0) {
	    frame.size.width = accessoryRect.origin.x;
    }
    return frame;
}

-(CGRect)rectForAccessoryView;
{
	UIView* view = [self currentAccessoryView];
    if (view) {
    	CGRect bounds = self.bounds;
        CGSize size = view.bounds.size;
        CGRect frame = CGRectMake(bounds.size.width - (size.width + 8), (bounds.size.height - size.height) / 2, size.width, size.height);
        frame = CGRectIntegral(frame);
        return frame;
    }
    return CGRectZero;
}

@end
