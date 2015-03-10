//
//  UIViewController+CWPopover.h
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


/*!
 * @abstract Additions to UIViewController in order to handle popovers in the same way
 *           as modal controllers.
 */
@interface UIViewController (CWPopover) <UIPopoverControllerDelegate>

/*!
 * @abstract An unordered set of UIViewControlelrs currently being shown as
 *           popovers from the receiver.
 */
//@property (nonatomic, retain, readonly) NSSet* visiblePopoverControllers;

/*!
 * @abstract Present a popover view managed by the given view controller to the user.
 * @discussion Only available on iPad. The view controller is retained by the receiver
 *             until the popover is dismissed. The popover permits arrows in all
 *             directions, and has no passthrough views.
 * @param controller The view controller that manages the modal view.
 * @param item The bar button item on which to anchor the popover.
 * @param animated Specify YES to animate the presentation of the popover.
 */
-(void)presentPopoverViewController:(UIViewController*)controller 
                  fromBarButtonItem:(UIBarButtonItem *)item 
                           animated:(BOOL)animated;

/*!
 * @abstract Present a popover view managed by the given view controller to the user.
 * @discussion Only available on iPad. The view controller is retained by the receiver
 *             until the popover is dismissed.
 * @param controller The view controller that manages the modal view.
 * @param item The bar button item on which to anchor the popover.
 * @param arrowDirections The arrow directions the popover is permitted to use.
 * @param passthroughtViews An array of views that the user can interact with while the popover is visible.
 * @param animated Specify YES to animate the presentation of the popover.
 */
-(void)presentPopoverViewController:(UIViewController*)controller 
                  fromBarButtonItem:(UIBarButtonItem *)item 
           permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                   passthroughViews:(NSArray*)views 
                           animated:(BOOL)animated;

/*!
 * @abstract Present a popover view managed by the given view controller to the user.
 * @discussion Only available on iPad. The view controller is retained by the receiver
 *             until the popover is dismissed. The popover permits arrows in all
 *             directions, and has no passthrough views.
 * @param controller The view controller that manages the modal view.
 * @param view The view at which to anchor the popover window.
 * @param animated Specify YES to animate the presentation of the popover.
 */
-(void)presentPopoverViewController:(UIViewController*)controller 
                           fromView:(UIView *)view 
                           animated:(BOOL)animated;

/*!
 * @abstract Present a popover view managed by the given view controller to the user.
 * @discussion Only available on iPad. The view controller is retained by the receiver
 *             until the popover is dismissed.
 * @param controller The view controller that manages the modal view.
 * @param rect The rectangle in view at which to anchor the popover window.
 * @param view The view containing the anchor rectangle for the popover.
 * @param arrowDirections The arrow directions the popover is permitted to use.
 * @param passthroughtViews An array of views that the user can interact with while the popover is visible.
 * @param animated Specify YES to animate the presentation of the popover.
 */
-(void)presentPopoverViewController:(UIViewController*)controller 
                           fromRect:(CGRect)rect inView:(UIView *)view 
           permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                   passthroughViews:(NSArray*)views 
                           animated:(BOOL)animated;

/*!
 * @abtract Replace a currently presented view with a new view managed by the given view controller.
 * @param oldController a view controller previously presented in a popover.
 * @param newController the new controller to replace with.
 * @param animated Specify YES if the change of view controllers should be animated.
 */
-(void)replacePresentedViewController:(UIViewController*)oldController 
                   withViewController:(UIViewController*)newController 
                             animated:(BOOL)animated;

/*!
 * @abstract Dismisses the specified popover programmatically.
 * @param controller a view controller previously presented in a popover.
 * @param animated Specify YES to animate the dismissal of the popover.
 */
-(void)dismissPopoverController:(UIViewController*)controller animated:(BOOL)animated;

/*!
 * @abstract Dismisses all popovers managed by the receiver.
 * @param animated Specify YES to animate the dismissal of the popovers.
 */
-(void)dismissAllPopoverControllersAnimated:(BOOL)animated;

/*!
 * @abstract Set a new content size for receiver when presented in a popover.
 * @param size new size.
 * @param animated Specify YES if you want the change in size to be animated.
 */
-(void)setContentSize:(CGSize)size forViewInPopoverAnimated:(BOOL)animated;

@end
