//
//  CWCalendarView.m
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

#import "CWCalendarView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSCalendar+CWAdditions.h"

@implementation CWCalendarView

#pragma mark -
#pragma mark Properties

-(void)setDelegate:(id<CWCalendarViewDelegate>)delegate;
{
    flags.delegateCanSelect = [delegate respondsToSelector:@selector(calendarView:canSelectDate:)];
    flags.delegateHasAnnotation = [delegate respondsToSelector:@selector(calendarView:hasAnnotationForDate:)];
    flags.delegateWillSelect = [delegate respondsToSelector:@selector(calendarView:willSelectDate:)];
    flags.delegateDidSelect = [delegate respondsToSelector:@selector(calendarView:didSelectDate:)];
    _delegate = delegate;
}

-(void)setSelectedDate:(NSDate *)selectedDate;
{
    if (![_selectedDate isEqualToDate:selectedDate]) {
        [_selectedDate autorelease];
        _selectedDate = [selectedDate copy];
        [self setNeedsDisplay];
    }
}

-(NSDate*)currentMonthDate;
{
    if (_currentMonthDate == nil) {
        if (_selectedDate) {
            self.currentMonthDate = _selectedDate;
        } else {
            self.currentMonthDate = [[[NSDate date] laterDate:_minimumDate] earlierDate:_maximumDate];
        }
    }
    return _currentMonthDate;
}

-(void)setCurrentMonthDate:(NSDate *)date;
{
    if (![_currentMonthDate isEqualToDate:date]) {
        [_currentMonthDate autorelease];
        _currentMonthDate = [[self.calendar truncateDate:date 
                                          toCalendarUnit:NSMonthCalendarUnit] retain];
        [currentTopLeftDate release], currentTopLeftDate = nil;
        [self setNeedsDisplay];
    }
    if (currentTopLeftDate == nil) {
        NSDateComponents* currentMonthComponents = [self.calendar components:NSWeekdayCalendarUnit 
                                                                    fromDate:_currentMonthDate];
        NSUInteger firstWeekDay = [self.calendar firstWeekday];
        NSInteger firstMonthViewDayOffset = [currentMonthComponents weekday] - firstWeekDay;
        while (firstMonthViewDayOffset < 0) {
            firstMonthViewDayOffset += 7;
        }
        NSDateComponents* dateOffset = [[[NSDateComponents alloc] init] autorelease];
        [dateOffset setDay:-firstMonthViewDayOffset];
        currentTopLeftDate = [[self.calendar dateByAddingComponents:dateOffset 
                                                             toDate:_currentMonthDate 
                                                            options:0] retain];
    }
}

-(void)setMinimumDate:(NSDate *)date;
{
    [_minimumDate autorelease];
    _minimumDate = [[self.calendar truncateDate:date 
                                 toCalendarUnit:NSDayCalendarUnit] retain];
    [self setNeedsDisplay];
}

-(void)setMaximumDate:(NSDate *)date;
{
    [_maximumDate autorelease];
    _maximumDate = [[self.calendar truncateDate:date 
                                 toCalendarUnit:NSDayCalendarUnit] retain];
    [self setNeedsDisplay];
}

@synthesize delegate = _delegate;
@synthesize selectedDate = _selectedDate;
@synthesize currentMonthDate = _currentMonthDate;
@synthesize maximumDate = _maximumDate;
@synthesize minimumDate = _minimumDate;
@synthesize calendar = _calendar;

#pragma mark -
#pragma mark Instance life cycle

-(void)primitiveInit;
{
    _calendar = [[NSCalendar currentCalendar] retain];
    UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                           action:@selector(handleTapGesture:)] autorelease];
    [self addGestureRecognizer:tap];
}

-(id)init;
{
    return [self initWithFrame:CGRectMake(0, 0, 320, 308)];
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size = CGSizeMake(320, 44 * 7);
    self = [super initWithFrame:frame];
    if (self) {
        [self primitiveInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self primitiveInit];
        CGRect bounds = self.bounds;
        bounds.size = CGSizeMake(320, 44 * 7);
        self.bounds = bounds;
    }
    return self;
}

