//
//  HEMBirthdatePickerView.m
//  Sense
//
//  Created by Jimmy Lu on 9/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMBirthdatePickerView.h"
#import "UIColor+HEMStyle.h"

CGFloat const kHEMBirthdateValueHeight = 50.0f;

static CGFloat const kHEMBirthdatePickerWidth = 270.0f;
static CGFloat const kHEMBirthdatePickerHeight = 300.0f;

static NSInteger const kHEMBirthdateNumberOfYears = 120;
static NSInteger const kHEMBirthdateNumberOfMonths = 12;

@interface HEMBirthdatePickerView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* monthTableView;
@property (nonatomic, strong) UITableView* dayTableView;
@property (nonatomic, strong) UITableView* yearTableView;

@property (nonatomic, strong) NSDateFormatter* monthFormatter;
@property (nonatomic, strong) UIFont* pickerTextFont;
@property (nonatomic, strong) UIColor* pickerTextColor;
@property (nonatomic, strong) NSMutableDictionary* daysInMonth;

@property (nonatomic, strong) NSMutableArray* accessibleElements;

// selection view components
@property (nonatomic, strong) UIView* topTransparentView;
@property (nonatomic, strong) UIView* botTransparentView;

@end

@implementation HEMBirthdatePickerView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    CGRect defaultFrame = frame;
    frame.size.width = kHEMBirthdatePickerWidth;
    self = [super initWithFrame:defaultFrame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init {
    self = [super initWithFrame:[self defaultFrame]];
    if (self) {
        [self setup];
    }
    return self;
}

- (CGRect)defaultFrame {
    return CGRectMake(0.0f, 0.0f, kHEMBirthdatePickerWidth, kHEMBirthdatePickerHeight);
}

- (void)setup {
    [self setDaysInMonth:[NSMutableDictionary dictionary]];
    
    [self setMonthFormatter:[[NSDateFormatter alloc] init]];
    [[self monthFormatter] setDateFormat:@"MMMM"];
    [[self monthFormatter] setLocale:[NSLocale currentLocale]];
    
    [self setPickerTextColor:[UIColor colorWithWhite:56.0f/255.0f alpha:1.0f]];
    [self setPickerTextFont:[UIFont birthdatePickerTextFont]];
    
    [self setMonthTableView:[self componentTableView]];
    [self addSubview:[self monthTableView]];
    
    [self setDayTableView:[self componentTableView]];
    [self addSubview:[self dayTableView]];
    
    [self setYearTableView:[self componentTableView]];
    [self addSubview:[self yearTableView]];
    
    [self setTopTransparentView:[self transparentView]];
    [self addSubview:[self topTransparentView]];

    [self setBotTransparentView:[self transparentView]];
    [self addSubview:[self botTransparentView]];
}

- (UITableView*)componentTableView {
    UITableView* tv = [[UITableView alloc] initWithFrame:[self bounds]];
    [tv setShowsHorizontalScrollIndicator:NO];
    [tv setShowsVerticalScrollIndicator:NO];
    [tv setDelegate:self];
    [tv setDataSource:self];
    [tv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tv setBackgroundColor:[UIColor clearColor]];
    return tv;
}

- (UIView*)transparentView {
    UIView* view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [view setUserInteractionEnabled:NO];
    return view;
}

- (void)layoutSubviews {
    if (CGRectIsEmpty([self bounds])) {
        [self setBounds:[self defaultFrame]];
    }
    
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGFloat bHeight = CGRectGetHeight([self bounds]);
    
    CGRect monthFrame = [[self monthTableView] frame];
    monthFrame.size.width = ceilf(bWidth * 0.45f);
    monthFrame.size.height = bHeight;
    [[self monthTableView] setFrame:monthFrame];
    
    CGRect dayFrame = [[self dayTableView] frame];
    dayFrame.size.width = ceilf(bWidth * 0.19f);
    dayFrame.size.height = bHeight;
    dayFrame.origin.x = CGRectGetMaxX(monthFrame);
    [[self dayTableView] setFrame:dayFrame];
    
    CGRect yearFrame = [[self yearTableView] frame];
    yearFrame.size.width = ceilf(bWidth * 0.36f);
    yearFrame.size.height = bHeight;
    yearFrame.origin.x = CGRectGetMaxX(dayFrame);
    [[self yearTableView] setFrame:yearFrame];
    
    CGFloat transparentHeight = ceilf((bHeight - kHEMBirthdateValueHeight)/2.0f);
    
    CGRect topTransparentFrame = [[self topTransparentView] frame];
    topTransparentFrame.size.height = transparentHeight;
    topTransparentFrame.size.width = bWidth;
    [[self topTransparentView] setFrame:topTransparentFrame];
    
    CGRect botTransparentFrame = [[self botTransparentView] frame];
    botTransparentFrame.origin.y = bHeight-transparentHeight;
    botTransparentFrame.size.height = transparentHeight;
    botTransparentFrame.size.width = bWidth;
    [[self botTransparentView] setFrame:botTransparentFrame];
    
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
    CGFloat lineWidth = 1.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [[UIColor tintColor] CGColor]);
    CGContextSetLineWidth(context, lineWidth);
    
    CGFloat padding = 10.0f;
    CGFloat sideInset = 12.0f;
    CGFloat y = CGRectGetMinY([[self botTransparentView] frame]) - lineWidth;
    CGContextMoveToPoint(context, sideInset, y);
    CGContextAddLineToPoint(context, CGRectGetMaxX([[self monthTableView] frame]) - padding, y);
    
    CGContextMoveToPoint(context, CGRectGetMinX([[self dayTableView] frame]), y);
    CGContextAddLineToPoint(context, CGRectGetMaxX([[self dayTableView] frame]), y);
    
    CGContextMoveToPoint(context, CGRectGetMinX([[self yearTableView] frame]) + padding, y);
    CGContextAddLineToPoint(context, CGRectGetMaxX([[self yearTableView] frame])-sideInset, y);
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (NSInteger)numberOfDaysInSelectedMonth {
    NSInteger selectedMonth = [self selectedMonth];
    return [self numberOfDaysInMonth:selectedMonth];
}

- (NSInteger)numberOfDaysInMonth:(NSInteger)month {
    if (month < 1 && month > 12) return 0;
    
    NSNumber* monthObject = @(month);
    NSNumber* days = [[self daysInMonth] objectForKey:monthObject];
    if (days == nil) {
        NSDateComponents* components = [[NSDateComponents alloc] init];
        [components setMonth:month];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitMonth
                                      forDate:[calendar dateFromComponents:components]];
        
        if (month == 2 && range.length < 29) {
            range.length = 29;
        }
        
        days = @(range.length);
        
        [[self daysInMonth] setObject:days forKey:monthObject];
    }
    return [days integerValue];
}

