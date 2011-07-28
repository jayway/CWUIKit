//
//  SampleAppAppDelegate.m
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

#import "SampleAppAppDelegate.h"
#import "CWViewSheet.h"

@implementation SampleAppAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    [self.window makeKeyAndVisible];    
    return YES;
}

-(IBAction)showCalendar;
{
    CWCalendarView* calendarView = [[[CWCalendarView alloc] init] autorelease];
    calendarView.delegate = self;
    calendarView.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 14];
    calendarView.maximumDate = [NSDate dateWithTimeIntervalSinceNow:86400 * 56];

    NSString* title = aswitch.on ? @"Select Date" : nil;
	CWViewSheet* sheet = [[[CWViewSheet alloc] initWithContentView:calendarView
                                                             title:title] autorelease];
    [sheet showFromRect:button.bounds inView:button animated:YES];
}

-(BOOL)calendarView:(CWCalendarView *)view canSelectDate:(NSDate *)date;
{
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSInteger weekday = [components weekday];
    return weekday != 1 && weekday != 7 && [components day] != 13;
}

-(BOOL)calendarView:(CWCalendarView *)view hasAnnotationForDate:(NSDate *)date;
{
    NSInteger foo = (int)([date timeIntervalSinceReferenceDate] / 3000) % 3;
    return foo == 0;
}

-(void)calendarView:(CWCalendarView *)view didSelectDate:(NSDate *)date;
{
    label.text = [date description];
}

@end
