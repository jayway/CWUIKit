//
//  UIDevice+CWCapabilities.h
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
 * @abstract A category on UIDevice to allow fast quering of cached capabilities.
 */
@interface UIDevice (CWCapabilities)

/*!
 * @abstract Ask is the current device is using Phone user interface idiom.
 */
+(BOOL)isPhone;

/*!
 * @abstract Ask is the current device is using Pad user interface idiom.
 */
+(BOOL)isPad;

/*!
 * @abstract Ask if the current device is capable of OpenGL ES 2.0.
 *
 * @discussion An OpenGL ES 2.0 capabable device is at least an iPhone 3GS, or
 *             a third generation iPod.
 */
+(BOOL)isEAGL2Capable;

/*!
 * @abstract Ask if the current devive is capable of multitasking.
 *
 * @discussion Allways returns NO for deviced running iPhone OS 3.2 and earlier.
 */
+(BOOL)isMultitaskingCapable;

/*!
* @abstract Ask if the current devive is iOS5 or higher.
*
*/
+(BOOL)isiOS5orGreater;

@end
