//
//  CWStyledSegmentedControl.m
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

#import "CWStyledSegmentedControl.h"
#import "UIImage+CWAdditions.h"


@implementation CWStyledSegmentedControl

-(NSInteger)selectedSegmentIndex;
{
	return _selectedSegmentIndex;
}

-(void)setSelectedSegmentIndex:(NSInteger)index;
{
	if (index != _selectedSegmentIndex) {
    	if (_selectedSegmentIndex != NSNotFound) {
        	[_buttons[_selectedSegmentIndex] setSelected:NO];
        }
        _selectedSegmentIndex = index;
    	if (_selectedSegmentIndex != NSNotFound) {
        	[_buttons[_selectedSegmentIndex] setSelected:YES];
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


-(instancetype)initWithItems:(NSArray*)items stretchableBackgroundImage:(UIImage*)backgroundImage stretchableSelectedBackgroundImage:(UIImage*)selectedBackgroundImage stretchableDividerImage:(UIImage*)dividerImage;
{    
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
		_selectedSegmentIndex = NSNotFound;
        UIImage* middleImage = [backgroundImage stretchableImageFromMiddleOfImage];
        UIImage* selectedMiddleImage = [selectedBackgroundImage stretchableImageFromMiddleOfImage];
        NSInteger buttonCount = [items count];
        NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:buttonCount];
        NSMutableArray* dividers = [NSMutableArray arrayWithCapacity:buttonCount - 1];
        for (NSInteger buttonIndex = 0; buttonIndex < buttonCount; buttonIndex++) {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            [button addTarget:self 
                       action:@selector(touchUpInsideForButton:)
             forControlEvents:UIControlEventTouchUpInside];
            button.tag = buttonIndex;
            id item = items[buttonIndex];
            if ([item isKindOfClass:[UIImage class]]) {
            	[button setImage:item forState:UIControlStateNormal];
            } else {
                [button setTitle:item forState:UIControlStateNormal];
            }
            UIImage* bgImage = nil;
            UIImage* selBGImage = nil;
            if (buttonIndex == 0) {
            	if (buttonCount == 1) {
                	bgImage = backgroundImage;
                    selBGImage = selectedBackgroundImage;
                } else {
                    bgImage = [backgroundImage stretchableImageFromLeftCapOfImage];
                    selBGImage = [selectedBackgroundImage stretchableImageFromLeftCapOfImage];
                }
            } else if (buttonIndex < (buttonCount - 1)) {
                bgImage = middleImage;
                selBGImage = selectedMiddleImage;
            } else {
                bgImage = [backgroundImage stretchableImageFromRightCapOfImage];
                selBGImage = [selectedBackgroundImage stretchableImageFromRightCapOfImage];
            }
            [button setBackgroundImage:bgImage forState:UIControlStateNormal];
            [button setBackgroundImage:selBGImage forState:UIControlStateSelected];
            [button setBackgroundImage:selBGImage forState:UIControlStateHighlighted];
            [buttons addObject:button];
            [self addSubview:button];
            if (buttonIndex < (buttonCount - 1)) {
            	UIImageView* divider = [[[UIImageView alloc] initWithImage:dividerImage] autorelease];
                [dividers addObject:divider];
                [self addSubview:divider];
            }
        }
        _buttons = [buttons copy];
        _dividers = [dividers copy];
        self.selectedSegmentIndex = 0;
        [self sizeToFit];
        [self setNeedsLayout];
    }
    return self;
}

- (void)dealloc;
{
    [_buttons release];
    [_dividers release];
    [super dealloc];
}


-(void)setTitleFont:(UIFont*)font;
{
	[_buttons setValue:font forKeyPath:@"titleLabel.font"];
}

-(void)setTitleShadowOffset:(CGSize)offset;
{
	[_buttons setValue:[NSValue valueWithCGSize:offset] forKeyPath:@"titleLabel.shadowOffset"];
}

-(void)setReversesTitleShadowWhenHighlighted:(BOOL)reverses;
{
	[_buttons setValue:@(reverses) forKey:@"reversesTitleShadowWhenHighlighted"];   
}

-(void)setTitleColor:(UIColor*)color forState:(UIControlState)state;
{
	for (UIButton* button in _buttons) {
    	[button setTitleColor:color forState:state];
    }
}

-(void)setTitleShadowColor:(UIColor*)color forState:(UIControlState)state;
{
	for (UIButton* button in _buttons) {
    	[button setTitleShadowColor:color forState:state];
    }
}



-(void)touchUpInsideForButton:(UIButton*)button;
{
	self.selectedSegmentIndex = button.tag;
}


-(CGSize)sizeThatFits:(CGSize)size;
{
	CGSize maxSize = CGSizeZero;
    for (UIButton* button in _buttons) {
    	CGSize s = [button sizeThatFits:size];
        maxSize.width = MAX(maxSize.width, s.width);
        maxSize.height = MAX(maxSize.height, s.height);
    }
    CGSize totalSize = CGSizeMake(maxSize.width * [_buttons count], maxSize.height);
    if ([_dividers count] > 0) {
    	UIImageView* divider = _dividers[0];
        CGSize s = [divider sizeThatFits:size];
        totalSize.width += MAX(1, s.width) * [_dividers count];
        totalSize.height = MAX(totalSize.height, s.height);
    }
    CGSize resultSize = CGSizeMake(MIN(totalSize.width, size.width),
                                   MIN(totalSize.height, size.height));
    return resultSize;
}


-(void)layoutSubviews;
{
	CGRect bounds = self.bounds;
    CGFloat widthLeft = bounds.size.width;
    CGFloat leftOffset = 0;
    CGFloat dividerWith = 0;
    if ([_dividers count] > 0) {
    	dividerWith = MAX(1, [_dividers[0] sizeThatFits:bounds.size].width);
        widthLeft -= dividerWith * [_dividers count];
    }
    NSInteger buttonCount = [_buttons count];
    CGFloat buttonWidth = (int)(widthLeft / buttonCount);
    for (NSInteger buttonIndex = 0; buttonIndex < buttonCount; buttonIndex++) {
        BOOL isLast = buttonIndex == (buttonCount - 1);
        CGRect frame = CGRectMake(leftOffset, 
                                  0, 
                                  isLast ? widthLeft : buttonWidth, 
                                  bounds.size.height);
        leftOffset += frame.size.width;
        widthLeft -= frame.size.width;
        [_buttons[buttonIndex] setFrame:frame];
        if (!isLast) {
        	frame = CGRectMake(leftOffset, 0, dividerWith, bounds.size.height);
            leftOffset += dividerWith;
            [_dividers[buttonIndex] setFrame:frame];
        }
    }
}


@end
