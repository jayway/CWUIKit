//
//  CWAuxiliaryAction.m
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

@implementation CWAuxiliaryAction

@synthesize localizedTitle = _title;
@synthesize handler = _handler;
@synthesize tag = _tag;

+(instancetype)actionWithTitle:(NSString*)title handler:(CWAuxiliaryActionHandler)handler;
{
	return [[[self alloc] initWithLocalizedTitle:title
                                         handler:handler] autorelease];    
}

+(instancetype)actionWithTitle:(NSString*)title handler:(CWAuxiliaryActionHandler)handler tag:(NSInteger)tag;
{
	CWAuxiliaryAction* action = [self actionWithTitle:title handler:handler];
    action.tag = tag;
    return action;
}

-(instancetype)initWithLocalizedTitle:(NSString*)title handler:(CWAuxiliaryActionHandler)handler;
{
	self = [self init];
    if (self) {
    	_title = [title copy];
        _handler = [handler copy];
    }
    return self;
}

-(void)dealloc;
{
	[_title release];
    [_handler release];
    [super dealloc];
}

@end