#pragma mark - Accessibility

- (NSArray *)accessibleElements {
    if ( _accessibleElements != nil ) {
        return _accessibleElements;
    }
    _accessibleElements = [[NSMutableArray alloc] init];
    
    [_accessibleElements addObject:[self monthTableView]];
    [_accessibleElements addObject:[self dayTableView]];
    [_accessibleElements addObject:[self yearTableView]];
    
    return _accessibleElements;
}

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    return [[self accessibleElements] count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return [[self accessibleElements] objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [[self accessibleElements] indexOfObject:element];
}


#pragma mark - TableView Helpers

- (NSInteger)lastRowOf:(UITableView*)tableView {
    NSInteger lastRow = 0;
    if (tableView == [self monthTableView]) {
        lastRow = kHEMBirthdateNumberOfMonths + 1;
    } else if (tableView == [self dayTableView]) {
        lastRow = [self numberOfDaysInSelectedMonth];
    } else {
        lastRow = kHEMBirthdateNumberOfYears + 1;
    }
    return lastRow;
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (tableView == [self monthTableView]) {
        rows = kHEMBirthdateNumberOfMonths;
    } else if (tableView == [self dayTableView]) {
        rows = [self numberOfDaysInSelectedMonth];
    } else if (tableView == [self yearTableView]) {
        rows = kHEMBirthdateNumberOfYears;
    }
    return rows + 2; // +2 for top and bottom padding so first and last row can be "selected"
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rows = 0;
    if (tableView == [self monthTableView]) {
        rows = kHEMBirthdateNumberOfMonths;
    } else if (tableView == [self dayTableView]) {
        rows = [self numberOfDaysInSelectedMonth];
    } else if (tableView == [self yearTableView]) {
        rows = kHEMBirthdateNumberOfYears;
    }
    
    CGFloat valueCellHeight = kHEMBirthdateValueHeight;
    CGFloat emptyCellHeight = ceilf((CGRectGetHeight([tableView bounds])/2)-(valueCellHeight/2));
    return [indexPath row] > 0 && [indexPath row] <= rows ? valueCellHeight : emptyCellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = nil;
    if ([indexPath row] == 0 || [indexPath row] == [self lastRowOf:tableView]) {
        static NSString* emptyCellId = @"empty";
        cellId = emptyCellId;
    } else {
        static NSString* valueCellId = @"value";
        cellId = valueCellId;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* title = nil;
    NSTextAlignment alignment = NSTextAlignmentLeft;
    
    if ([indexPath row] > 0 && [indexPath row] < [tableView numberOfRowsInSection:0] - 1) {
        NSInteger dataRow = [indexPath row];
        if (tableView == [self monthTableView]) {
            title = [[[self monthFormatter] standaloneMonthSymbols] objectAtIndex:dataRow - 1];
            alignment = NSTextAlignmentLeft;
        } else if (tableView == [self dayTableView]) {
            title = [NSString stringWithFormat:@"%ld", dataRow];
            alignment = NSTextAlignmentCenter;
        } else if (tableView == [self yearTableView]) {
            NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                           fromDate:[NSDate date]];
            title = [NSString stringWithFormat:@"%ld", [components year]-kHEMBirthdateNumberOfYears+dataRow+1];
            alignment = NSTextAlignmentRight;
        }
    }
    
    [cell setIndentationLevel:-1];
    [[cell textLabel] setText:title];
    [[cell textLabel] setTextAlignment:alignment];
    [[cell textLabel] setFont:[self pickerTextFont]];
    [[cell textLabel] setTextColor:[self pickerTextColor]];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    if (tableView == [self monthTableView]) {
        [[self dayTableView] reloadData];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // if decelerating, let scrollViewDidEndDecelerating: handle it
    if (decelerate == NO) {
        [self snapTableView:(UITableView*)scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self snapTableView:(UITableView*)scrollView];
}

- (void)snapTableView:(UITableView*)tableView {
    [tableView selectRowAtIndexPath:[self selectedPathFor:tableView]
                           animated:YES
                     scrollPosition:UITableViewScrollPositionMiddle];
    if (tableView == [self monthTableView]) {
        [[self dayTableView] reloadData];
    }
}

#pragma mark - Setting Defaults

- (void)selectValueRow:(NSInteger)row inTableView:(UITableView*)tableView {
    NSIndexPath* path = [NSIndexPath indexPathForRow:row+1 inSection:0];
    [tableView selectRowAtIndexPath:path
                           animated:NO
                     scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)setMonth:(NSInteger)month day:(NSInteger)day yearsPast:(NSInteger)yearsPast {
    if (month < 1
        || month > 12
        || day < 1
        || day > [self numberOfDaysInMonth:month]
        || yearsPast < 0
        || yearsPast > kHEMBirthdateNumberOfYears) {
        return;
    }
    [self selectValueRow:month-1 inTableView:[self monthTableView]];
    [self selectValueRow:day-1 inTableView:[self dayTableView]];
    [self selectValueRow:[self lastRowOf:[self yearTableView]]-yearsPast-2
             inTableView:[self yearTableView]];
}

#pragma mark - Selected Values

- (NSIndexPath*)selectedPathFor:(UITableView*)tableView {
    CGPoint center = CGPointMake(CGRectGetMidX([tableView bounds]),
                                 CGRectGetMidY([tableView bounds]));
    return [tableView indexPathForRowAtPoint:center];
}

- (NSInteger)selectedMonth {
    return [[self selectedPathFor:[self monthTableView]] row];
}

- (NSInteger)selectedDay {
    return [self selectedIntegerValueInTableView:self.dayTableView];
}

- (NSInteger)selectedYear {
    return [self selectedIntegerValueInTableView:self.yearTableView];
}

- (NSInteger)selectedIntegerValueInTableView:(UITableView*)tableView {
    NSIndexPath* path = [self selectedPathFor:tableView];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:path];
    return [cell.textLabel.text integerValue];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[self monthTableView] setDelegate:nil];
    [[self monthTableView] setDataSource:nil];
    
    [[self dayTableView] setDelegate:nil];
    [[self dayTableView] setDataSource:nil];
    
    [[self yearTableView] setDelegate:nil];
    [[self yearTableView] setDataSource:nil];
}

@end
