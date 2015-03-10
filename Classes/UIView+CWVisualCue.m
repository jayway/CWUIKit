//
//  UIView+CWVisualCue.m
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

#import "UIView+CWVisualCue.h"
#import <QuartzCore/QuartzCore.h>
#import "CWGeometry.h"

#define ANIMATION_MOVE_ID @"CWVisualMoveCue"
#define ANIMATION_FLASH_ID @"CWVisualFlashCue"

NSTimeInterval CWVisualCueDefaultAnimationDuration = 0.4;


@implementation UIView (CWVisualCue)

-(UIView*)firstCommonSuperviewWithView:(UIView*)view;
{
	while (view != nil) {
    	if ([self isDescendantOfView:view]) {
        	return view;
        } else {
        	view = view.superview;
        }
    }
    return nil;
}

+(void)animateVisualCueForMovingRect:(CGRect)fromRect inView:(UIView*)fromView 
                              toRect:(CGRect)toRect inView:(UIView*)toView;
{
	[self animateVisualCueForMovingRect:fromRect 
                                 inView:fromView 
                                 toRect:toRect 
                                 inView:toView
                               rotation:0.0f
                               duration:CWVisualCueDefaultAnimationDuration
                        flashAtEndpoint:NO];
}

+(void)animateVisualCueForMovingRect:(CGRect)fromRect inView:(UIView*)fromView 
                              toRect:(CGRect)toRect inView:(UIView*)toView
							rotation:(CGFloat)rotation duration:(NSTimeInterval)duration
                     flashAtEndpoint:(BOOL)flash;
{    
	[[fromView firstCommonSuperviewWithView:toView] animateVisualCueForMovingRect:fromRect 
                                                                           inView:fromView 
                                                                           toRect:toRect 
                                                                           inView:toView
                                                                         rotation:rotation
                                                                         duration:duration
                                                                  flashAtEndpoint:flash];
}


static CGRect gToRect;

-(void)animateVisualCueForMovingRect:(CGRect)fromRect inView:(UIView*)fromView 
                              toRect:(CGRect)toRect inView:(UIView*)toView
							rotation:(CGFloat)rotation duration:(NSTimeInterval)duration
                     flashAtEndpoint:(BOOL)flash;
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
	UIGraphicsBeginImageContext(fromRect.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, -fromRect.origin.x, -fromRect.origin.y);
    [fromView.layer renderInContext:c];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    fromRect = [fromView convertRect:fromRect toView:self];
    toRect = [toView convertRect:toRect toView:self];
    toRect = CWRectFitAndCenterInRect(fromRect, toRect);
	gToRect = toRect;
    
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    imageView.tag = (int)flash;
    imageView.frame = fromRect;
    [self addSubview:imageView];
    
    // Create a ballistic path to that destination.
    CGPoint fromCenter = fromRect.origin;
    fromCenter.x += roundf(fromRect.size.width / 2.0f);
    fromCenter.y += roundf(fromRect.size.height / 2.0f);
    CGPoint toCenter = toRect.origin;
    toCenter.x += roundf(toRect.size.width / 2.0f);
    toCenter.y += roundf(toRect.size.height / 2.0f);

    CGMutablePathRef ballisticPath = CGPathCreateMutable();
    CGPathMoveToPoint(ballisticPath, NULL, fromCenter.x, fromCenter.y);
    CGPathAddQuadCurveToPoint(ballisticPath, NULL, toCenter.x, 0.0f, toCenter.x, toCenter.y);
    
    // Create a keyframe animation.
    CAKeyframeAnimation* keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrame.path = ballisticPath;
    keyFrame.keyTimes = @[@0.0f, @1.0f];
    keyFrame.duration = duration;
    keyFrame.calculationMode = kCAAnimationLinear;
//    keyFrame.delegate = self;
    keyFrame.fillMode = kCAFillModeBoth;
    [imageView.layer addAnimation:keyFrame forKey:@"position"];
    CGPathRelease(ballisticPath);
    
    // Now we need to rotate the image view and fade out.
    [UIView beginAnimations:ANIMATION_MOVE_ID context:(void*)imageView];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(visualCueAnimationDidStop:finished:context:)];
    [UIView setAnimationDuration:duration];
    CGAffineTransform transform = imageView.transform;
    if (rotation != 0.0f) {
		transform = CGAffineTransformRotate(transform, rotation);
    }
	imageView.alpha = 0.999f;
    transform = CGAffineTransformScale(transform, toRect.size.width / fromRect.size.width, toRect.size.height / fromRect.size.height);
	imageView.transform = transform;
    
    [UIView commitAnimations];
}

- (void)visualCueAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
	if ([animationID isEqualToString:ANIMATION_MOVE_ID]) {
        UIImageView* imageView = (UIImageView*)context;
        UIView* parent = imageView.superview;
        [imageView removeFromSuperview];
        if ((BOOL)imageView.tag) {
            UIImageView* flashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CWUIKitResources.bundle/flash.png"]];
            flashView.frame = gToRect;
            [parent addSubview:flashView];
            [UIView beginAnimations:ANIMATION_FLASH_ID context:(void*)flashView];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:_cmd];
            [flashView setAlpha:0.0];
            [UIView commitAnimations];
        } else {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    } else if ([animationID isEqualToString:ANIMATION_FLASH_ID]) {
        UIImageView* imageView = (UIImageView*)context;
        [imageView removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

@end