- (void)dealloc
{
    [_selectedDate release];
    [_currentMonthDate release];
    [_maximumDate release];
    [_minimumDate release];
    [_calendar release];
    [currentTopLeftDate release];
    [super dealloc];
}

#pragma mark -
#pragma mark Helper methods

-(BOOL)canGotoPreviousMonth;
{
    return [_minimumDate compare:self.currentMonthDate] != NSOrderedDescending;
}

-(BOOL)canGotoNextMonth;
{
    if (_maximumDate) {
        NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
        [components setMonth:1];
        NSDate* nextMonthDate = [self.calendar dateByAddingComponents:components 
                                                               toDate:self.currentMonthDate 
                                                              options:0];
        return [_maximumDate compare:nextMonthDate] != NSOrderedAscending;
    }
    return YES;
}

-(BOOL)canSelectDate:(NSDate*)date;
{
    BOOL canSelectDate = [_minimumDate compare:date] != NSOrderedDescending && [_maximumDate compare:date] != NSOrderedAscending;    
    if (canSelectDate && flags.delegateCanSelect) {
        canSelectDate = [self.delegate calendarView:self canSelectDate:date];
    }
    return canSelectDate;
}

-(NSDate*)dateForRow:(NSInteger)row column:(NSInteger)col;
{
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    [components setDay:row * 7 + col];
    return [self.calendar dateByAddingComponents:components 
                                          toDate:currentTopLeftDate 
                                         options:0];
}

#pragma mark -
#pragma mark - Cached drawing primitives

#define CWStaticColor(name, color) -(UIColor*)name{static UIColor*c=nil;if(c==nil)c=[(color)retain];return c;}

CWStaticColor(cellBackgroundColor, [UIColor colorWithRed:0.87f green:0.87f blue:0.89f alpha:1])
CWStaticColor(disabledCellBackgroundColor, [UIColor colorWithRed:0.80f green:0.75f blue:0.74f alpha:1])
CWStaticColor(lightCellBorderColor, [UIColor colorWithWhite:0.92f alpha:1])
CWStaticColor(darkCellBorderColor, [UIColor colorWithWhite:0.63f alpha:1])
CWStaticColor(lightDisabledCellBorderColor, [UIColor colorWithRed:0.92f green:0.90f blue:0.89f alpha:1])
CWStaticColor(darkDisabledCellBorderColor, [UIColor colorWithRed:0.63f green:0.61f blue:0.60f alpha:1])
CWStaticColor(currentSelectedCellBackgroundColor, [UIColor colorWithRed:0.04f green:0.19f blue:0.57f alpha:1])
CWStaticColor(currentCellBackgroundColor, [UIColor colorWithRed:0.15f green:0.25f blue:0.38f alpha:1])
CWStaticColor(currentSelectedCellFillColor, [UIColor colorWithRed:0.10f green:0.50f blue:0.90f alpha:0.2f])
CWStaticColor(currentCellFillColor, [UIColor colorWithRed:0.45f green:0.54f blue:0.65f alpha:0.2f])
CWStaticColor(selectedCellBorder, [UIColor colorWithRed:0.16f green:0.21f blue:0.28f alpha:1])

CWStaticColor(textColor, [UIColor colorWithRed:0.24f green:0.29f blue:0.35f alpha:1]);
CWStaticColor(textHighlightColor, [UIColor whiteColor])
CWStaticColor(disabledTextColor, [UIColor colorWithRed:0.57f green:0.59f blue:0.63f alpha:1])
CWStaticColor(disabledTextHighlightColor, [UIColor colorWithWhite:0.9f alpha:1])
CWStaticColor(selectedTextColor, [UIColor whiteColor])
CWStaticColor(selectedTextHighlightColor, [UIColor colorWithWhite:0.10f alpha:1])
CWStaticColor(dimmedCurrentTextColor, [UIColor colorWithRed:0.57f green:0.60f blue:0.63f alpha:1])
CWStaticColor(dimmedSelectedTextColor, [UIColor colorWithRed:0.78f green:0.80f blue:0.82f alpha:1])
CWStaticColor(invalidTextColor, [UIColor colorWithRed:0.43f green:0.44f blue:0.46f alpha:1])
CWStaticColor(dimmedInvalidTextColor, [UIColor colorWithRed:0.63f green:0.59f blue:0.57f alpha:1])


