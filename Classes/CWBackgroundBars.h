//
//  CWBackgroundBars.h
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

#import <UIKit/UIKit.h>


/*
Deprecation warning:
 The functionality in these classes will be obsolete as of iOS 5.0 since
 the new version of UIKit includes more functionality for customizing views.
 
*/

@interface CWBackgroundNavigationBar : UINavigationBar {
@private
    UIView* _obsoluteBackgroundView;
    BOOL _hiddenBackgroundImage;
}

@property(nonatomic, retain) UIView* backgroundView;
@property(nonatomic, assign, getter=isHiddenBackgroundView) BOOL hiddenBackgroundView;
-(void)setHiddenBackgroundView:(BOOL)hidden animated:(BOOL)animated;

@end


@interface CWBackgroundToolbar : UIToolbar {
@private
    UIView* _obsoluteBackgroundView;
    BOOL _hiddenBackgroundImage;
}

@property(nonatomic, retain) UIView* backgroundView;
@property(nonatomic, assign, getter=isHiddenBackgroundView) BOOL hiddenBackgroundView;
-(void)setHiddenBackgroundView:(BOOL)hidden animated:(BOOL)animated;

@end
