//
//  NSObject+CWNibLocalizations.m
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

#import "NSObject+CWNibLocalizations.h"

@implementation NSObject (CWNIBLocalizations)

-(NSString*)localizedValue:(NSString*)value;
{
    if ([value hasPrefix:@"@"]) {
    	value = NSLocalizedString([value substringFromIndex:1], nil);
    } else if ([value hasPrefix:@"\\@"]) {
        value = [value substringFromIndex:1];
    }
    return value;
}

-(void)localizeValueForKey:(NSString*)key;
{
	NSString* oldValue = [self valueForKey:key];
    NSString* newValue = [self localizedValue:oldValue];
    if (oldValue != newValue) {
	    [self setValue:newValue forKey:key];
    }
}

-(void)localizeButton;
{
    UIButton* button = (id)self;
	for (int state = 0; state < 8; state++) {
		NSString* oldTitle = [button titleForState:state];
        if (oldTitle != nil) {
            NSString* newTitle = [self localizedValue:oldTitle];
            if (oldTitle != newTitle) {
                [button setTitle:newTitle forState:state];
            }
        }
    }
}

-(void)localizeSegmentedControl;
{
    UISegmentedControl* segment = (id)self;
    int itemCount = [segment numberOfSegments];
    for (int index = 0; index < itemCount; index++) {
        NSString* oldTitle = [segment titleForSegmentAtIndex:index];
        if (oldTitle != nil) {
            NSString* newTitle = [self localizedValue:oldTitle];
            if (oldTitle != newTitle) {
                [segment setTitle:newTitle forSegmentAtIndex:index];
            }
        }
    }
}

-(void)performLocalization {
    // UIButton responds to title, seems to be private attribute.
    // Therefore its comparison call is at the top.
    
    if ([self isKindOfClass:[UIButton class]]) {
    	[self localizeButton];
    } else if ([self respondsToSelector:@selector(text)]) {
        [self localizeValueForKey:@"text"];
    } else if ([self respondsToSelector:@selector(title)]) {
        [self localizeValueForKey:@"title"];
    } else if ([self isKindOfClass:[UISegmentedControl class]]) {
    	[self localizeSegmentedControl];
    }
    if ([self respondsToSelector:@selector(placeholder)]) {
        [self localizeValueForKey:@"placeholder"];
    }
}

-(void)awakeFromNib;
{
    [self performLocalization];
}

-(void)localizeFromNib {
    [self performLocalization];
    
    if ([self isKindOfClass:[UIView class]]) {
        UIView* uiView = (UIView*)self;

        for(UIView* view in uiView.subviews) {
            [view localizeFromNib];
        }
    }
}

@end
