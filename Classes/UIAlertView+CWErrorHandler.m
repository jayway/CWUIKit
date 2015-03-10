//
//  UIAlertView+CWErrorHandler.m
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

#import "UIAlertView+CWErrorHandler.h"
#import "NSError+CWAdditions.h"

@implementation UIAlertView (CWErrorHandler)

static NSMutableDictionary* cw_recoveryErrors = nil;

+(void)alertViewCancel:(UIAlertView *)alertView;
{
    NSError* error = cw_recoveryErrors[[NSValue valueWithPointer:(const void *)alertView]];
	id<CWErrorRecoveryAttempting> recoveryAttempter = [error recoveryAttempter];
    [recoveryAttempter attemptRecoveryFromError:error optionIndex:NSNotFound];
    [cw_recoveryErrors removeObjectForKey:[NSValue valueWithPointer:(const void *)alertView]];
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSError* error = cw_recoveryErrors[[NSValue valueWithPointer:(const void *)alertView]];
	NSInteger recoveryIndex = [[error localizedRecoveryOptions] indexOfObject:[alertView buttonTitleAtIndex:buttonIndex]];
	id<CWErrorRecoveryAttempting> recoveryAttempter = [error recoveryAttempter];
    [recoveryAttempter attemptRecoveryFromError:error optionIndex:recoveryIndex];
	[cw_recoveryErrors removeObjectForKey:[NSValue valueWithPointer:(const void *)alertView]];
}

+(UIAlertView*)alertViewWithError:(NSError*)error;
{
	if(error == nil) {
		return nil;
	}
	
    BOOL hasRecoveryAttempter = [error recoveryAttempter] != nil && [[error localizedRecoveryOptions] count] > 0;
    NSString* cancelButton = hasRecoveryAttempter ? nil : NSLocalizedString(@"OK", nil);
    NSString* message = [error localizedFailureReason];
    if ([error localizedRecoverySuggestion]) {
    	message = [message stringByAppendingFormat:@"\n%@", [error localizedRecoverySuggestion]];
    }
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButton
                                          otherButtonTitles:nil] autorelease];
    if (hasRecoveryAttempter) {
    	if (cw_recoveryErrors == nil) {
			cw_recoveryErrors = [[NSMutableDictionary alloc] initWithCapacity:4];            
        }
        cw_recoveryErrors[[NSValue valueWithPointer:(const void *)alert]] = error;
        for (NSString* recoveryOption in [error localizedRecoveryOptions]) {
        	[alert addButtonWithTitle:recoveryOption];
        }
        alert.cancelButtonIndex = [[error localizedRecoveryOptions] count] - 1;
        alert.delegate = (id)self;
    }
    return alert;
}

@end
