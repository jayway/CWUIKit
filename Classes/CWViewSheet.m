//
//  CWViewSheet.m
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

#import "CWViewSheet.h"

@interface CWViewSheet (Private)
@property(nonatomic, readwrite, assign) BOOL visible;
@end

@implementation CWViewSheet

-(void)setVisible:(BOOL)visible;
{
    _visible = visible;
    [self.window endEditing:YES];
}

@synthesize contentView = _contentView;
@synthesize visible = _visible;

-(void)primitiveInitForPhoneIdiomWithFrame:(CGRect)frame title:(NSString*)title;
{
    self.autoresizesSubviews = YES;
    CGRect contentFrame = _contentView.bounds;
    contentFrame.origin.y = (title ? 44 : 0);
    _contentView.frame = contentFrame;
    CGRect layoutFrame = frame;
    layoutFrame.size.height = contentFrame.size.height + (title ? 44 : 0);
    layoutFrame.origin.y = frame.size.height - layoutFrame.size.height;
    layoutView = [[[UIView alloc] initWithFrame:layoutFrame] autorelease];
    layoutView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [layoutView addSubview:_contentView];
    if (title) {
        UIBarButtonItem* flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] autorelease];
        label.text = title;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        [label sizeToFit];
        UIBarButtonItem* titleItem = [[[UIBarButtonItem alloc] initWithCustomView:label] autorelease];
        UIBarButtonItem* doneItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)] autorelease];
        UIBarButtonItem* spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL] autorelease];
        spaceItem.width = 30;
        NSArray* items = @[spaceItem, flexItem, titleItem, flexItem, doneItem];
        CGRect toolbarFrame = contentFrame;
        toolbarFrame.origin.y = 0;
        toolbarFrame.size.height = 44;
        UIToolbar* toolbar = [[[UIToolbar alloc] initWithFrame:toolbarFrame] autorelease];
        toolbar.items = items;
        toolbar.barStyle = UIBarStyleBlack;
        [layoutView addSubview:toolbar];
    }
    dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.frame = self.bounds;
    dismissButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    [self addSubview:dismissButton];
    [self addSubview:layoutView];
}

-(void)primitiveInitForPadIdiomWithFrame:(CGRect)frame title:(NSString*)title;
{
    UIViewController* vc = [[[UIViewController alloc] init] autorelease];
    // This is done to avoid a resize bug in UIPopoverController.
    UIView* contentView = [[[UIView alloc] initWithFrame:_contentView.bounds]autorelease];
    [contentView addSubview:_contentView];
    vc.view = contentView;
    vc.contentSizeForViewInPopover = frame.size;
    if (title) {
        vc.title = title;
        vc.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)] autorelease];
        vc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    }
    popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    popoverController.popoverContentSize = frame.size;
    popoverController.delegate = self;
}

-(instancetype)initWithContentView:(UIView*)view title:(NSString*)title;
{
    iPhoneIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    CGRect frame = iPhoneIdiom ? [[UIScreen mainScreen] applicationFrame] : view.bounds;
    self = [self initWithFrame:frame];
    if (self) {
        _contentView = view;
        if (iPhoneIdiom) {
            [self primitiveInitForPhoneIdiomWithFrame:frame title:title];
        } else {
            [self primitiveInitForPadIdiomWithFrame:frame title:title];
        }
    }
    return self;
}

- (void)dealloc
{
    popoverController.delegate = nil;
    [popoverController release];
    [super dealloc];
}

-(void)showInView:(UIView*)view animated:(BOOL)animated;
{
    if (self.visible) {
        return;
    }
    if (iPhoneIdiom) {
        if (view == nil) {
            view = [[UIApplication sharedApplication] keyWindow];
        }
        if (![view isKindOfClass:[UIWindow class]]) {
            view = view.window;
        }
        CGRect frame = [[(UIWindow*)view screen] applicationFrame];
        self.frame = frame;
        [view addSubview:self];
        if (animated) {
            CGRect layoutFrame = layoutView.frame;
            layoutFrame.origin.y += layoutFrame.size.height;
            layoutView.frame = layoutFrame;
            dismissButton.alpha = 0;
            [UIView beginAnimations:nil context:NULL];
            layoutFrame.origin.y -= layoutFrame.size.height;
            layoutView.frame = layoutFrame;
            dismissButton.alpha = 1;
            [UIView commitAnimations];                    
        }
    } else {
        UIView* view = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = view.bounds;
        rect = CGRectMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.width / 2, 1, 1);
        [popoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:0 animated:animated];
        retainDummy = [self retain];
    }
    self.visible = YES;
}

-(void)showFromRect:(CGRect)rect inView:(UIView*)view animated:(BOOL)animated;
{
    if (self.visible) {
        return;
    }
    if (iPhoneIdiom) {
        [self showInView:[[UIApplication sharedApplication] keyWindow] animated:animated];
    } else {
        [popoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:animated];
        retainDummy = [self retain];
    }
    self.visible = YES;
}

-(void)showFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated;
{
    if (self.visible) {
        return;
    }
    if (iPhoneIdiom) {
        [self showInView:[[UIApplication sharedApplication] keyWindow] animated:animated];
    } else {
        [self showFromBarButtonItem:item animated:animated];
        retainDummy = [self retain];
    }
    self.visible = YES;
}

-(void)dismiss;
{
    [self dismissAnimated:YES];
}
                                  
-(void)dismissAnimated:(BOOL)animated;
{
    if (!self.visible) {
        return;
    }
    if (iPhoneIdiom) {
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            CGRect layoutFrame = layoutView.frame;
            layoutFrame.origin.y += layoutFrame.size.height;
            layoutView.frame = layoutFrame;
            dismissButton.alpha = 0;
            [UIView commitAnimations];
        } else {
            [self removeFromSuperview];
        }
    } else {
        [popoverController dismissPopoverAnimated:animated];
        [retainDummy autorelease], retainDummy = nil;
    }
    self.visible = NO;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    [self removeFromSuperview];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
{
    [retainDummy autorelease], retainDummy = nil;
    self.visible = NO;
}


@end
