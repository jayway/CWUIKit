//
//  UIColor+CWAdditions.h
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

@interface UIColor (CWAdditions)

@property(nonatomic, readonly) CGColorSpaceModel colorSpaceModel;

-(UIColor*)colorByBlendingWithColor:(UIColor*)color fraction:(CGFloat)fraction;
-(UIColor*)colorByAddingColor:(UIColor*)color;
-(UIColor*)colorByMultiplyingColor:(UIColor*)color;

@property(nonatomic, readonly) CGFloat alpha; 

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canProvideRGBComponents;
-(void)getRGBA:(CGFloat[4])pRGBA;
@property(nonatomic, readonly) CGFloat red; 
@property(nonatomic, readonly) CGFloat green; 
@property(nonatomic, readonly) CGFloat blue; 

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canProvideHSVComponents;
-(void)getHSVA:(CGFloat[4])pHSVA;
@property (nonatomic, readonly) CGFloat hue;
@property (nonatomic, readonly) CGFloat saturation;
@property (nonatomic, readonly) CGFloat brightness;

@end

@interface UIColor (CWStandardColors)

+(UIColor*)cw_tableSeparatorDarkColor;
+(UIColor*)cw_tableSeparatorLightColor;
+(UIColor*)cw_tableBackgroundColor;
+(UIColor*)cw_tableCellBlueTextColor;
+(UIColor*)cw_tableCellGrayTextColor;
+(UIColor*)cw_infoTextOverPinStripeTextColor;
+(UIColor*)cw_tableCellValue1BlueColor;
+(UIColor*)cw_tableCellValue2BlueColor;

@end

