//
//  CWCalendarView.h
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

@protocol CWCalendarViewDelegate;

/*!
 * @abstract A calendar view close to the Calendar app in visual appearance.
 *
 * @discussion Supports selection with date validation, and annotation markers.
 *             Programatically setting selectedDate will not update currentMonthDate.
 *             CWCalendarView expects a 320x308 size.
 */
@interface CWCalendarView : UIView {
@private
    id<CWCalendarViewDelegate> _delegate;
    NSDate* _selectedDate;
    NSDate* _currentMonthDate;
    NSDate* _maximumDate;
    NSDate* _minimumDate;
    NSCalendar* _calendar;
    NSDate* currentTopLeftDate;
    struct {
        unsigned int delegateCanSelect:1;
        unsigned int delegateHasAnnotation:1;
        unsigned int delegateWillSelect:1;
        unsigned int delegateDidSelect:1;
    } flags;
}

/*!
 * @abstract The calendar delegate.
 */
@property(nonatomic, assign) IBOutlet id<CWCalendarViewDelegate> delegate;

/*!
 * @abstract The date currently selected, or nil of no selection.
 */
@property(nonatomic, copy) NSDate* selectedDate;

/*!
 * @abstract The first day of the month to display.
 * @discussion Truncated to first day of month when set.
 *             If nil it will reset to selectedDate if it exist, otherwise
 *             is restes to the current month.
 */
@property(nonatomic, copy) NSDate* currentMonthDate;

/*!
 * @abstract Minimum date to display and allow selection for.
 * @discussion Truncated to a day.
 */
@property(nonatomic, copy) NSDate* maximumDate;

/*!
 * @abstract Maximum date to display and allow selection for.
 * @discussion Truncated to a day.
 */
@property(nonatomic, copy) NSDate* minimumDate;

/*!
 * @abstract The calendar to use for the calendar view.
 * @abstract Default is the current calendar, it is not safe to change the 
 *           calendar after the view has been drawn to screen.
 */
@property(nonatomic, retain) NSCalendar* calendar;

@end


/*!
 * @abstract The delegate for a CWCalendarView must adopt this protocol.
 */
@protocol CWCalendarViewDelegate <NSObject>
@optional

/*!
 * @abstract Query if a date can be selected.
 * @discussion Dates beyound minimim and maximum dates, if set, will not be queried. 
 */
-(BOOL)calendarView:(CWCalendarView*)view canSelectDate:(NSDate*)date;

/*!
 * @abstract Query if a date has annotations, and should be drawn with a dot.
 */
-(BOOL)calendarView:(CWCalendarView *)view hasAnnotationForDate:(NSDate *)date;

/*!
 * @abstract Inform the delegate of a date selection change by the user.
 * @discussion Return the date to allow the selection, nil to cancel the selection,
 *             or a new date to change the selection.
 */
-(NSDate*)calendarView:(CWCalendarView*)view willSelectDate:(NSDate*)date;

/*!
 * @abstract Inform the delegate of a date selection change by the user.
 */
-(void)calendarView:(CWCalendarView*)view didSelectDate:(NSDate*)date;

/*!
 * @abstract The designated initializer, initializing with a 320x308 frame.
 */
-(id)init;

@end