-(CGGradientRef)headerGradient;
{
    static CGGradientRef g = NULL;
    if (g == NULL) {
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        NSArray* colors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithRed:0.96f green:0.96f blue:0.97f alpha:1].CGColor,
                           (id)[UIColor colorWithRed:0.80f green:0.80f blue:0.82f alpha:1].CGColor,
                           nil];
        g = CGGradientCreateWithColors(space, (CFArrayRef)colors, (CGFloat[4]){0.f, 1.f});
        CGColorSpaceRelease(space);
    }
    return g;
}

-(CGGradientRef)selectedCellGradient;
{
    static CGGradientRef g = NULL;
    if (g == NULL) {
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        NSArray* colors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithRed:0.74f green:0.85f blue:0.97f alpha:1].CGColor,
                           (id)[UIColor colorWithRed:0.45f green:0.69f blue:0.94f alpha:1].CGColor,
                           (id)[UIColor colorWithRed:0.17f green:0.54f blue:0.91f alpha:1].CGColor,
                           (id)[UIColor colorWithRed:0.00f green:0.45f blue:0.89f alpha:1].CGColor,
                           nil];
        g = CGGradientCreateWithColors(space, (CFArrayRef)colors, (CGFloat[4]){0.02f, 0.06f, 0.5f, 0.51f});
        CGColorSpaceRelease(space);
    }
    return g;
}

-(NSDateFormatter*)dateFormatterWithFormat:(NSString*)format;
{
    static NSMutableDictionary* fs = nil;
    NSDateFormatter* f = [fs objectForKey:format];
    if (f == nil) {
        f = [[[NSDateFormatter alloc] init] autorelease];
        [f setDateFormat:format];
        if (fs == nil) {
            fs = [[NSMutableDictionary alloc] initWithCapacity:4];
        }
        [fs setObject:f forKey:format];
    }
    return f;
}

#pragma mark -
#pragma mark Drawing methods

-(void)drawHeaderBackgroundInRect:(CGRect)rect;
{
    // Draw background
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    CGContextClipToRect(c, rect);
    CGContextDrawLinearGradient(c, [self headerGradient], rect.origin, CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 0);
    CGContextRestoreGState(c);
    [[self darkCellBorderColor] set];
    [[UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(-1, -1, 0.5f, -1))] stroke];
    
}

-(void)drawHeaderTitleInRect:(CGRect)rect;
{
    NSDateFormatter* formatter = [self dateFormatterWithFormat:@"MMM yyyy"];
    NSString* month = [formatter stringFromDate:self.currentMonthDate];
    CGRect monthRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(4, 0, 10, 0));
    UIFont* font = [UIFont boldSystemFontOfSize:20];
    [[self textHighlightColor] set];
    [month drawInRect:monthRect 
             withFont:font 
        lineBreakMode:UILineBreakModeMiddleTruncation 
            alignment:UITextAlignmentCenter];
    [[self textColor] set];
    monthRect.origin.y--;
    [month drawInRect:monthRect 
             withFont:font 
        lineBreakMode:UILineBreakModeMiddleTruncation 
            alignment:UITextAlignmentCenter];
}

-(void)drawHeaderDayColumnTitles;
{
    NSDateFormatter* formatter = [self dateFormatterWithFormat:@"EEE"];
    UIFont* font = [UIFont boldSystemFontOfSize:10];
    for (int col = 0; col < 7; col++) {
        NSDate* date = [self dateForRow:0 column:col];
        NSString* weekday = [formatter stringFromDate:date];
        CGRect dayRect = CGRectMake(col * 46 - 1, 30, 46, 14);
        [[self textHighlightColor] set];
        [weekday drawInRect:dayRect 
                   withFont:font 
              lineBreakMode:UILineBreakModeMiddleTruncation 
                  alignment:UITextAlignmentCenter];
        [[self textColor] set];
        dayRect.origin.y--;
        [weekday drawInRect:dayRect 
                   withFont:font 
              lineBreakMode:UILineBreakModeMiddleTruncation 
                  alignment:UITextAlignmentCenter];
    }
}

