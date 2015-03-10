//
//  UIDevice+CWCapabilities.m
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

#import "UIDevice+CWCapabilities.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, CWCapabilityState) {
	CWCapabilityStateUnknown = 0,
    CWCapabilityStateNo = 1,
    CWCapabilityStateYes = 2
} ;

@implementation UIDevice (CWCapabilities)

+(BOOL)isPhone;
{
	static CWCapabilityState v = CWCapabilityStateUnknown;
    if (v == CWCapabilityStateUnknown) {
    	v = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? CWCapabilityStateYes : CWCapabilityStateNo;
    }
    return v == CWCapabilityStateYes;
}

+(BOOL)isPad;
{
	static CWCapabilityState v = CWCapabilityStateUnknown;
    if (v == CWCapabilityStateUnknown) {
    	v = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? CWCapabilityStateYes : CWCapabilityStateNo;
    }
    return v == CWCapabilityStateYes;
}

+(BOOL)isEAGL2Capable;
{
	static CWCapabilityState v = CWCapabilityStateUnknown;
    if (v == CWCapabilityStateUnknown) {
    	v = ([[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease]) != nil ? CWCapabilityStateYes : CWCapabilityStateNo;
    }
    return v == CWCapabilityStateYes;
}

+(BOOL)isMultitaskingCapable;
{
	static CWCapabilityState v = CWCapabilityStateUnknown;
    if (v == CWCapabilityStateUnknown) {
        v = CWCapabilityStateNo;
        if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
    		v = [[UIDevice currentDevice] isMultitaskingSupported] ? CWCapabilityStateYes : CWCapabilityStateNo;
        }
    }
    return v == CWCapabilityStateYes;
}

+(BOOL)isiOS5orGreater;
{
    id class = NSClassFromString(@"UIPageViewController");
    if (class){
        return YES;
    } else{
        return NO;
    }
}

@end
