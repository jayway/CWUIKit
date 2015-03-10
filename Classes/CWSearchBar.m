//
//  CWSearchBar.m
//  CWUIKit
//  Created by David Arve 
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
//     * Neither the name of the Jayway nor the names of its contributors may 
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

#import "CWSearchBar.h"
#import "CWTextField.h"
#import <QuartzCore/QuartzCore.h>

@interface CWSearchBar () <UITextFieldDelegate> 
@end


@implementation CWSearchBar

@synthesize delegate = _delegate;
@synthesize tintColor = _tintColor;
@synthesize scopeSegmentedControl = _segmentedControl;

-(void)setTintColor:(UIColor *)newTintColor;
{
	if (_tintColor != newTintColor) {
		[_tintColor release];
		_tintColor = [newTintColor retain];
	}
}

@synthesize cancelButton = _cancelButton;

-(void)setCancelButton:(UIButton *)newCancelButton;
{
	if (_cancelButton != newCancelButton) {
		[_cancelButton removeFromSuperview];
		_cancelButton = newCancelButton;
		_cancelButton.frame = CGRectMake(self.frame.size.width - _cancelButton.frame.size.width, 0, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
		_cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		_cancelButton.alpha = self.showsCancelButton ? 1.0 : 0.0;
		[_cancelButton addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:_cancelButton];
		
	}
}

@synthesize showsCancelButton;


- (void)setShowsCancelButton:(BOOL)shouldShowCancelButton animated:(BOOL)animated;
{
	if (self.showsCancelButton == shouldShowCancelButton) {
		return;
	}
	if (animated) {
		[UIView beginAnimations:NSStringFromClass([self class]) context:nil];
		[UIView setAnimationDuration:.2];
		
	}
	self.showsCancelButton = shouldShowCancelButton;
	self.cancelButton.alpha = shouldShowCancelButton ? 1.0 : 0.0;
    _segmentedControl.alpha = shouldShowCancelButton ? 1 : 0;
	[self layoutSubviews];

	if (animated) {
		[UIView commitAnimations];
		
	}

}

-(NSString*)placeholder;
{
	return _searchField.placeholder;
}

-(void)setPlaceholder:(NSString *)newPlacholder;
{
	_searchField.placeholder = newPlacholder;
}

@synthesize text;


-(void)primitiveInit;
{
	self.backgroundColor = [UIColor clearColor];
	
	UIImage *image = [UIImage imageNamed:@"CWUIKitResources.bundle/input_field_extendable.png"];
	UIImage *stretchableImage = [image stretchableImageWithLeftCapWidth:floorf((image.size.width -1)/2)  topCapHeight:floorf((image.size.height -1)/2)];
	_searchBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	_searchBarImageView.image = stretchableImage;
	_searchBarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:_searchBarImageView];

	_searchField = [[CWTextField alloc] initWithFrame:CGRectMake(8, 4, self.frame.size.width-13, self.frame.size.height - 8)];
	_searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_searchField.textInsets = UIEdgeInsetsMake(0, 20, 0, 0);
	_searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_searchField.delegate = self;
	_searchField.returnKeyType = UIReturnKeySearch;
	[self addSubview:_searchField];
		
	UIButton* defaultCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[defaultCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[defaultCancelButton sizeToFit];
	self.cancelButton = defaultCancelButton;
	
	[[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:_searchField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *arg1) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
			self.text = _searchField.text;
			[self.delegate searchBar:self textDidChange:self.text];
		}
	}];
	    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self primitiveInit];
    }
    return self;	
}

-(instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self primitiveInit];
    }
    return self;
}

-(void)layoutSubviews;
{
	if (self.showsCancelButton) {
		_searchField.frame = CGRectMake(8, 4, 
                                        self.bounds.size.width - 13 - (self.cancelButton.bounds.size.width + 10), 
                                        22);
		_searchBarImageView.frame = CGRectMake(0, 0, 
                                               self.frame.size.width -(self.cancelButton.bounds.size.width + 10), 
                                               30);
    } else {
		_searchField.frame = CGRectMake(8, 4, self.frame.size.width-13, 22);
		_searchBarImageView.frame = CGRectMake(0, 0, self.frame.size.width, 30);
	} 
    
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	UIBezierPath* path;
	path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(10, 8, 10, 10)];
	[path setLineWidth:2.0f];
	if (self.tintColor) {
		[self.tintColor set];
	} else {
		[[UIColor blackColor] set];
	}
	[path stroke];
	path = [UIBezierPath bezierPath];
	[path setLineWidth:2.0f];
	[path moveToPoint:CGPointMake(17+6, 17+4)];
	[path addLineToPoint:CGPointMake(18, 16.5)];
	[path stroke];
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL)resignFirstResponder;
{
	BOOL willResignFirstResponder = [_searchField resignFirstResponder];
	return willResignFirstResponder;
}

- (BOOL)becomeFirstResponder
{
	return [_searchField becomeFirstResponder];
}

-(BOOL)canBecomeFirstResponder;
{
	return [_searchField canBecomeFirstResponder];
}

#pragma mark -
#pragma mark UITextFieldDelegate comformance

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
		return [self.delegate searchBarShouldBeginEditing:self];
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
		[self.delegate searchBarTextDidBeginEditing:self];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField; 
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
		return [self.delegate searchBarShouldEndEditing:self];
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField; 
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
		[self.delegate searchBarTextDidEndEditing:self];
	}
}


- (BOOL)textFieldShouldClear:(UITextField *)textField; 
{
	return YES;
}

-(void)searchBarCancelButtonClicked:(id)sender; 
{
	_searchField.text = @"";
	if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
		[self.delegate searchBarCancelButtonClicked:self];
	}
    [_searchField performSelector:@selector(resignFirstResponder)
                       withObject:nil
                       afterDelay:0.001];
}



@end