-(void)drawHeaderNavigationArrows;
{
    UIBezierPath* prevPath = [UIBezierPath bezierPath];
    [prevPath moveToPoint:CGPointMake(18, 14.5f)];
    [prevPath addLineToPoint:CGPointMake(29, 7.5f)];
    [prevPath addLineToPoint:CGPointMake(29, 21.5f)];
    [prevPath closePath];
    UIBezierPath* nextPath = [[prevPath copy] autorelease];
    [nextPath applyTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(-1, 1), -320, 0)];
    
    [[self textHighlightColor] setFill];
    [prevPath fill];
    [nextPath fill];
    
    [prevPath applyTransform:CGAffineTransformMakeTranslation(0, -1)];
    if ([self canGotoPreviousMonth]) {
        [[self textColor] setFill];
    } else {
        [[self disabledTextColor] set];
    }
    [prevPath fill];
    if ([self canGotoNextMonth]) {
        [[self textColor] setFill];
    } else {
        [[self disabledTextColor] set];
    }    
    [nextPath applyTransform:CGAffineTransformMakeTranslation(0, -1)];
    [nextPath fill];
}

-(void)drawHeaderInRect:(CGRect)rect;
{
    [self drawHeaderBackgroundInRect: rect];
    [self drawHeaderTitleInRect: rect];
    [self drawHeaderDayColumnTitles];
    [self drawHeaderNavigationArrows];
}

- (void)drawCurrentCellBackgroundInRect:(CGRect)rect isSelectedDate:(BOOL)isSelectedDate;  
{
    if (isSelectedDate) {
        [[self currentSelectedCellBackgroundColor] setFill];
    } else {
        [[self currentCellBackgroundColor] setFill];
    }
    [[UIBezierPath bezierPathWithRect:rect] fill];
    if (isSelectedDate) {
        [[self currentSelectedCellFillColor] setFill];
    } else {
        [[self currentCellFillColor] setFill];
    }
    for (CGFloat i = 0.0f; i < 5.0f; i += 0.5f) {
        CGRect insetRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(i, i, i, i));
        [[UIBezierPath bezierPathWithRoundedRect:insetRect 
                                    cornerRadius:1.0f] fill];
    }
}

-(void)drawCellBackgroundInRect:(CGRect)rect canSelectDate:(BOOL)canSelectDate isSelectedDate:(BOOL)isSelectedDate  
{
    if (isSelectedDate) {
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSaveGState(c);
        CGContextClipToRect(c, rect);
        CGContextDrawLinearGradient(c, [self selectedCellGradient], rect.origin, CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 0);
        CGContextRestoreGState(c);
        CGRect insetRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f));
        [[self selectedCellBorder] set];
        [[UIBezierPath bezierPathWithRect:insetRect] stroke];
    } else {
        if (canSelectDate) {
            [[self cellBackgroundColor] setFill];
        } else {
            [[self disabledCellBackgroundColor] setFill];
        }
        [[UIBezierPath bezierPathWithRect:rect] fill];
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(rect.origin.x + 0.5f, rect.origin.y + 0.5f)];
        [path addLineToPoint:CGPointMake((rect.origin.x + rect.size.width) - 0.5f , rect.origin.y + 0.5f)];
        [path addLineToPoint:CGPointMake((rect.origin.x + rect.size.width) - 0.5f , (rect.origin.y + rect.size.height) - 0.5f)];
        if (canSelectDate) {
            [[self lightCellBorderColor] set];
        } else {
            [[self lightDisabledCellBorderColor] set];
        }
        [path stroke];
        path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(rect.origin.x + 0.5f, rect.origin.y + 0.5f)];
        [path addLineToPoint:CGPointMake(rect.origin.x + 0.5f , (rect.origin.y + rect.size.height) - 0.5f)];
        [path addLineToPoint:CGPointMake((rect.origin.x + rect.size.width) - 0.5f , (rect.origin.y + rect.size.height) - 0.5f)];
        if (canSelectDate) {
            [[self darkCellBorderColor] set];
        } else {
            [[self darkDisabledCellBorderColor] set];
        }
        [path stroke];
    }
}

