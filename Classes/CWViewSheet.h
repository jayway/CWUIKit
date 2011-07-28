//
//  CWViewSheet.h
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
 * @abstract An helper class for presenting a view as a sheet.
 *
 * @discussion Visually and conceptually it looks and behaves like a UIActionSheet.
 *             Is presented inside a popover on iPad.
 *             Only compatible with portrait orientation on iPhone.
 */
@interface CWViewSheet : UIView <UIPopoverControllerDelegate> {
@private
    UIView* _contentView;
    BOOL _visible;
    UIView* layoutView;
    UIButton* dismissButton;
    id retainDummy;
    UIPopoverController* popoverController;
    BOOL iPhoneIdiom;
}

/*! 
 * @abstract The content view the sheet presents.
 */
@property(nonatomic, readonly, retain) UIView* contentView;

/*!
 * @abstract Query of the sheet is currently visible.
 */
@property(nonatomic, readonly, getter=isVisible, assign) BOOL visible;

/*!
 * @abstract Initializes and returns an instance with a goven contemnt view.
 *
 * @discussion Title is optional, if available it will be displayed in a black
 *             bar above the content view in the sheet.
 */
-(id)initWithContentView:(UIView*)view title:(NSString*)title;

/*!
 * @abstract Displey the sheet originating in a view.
 */
-(void)showInView:(UIView*)view animated:(BOOL)animated;

/*!
 * @abstract Displey the sheet originating from a view.
 */
-(void)showFromRect:(CGRect)rect inView:(UIView*)view animated:(BOOL)animated;

/*!
 * @abstract Displey the sheet originating from a bar button.
 */
-(void)showFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated;

/*!
 * @abstract Dismiss the sheet.
 */
-(void)dismissAnimated:(BOOL)animated;

@end

