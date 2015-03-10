//
//  UIViewController+CWPopover.m
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

#import "UIViewController+CWPopover.h"
#import <objc/runtime.h>

@interface CWViewControllerPopoverHelper : NSObject {
@private
    UIViewController* parentViewController;
    UIPopoverController* containerPopoverController;
    NSMutableSet* visiblePopoverControllers;
}
@property (nonatomic, assign) UIViewController* parentViewController;
@property (nonatomic, assign) UIPopoverController* containerPopoverController;
@property (nonatomic, retain) NSMutableSet* visiblePopoverControllers;

@end

@implementation CWViewControllerPopoverHelper

@synthesize parentViewController, containerPopoverController, visiblePopoverControllers;

-(instancetype)init;
{
	self = [super init];
    if (self) {
    	//self.visiblePopoverControllers = [NSMutableSet setWithCapacity:4];
    }
    return self;
}

-(void)dealloc;
{
	[visiblePopoverControllers release];
    [super dealloc];
}

@end



@implementation UIViewController (CWPopover)

#pragma mark --- Private helpers

static NSMutableDictionary* popoverHelpers = nil;

-(CWViewControllerPopoverHelper*)popoverHelper;
{
	NSValue* key = [NSValue valueWithPointer:self];
    if (popoverHelpers == nil) {
    	popoverHelpers = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
	CWViewControllerPopoverHelper* helper = popoverHelpers[key];
    if (helper == nil) {
        helper = [[[CWViewControllerPopoverHelper alloc] init] autorelease];
		popoverHelpers[key] = helper;
    }
    return helper;
}

+(void)load;
{
    Method m1 = class_getInstanceMethod(self, @selector(dealloc));
    Method m2 = class_getInstanceMethod(self, @selector(cwPopoverDealloc));
    method_exchangeImplementations(m1, m2);
    m1 = class_getInstanceMethod(self, @selector(parentViewController));
    m2 = class_getInstanceMethod(self, @selector(cwPopoverParentViewController));
    method_exchangeImplementations(m1, m2);
}

-(void)cwPopoverDealloc;
{
    [self dismissAllPopoverControllersAnimated:NO];
	NSValue* key = [NSValue valueWithPointer:self];
    [popoverHelpers removeObjectForKey:key];
    [self cwPopoverDealloc];
}

-(UIViewController*)cwPopoverParentViewController;
{
	UIViewController* parent = [self popoverHelper].parentViewController;
    if (parent == nil) {
    	parent = [self cwPopoverParentViewController];
    }
    return parent;
}

-(void)addPopoverViewController:(UIPopoverController*)pc passthroughViews:(NSArray*)views;
{
	if (views) {
    	pc.passthroughViews = views;
    }
    pc.delegate = self;
	[[self popoverHelper].visiblePopoverControllers addObject:pc];
    CWViewControllerPopoverHelper* helper = [pc.contentViewController popoverHelper];
    helper.parentViewController = self;
    helper.containerPopoverController = pc;
}

#pragma mark --- Public API implementation

-(NSSet*)visiblePopoverControllers;
{
    NSMutableSet* controllers = [NSMutableSet set];
    for (UIPopoverController* pc in [self popoverHelper].visiblePopoverControllers) {
		[controllers addObject:pc.contentViewController];
    }
    if ([controllers count] > 0) {
        return [NSSet setWithSet:controllers];
    } else {
        return nil;
    }
}

-(void)presentPopoverViewController:(UIViewController*)controller 
                  fromBarButtonItem:(UIBarButtonItem *)item 
                           animated:(BOOL)animated;
{
	[self presentPopoverViewController:controller fromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny passthroughViews:nil animated:animated];    
}

-(void)presentPopoverViewController:(UIViewController*)controller fromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections passthroughViews:(NSArray*)views animated:(BOOL)animated;
{
    UIPopoverController* pc = [[[UIPopoverController alloc] initWithContentViewController:controller] autorelease];
	[self addPopoverViewController:pc passthroughViews:views];
    [pc presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
}

-(void)presentPopoverViewController:(UIViewController*)controller fromView:(UIView *)view animated:(BOOL)animated;
{
	[self presentPopoverViewController:controller fromRect:view.bounds inView:view permittedArrowDirections:UIPopoverArrowDirectionAny passthroughViews:nil animated:YES];
}

-(void)presentPopoverViewController:(UIViewController*)controller fromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections passthroughViews:(NSArray*)views animated:(BOOL)animated;
{
    UIPopoverController* pc = [[[UIPopoverController alloc] initWithContentViewController:controller] autorelease];
	[self addPopoverViewController:pc passthroughViews:views];
    [pc presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
}

-(void)replacePresentedViewController:(UIViewController*)oldController withViewController:(UIViewController*)newController animated:(BOOL)animated;
{
	[oldController dismissAllPopoverControllersAnimated:animated];
    CWViewControllerPopoverHelper* oldAdditions = [oldController popoverHelper];
    CWViewControllerPopoverHelper* newAdditions = [newController popoverHelper];
    newAdditions.containerPopoverController = oldAdditions.containerPopoverController;
    newAdditions.parentViewController = oldAdditions.parentViewController;
    oldAdditions.containerPopoverController = nil;
    oldAdditions.parentViewController = nil;
    [newAdditions.containerPopoverController setContentViewController:newController animated:animated];
}

-(void)dismissPopoverController:(UIViewController*)controller animated:(BOOL)animated;
{
	[controller dismissAllPopoverControllersAnimated:animated];
	CWViewControllerPopoverHelper* helper = [controller popoverHelper];
    UIPopoverController* pc = helper.containerPopoverController;
    UIViewController* vc = helper.parentViewController;
    [pc dismissPopoverAnimated:animated];
	helper.containerPopoverController = nil;
    helper.parentViewController = nil;
    [[vc popoverHelper].visiblePopoverControllers removeObject:pc];
}

-(void)dismissAllPopoverControllersAnimated:(BOOL)animated;
{
    for (UIViewController* vc in self.visiblePopoverControllers) {
        [self dismissPopoverController:vc animated:animated];
    }
}


-(void)setContentSize:(CGSize)size forViewInPopoverAnimated:(BOOL)animated;
{
	[[self popoverHelper].containerPopoverController setPopoverContentSize:size animated:animated];
    self.contentSizeForViewInPopover = size;
}


#pragma mark --- Popver delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc;
{
	[self dismissPopoverController:pc.contentViewController animated:NO];
}


@end
