//
//  UIActionSheet+AuxiliaryAction.m
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

#import "CWAuxiliaryAction.h"
#import <objc/runtime.h>

@interface CWActionSheedAuxiliaryActionsDelegate : NSObject <UIActionSheetDelegate> {
@private
	NSArray* _actions;
}

-(instancetype)initWithAuxiliaryActions:(NSArray*)actions;

@end


@implementation UIActionSheet (AuxiliaryAction)

static void* actionKey = "auxiliaryActionsKey"; 
static void* dismissKey = "dismissHandlerKey"; 

-(CWAuxiliaryActionHandler)dismissHandler;
{
	return objc_getAssociatedObject(self, dismissKey);
}

-(void)setDismissHandler:(CWAuxiliaryActionHandler)handler;
{
	objc_setAssociatedObject(self, dismissKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+(UIActionSheet*)actionSheetWithAuxiliaryActions:(NSArray*)actions cancelButtonTitle:(NSString*)cancelTitle;
{
	UIActionSheet* sheet = [[[UIActionSheet alloc] init] autorelease];
    for (CWAuxiliaryAction* action in actions) {
        [sheet addButtonWithTitle:action.localizedTitle];
    }
    if (cancelTitle) {
	    NSInteger index = [sheet addButtonWithTitle:cancelTitle];
    	sheet.cancelButtonIndex = index;
    }
    CWActionSheedAuxiliaryActionsDelegate* delegate = [[[CWActionSheedAuxiliaryActionsDelegate alloc] initWithAuxiliaryActions:actions] autorelease];
    sheet.delegate = delegate;
    objc_setAssociatedObject(sheet, actionKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return sheet;
}

+(UIActionSheet*)actionSheetWithCancelButtonTitle:(NSString*)cancelTitle otherTitlesAndAuxiliaryActions:(NSString*)firstTitle, ...;
{
	NSMutableArray* actions = [NSMutableArray array];
    va_list vl;
    NSString* title = firstTitle;
    va_start(vl, firstTitle);
    while (title) {
    	CWAuxiliaryActionHandler handler = va_arg(vl, CWAuxiliaryActionHandler);
        [actions addObject:[CWAuxiliaryAction actionWithTitle:title handler:handler]];
        title = va_arg(vl, NSString*);
    }
    va_end(vl);
    return [self actionSheetWithAuxiliaryActions:actions cancelButtonTitle:cancelTitle];
}

@end


@implementation CWActionSheedAuxiliaryActionsDelegate

-(instancetype)initWithAuxiliaryActions:(NSArray*)actions;
{
	self = [self init];
    if (self) {
    	_actions = [actions copy];
    }
    return self;
}

-(void)dealloc;
{
	[_actions release];
    [super dealloc];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    for (CWAuxiliaryAction* action in _actions) {
    	if ([title isEqualToString:action.localizedTitle]) {
        	action.handler(action);
            return;
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
	CWAuxiliaryActionHandler handler = actionSheet.dismissHandler;
    if (handler) {
        NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
        for (CWAuxiliaryAction* action in _actions) {
            if ([title isEqualToString:action.localizedTitle]) {
                handler(action);
                return;
            }
        }
        handler(nil);
    }
}

@end