-(void)drawCellText:(NSString*)day inRect:(CGRect)rect isSameMonth:(BOOL)isSameMonth canSelectDate:(BOOL)canSelectDate isSelectedDate:(BOOL)isSelectedDate isCurrentDate:(BOOL)isCurrentDate hasAnnotation:(BOOL)hasAnnotation;
{
    UIFont* font = [UIFont boldSystemFontOfSize:24];
    UIFont* annotationFont = hasAnnotation ? [UIFont boldSystemFontOfSize:16] : nil;
    if (isCurrentDate || isSelectedDate) {
        [[self selectedTextHighlightColor] set];
    } else {
        if (canSelectDate) {
            [[self textHighlightColor] set];
        } else {
            [[self disabledTextHighlightColor] set];
        }
    }
    rect.origin.y += (!isCurrentDate && isSelectedDate) ? 4 : 6;
    [day drawInRect:rect 
           withFont:font 
      lineBreakMode:UILineBreakModeMiddleTruncation 
          alignment:UITextAlignmentCenter];
    if (hasAnnotation) {
        CGRect annotationRect = rect;
        annotationRect.origin.y += 19;
        annotationRect.origin.x += 1;
        [@"∙" drawInRect:annotationRect 
                  withFont:annotationFont 
             lineBreakMode:UILineBreakModeMiddleTruncation 
                 alignment:UITextAlignmentCenter];   
    }
    if (!isCurrentDate && isSelectedDate) {
        rect.origin.y++;
    } else {
        rect.origin.y--;
    }
    if (canSelectDate && isSameMonth) {
        if (isCurrentDate || isSelectedDate) {
            [[self selectedTextColor] set];
        } else {
            [[self textColor] set];
        }
    } else {
        if (isCurrentDate) {
            [[self dimmedCurrentTextColor] set];
        } else if (isSelectedDate) {
            [[self dimmedSelectedTextColor] set];
        } else {
            if (canSelectDate) {
                [[self disabledTextColor] set];
            } else {
                if (isSameMonth) {
                    [[self invalidTextColor] set];
                } else {
                    [[self dimmedInvalidTextColor] set];
                }
            }
        }
    }
    [day drawInRect:rect 
           withFont:font 
      lineBreakMode:UILineBreakModeMiddleTruncation 
          alignment:UITextAlignmentCenter];   
    if (hasAnnotation) {
        CGRect annotationRect = rect;
        annotationRect.origin.y += 19;
        annotationRect.origin.x += 1;
        [@"∙" drawInRect:annotationRect 
                withFont:annotationFont 
           lineBreakMode:UILineBreakModeMiddleTruncation 
               alignment:UITextAlignmentCenter];   
    }
}

-(void)drawCellForDate:(NSDate*)date inRect:(CGRect)rect;
{
    BOOL isSameMonth = [self.calendar compareDate:date 
                                           toDate:self.currentMonthDate 
                        withCalendarUnitPrecision:NSMonthCalendarUnit] == NSOrderedSame;
    BOOL canSelectDate = [self canSelectDate:date];
    BOOL isSelectedDate = [self.calendar compareDate:date 
                                              toDate:self.selectedDate
                           withCalendarUnitPrecision:NSDayCalendarUnit] == NSOrderedSame;
    BOOL isCurrentDate = [self.calendar compareDate:date 
                                             toDate:[NSDate date] 
                          withCalendarUnitPrecision:NSDayCalendarUnit] == NSOrderedSame;
    BOOL hasAnnotation = flags.delegateHasAnnotation ? [self.delegate calendarView:self hasAnnotationForDate:date] : NO;
    
    if (isCurrentDate) {
        [self drawCurrentCellBackgroundInRect:rect 
                               isSelectedDate:isSelectedDate];
    } else {
        [self drawCellBackgroundInRect:rect 
                         canSelectDate:canSelectDate 
                        isSelectedDate:isSelectedDate];
    }

    NSDateComponents* components = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSString* day = [NSString stringWithFormat:@"%d", [components day]];
    [self drawCellText:day 
                inRect:rect 
           isSameMonth:isSameMonth 
         canSelectDate:canSelectDate 
        isSelectedDate:isSelectedDate 
         isCurrentDate:isCurrentDate 
         hasAnnotation:hasAnnotation];
}

