//
//  UIBarButtonItem+CWAdditions.m
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

#import "UIBarButtonItem+CWAdditions.h"


@implementation UIBarButtonItem (CWAdditions)

+(UIBarButtonItem*)barButtonItemWithImage:(UIImage*)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
{
	return [[[UIBarButtonItem alloc] initWithImage:image
                                             style:style
                                            target:target
                                            action:action] autorelease];    
}

+(UIBarButtonItem*)barButtonItemWithTitle:(NSString*)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
{
	return [[[UIBarButtonItem alloc] initWithTitle:title
                                             style:style
                                            target:target
                                            action:action] autorelease];
}

+(UIBarButtonItem*)barButtonItemWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;
{
	return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem
                                                          target:target
                                                          action:action] autorelease];    
}

+(UIBarButtonItem*)barButtonItemWithCustomView:(UIView*)customView;
{
	return [[[UIBarButtonItem alloc] initWithCustomView:customView] autorelease];
}

+(UIBarButtonItem*)barButtonItemWithTitle:(NSString*)title titleColor:(UIColor*)titleColor titleShadowColor:(UIColor*)titleShadowColor image:(UIImage*)image  stretchableBackgroundImage:(UIImage*)backgroundImage stretchableHighlightedBackgroundImage:(UIImage*)highlightedBackgroundImage target:(id)target action:(SEL)action;
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    [button setTitle:title forState:UIControlStateNormal];
    if (titleColor == nil) {
    	titleColor = [UIColor colorWithWhite:1 alpha:0.9f];
    }
	[button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    if (titleShadowColor == nil) {
    	titleShadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
    }
    [button setTitleShadowColor:titleShadowColor forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    return [self barButtonItemWithCustomView:button];
}

+(UIBarButtonItem*)barButtonItemWithTitle:(NSString*)title titleColor:(UIColor*)titleColor titleShadowColor:(UIColor*)titleShadowColor image:(UIImage*)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
{
    if (style == UIBarButtonItemStylePlain) {
    	return [self barButtonItemWithTitle:title
                                 titleColor:titleColor
                           titleShadowColor:titleShadowColor
                                      image:image
                 stretchableBackgroundImage:nil
      stretchableHighlightedBackgroundImage:nil
                                     target:target
                                     action:action];
    } else {
        UIImage* backgroundImage = nil;
        UIImage* highlightedBackgroundImage = nil;
     	if (backgroundImage == nil) {
            backgroundImage = [[UIImage imageNamed:@"CWUIKitResources.bundle/bar_button.png"] stretchableImageWithLeftCapWidth:15
                                                                                                           topCapHeight:15];
            highlightedBackgroundImage = [[UIImage imageNamed:@"CWUIKitResources.bundle/bar_button_highlighted.png"] stretchableImageWithLeftCapWidth:15
                                                                                                           topCapHeight:15];
        }
        return [self barButtonItemWithTitle:title
                                 titleColor:titleColor
                           titleShadowColor:titleShadowColor
                                      image:image
                 stretchableBackgroundImage:backgroundImage
      stretchableHighlightedBackgroundImage:highlightedBackgroundImage
                                     target:target
                                     action:action];
    }
}

@end