-(CGRect)rectForCellAtRow:(NSInteger)row column:(NSInteger)col;
{
    return CGRectMake((46 * col) - 1, 44 * (row + 1), 46, 44);    
}

-(void)drawSelectedDateCornerMarkersIfNeeded;
{
    if (_selectedDate == nil) {
        return;
    }
    if ([_selectedDate compare:currentTopLeftDate] == NSOrderedAscending) {
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 44)];
        [path addLineToPoint:CGPointMake(15, 44)];
        [path addLineToPoint:CGPointMake(0, 44 + 15)];
        [path closePath];
        [path addClip];
        [self drawCellBackgroundInRect:[self rectForCellAtRow:0 column:0] 
                         canSelectDate:YES 
                        isSelectedDate:YES];
        [path stroke];
    } else {
        NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
        [components setDay:7 * 6];
        NSDate* nextTopLeftDate = [self.calendar dateByAddingComponents:components toDate:currentTopLeftDate options:0];
        if ([_selectedDate compare:nextTopLeftDate] != NSOrderedAscending) {
            UIBezierPath* path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(320, 44 * 7)];
            [path addLineToPoint:CGPointMake(320 - 15, 44 * 7)];
            [path addLineToPoint:CGPointMake(320, 44 * 7 - 15)];
            [path closePath];
            [path addClip];
            [self drawCellBackgroundInRect:[self rectForCellAtRow:5 column:6] 
                             canSelectDate:YES 
                            isSelectedDate:YES];
            [path stroke];
        }
    }
}

-(void)drawRect:(CGRect)rect;
{
    CGRect headerRect = rect;
    headerRect.size.height = 44;
    [self drawHeaderInRect:headerRect];
    for (NSInteger row = 0; row < 7; row++) {
        for (NSInteger col = 0; col < 7; col++) {
            NSDate* date = [self dateForRow:row column:col];
            CGRect rect = [self rectForCellAtRow:row column:col];
            [self drawCellForDate:date inRect:rect];
        }
    }
    [self drawSelectedDateCornerMarkersIfNeeded];
}


#pragma mark -
#pragma mark Handle selections

-(void)handleTapGesture:(UITapGestureRecognizer*)tap;
{
    CGPoint location = [tap locationInView:self];
    if (location.y < 44) {
        if (location.x < 50 && [self canGotoPreviousMonth]) {
            NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
            [components setMonth:-1];
            self.currentMonthDate = [self.calendar dateByAddingComponents:components 
                                                                   toDate:self.currentMonthDate 
                                                                  options:0];
        } else if (location.x > 270 && [self canGotoNextMonth]) {
            NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
            [components setMonth:1];
            self.currentMonthDate = [self.calendar dateByAddingComponents:components 
                                                                   toDate:self.currentMonthDate 
                                                                  options:0];
        }
    } else {
        location.y -= 44;
        int row = location.y / 44;
        int col = location.x / 46;
        NSDate* date = [self dateForRow:row column:col];
        if ([self canSelectDate:date]) {
            if (flags.delegateWillSelect) {
                date = [self.delegate calendarView:self willSelectDate:date];
            }
            if (date) {
                self.selectedDate = date;
                self.currentMonthDate = date;
                if (flags.delegateDidSelect) {
                    [self.delegate calendarView:self didSelectDate:date];
                }
            }
        }
    }
}

@end
