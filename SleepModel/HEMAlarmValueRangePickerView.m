//
//  HEMAlarmValueRangePickerView.m
//  Sense
//
//  Created by Jimmy Lu on 10/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <NAPickerView/NAPickerView.h>
#import "NSBundle+HEMUtils.h"
#import "Sense-Swift.h"
#import "HEMAlarmValueRangePickerView.h"

static CGFloat const HEMAlarmPickerDarkGradient = 0.8f;
static CGFloat const HEMAlarmPickerLightGradient = 0.05f;
static CGFloat const HEMAlarmValueRangePickerWidth = 90.f;
static CGFloat const HEMAlarmValueRangeDividerWidth = 40.0f;
static NSInteger const HEMAlarmValueRangeDefaultDiff = 10;

@interface HEMAlarmValueRangePickerView()

@property (nonatomic, strong) NAPickerView* minPicker;
@property (nonatomic, strong) NAPickerView* maxPicker;
@property (nonatomic, strong) UIView* rangeDivider;
@property (nonatomic, strong) NSArray<NSString*>* values;
@property (nonatomic, assign) BOOL configuredGradients;

@end

@implementation HEMAlarmValueRangePickerView

+ (instancetype)defaultRangePickerView {
    return [NSBundle loadNibWithOwner:[self class]];
}

- (void)addGradient:(NSArray*)colors toView:(UIView*)view {
    if (view && colors) {
        [[[view layer] sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        
        CAGradientLayer* layer = [CAGradientLayer layer];
        [layer setFrame:[view bounds]];
        [layer setColors:colors];
        [[view layer] addSublayer:layer];
        [view setBackgroundColor:[UIColor clearColor]];
        [view setUserInteractionEnabled:NO];
    }
}

- (void)configureGradientViews {
    UIColor* bgColor = [SenseStyle colorWithGroup:GroupExpansionRangePicker property:ThemePropertyBackgroundColor];
    [self setBackgroundColor:bgColor];
    
    NSArray* colors = @[(id) [[bgColor colorWithAlphaComponent:HEMAlarmPickerDarkGradient] CGColor],
                        (id) [[bgColor colorWithAlphaComponent:HEMAlarmPickerLightGradient] CGColor]];
    
    [self addGradient:colors toView:[self topGradientView]];
    [self addGradient:[[colors reverseObjectEnumerator] allObjects] toView:[self botGradientView]];
}

- (void)configureValuesArray:(NSInteger)min max:(NSInteger)max {
    NSMutableArray* items = [NSMutableArray arrayWithCapacity:max - min];
    NSInteger i;
    for (i = min; i <= max; i++) {
        [items addObject:[NSString stringWithFormat:@"%ld%@", i, [self unitSymbol] ?: @""]];
    }
    [self setValues:items];
}

- (NSString*)pickerTextWithValue:(NSInteger)value {
    return [NSString stringWithFormat:@"%ld%@", value, [self unitSymbol] ?: @""];
}

- (NSInteger)indexOfValue:(NSInteger)value {
    NSString* text = [self pickerTextWithValue:value];
    return [[self values] indexOfObject:text];
}

- (void)configureRangeWithMin:(NSInteger)min max:(NSInteger)max {
    [self configureValuesArray:min max:max];
    
    CGFloat maxHeight = CGRectGetHeight([self bounds]);
    CGFloat maxWidth = CGRectGetWidth([self bounds]);
    CGFloat pickerWidth = HEMAlarmValueRangePickerWidth;
    CGFloat pickerWidths = (2 *pickerWidth);
    CGFloat x = (maxWidth - pickerWidths - HEMAlarmValueRangeDividerWidth) / 2.0f;
    
    __weak typeof(self) weakSelf = self;
    [self setMinPicker:[self pickerWithXOrigin:x width:pickerWidth onSelection:^(NSNumber *value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([value integerValue] > [strongSelf selectedMaxValue]) {
            NSInteger valueIndex = [strongSelf indexOfValue:[value integerValue]];
            NSInteger maxIndex = MIN([[strongSelf values] count] - 1, valueIndex + HEMAlarmValueRangeDefaultDiff);
            [[strongSelf maxPicker] setIndex:maxIndex];
        }
        [strongSelf setSelectedMinValue:[value integerValue]];
        [[strongSelf pickerDelegate] didUpdateSelectedValuesFrom:strongSelf];
    }]];
    
    NSInteger valueIndex = MAX(0, [self indexOfValue:[self selectedMinValue]]);
    if (valueIndex < [[self values] count]) {
        [[self minPicker] setIndex:valueIndex];
    }
    
    [self insertSubview:[self minPicker] atIndex:0];
    
    UIColor* highlightedColor = [SenseStyle colorWithGroup:GroupExpansionRangePicker property:ThemePropertyTextHighlightedColor];
    UIFont* highlightedFont = [SenseStyle fontWithGroup:GroupExpansionRangePicker property:ThemePropertyTextFont];
    
    // add divider
    CGRect dividerFrame = CGRectZero;
    dividerFrame.size.width = HEMAlarmValueRangeDividerWidth;
    dividerFrame.size.height = maxHeight;
    dividerFrame.origin.x = CGRectGetMaxX([[self minPicker] frame]);
    
    UILabel* dividerLabel = [[UILabel alloc] initWithFrame:dividerFrame];
    [dividerLabel setTextAlignment:NSTextAlignmentCenter];
    [dividerLabel setFont:highlightedFont];
    [dividerLabel setTextColor:highlightedColor];
    [dividerLabel setText:@"-"];
    [dividerLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight
                                    | UIViewAutoresizingFlexibleWidth];
    [self setRangeDivider:dividerLabel];
    [self insertSubview:[self rangeDivider] aboveSubview:[self minPicker]];
    
    x = CGRectGetMaxX(dividerFrame);
    [self setMaxPicker:[self pickerWithXOrigin:x width:pickerWidth onSelection:^(NSNumber *value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([value integerValue] < [strongSelf selectedMinValue]) {
            NSInteger valueIndex = [strongSelf indexOfValue:[value integerValue]];
            NSInteger maxIndex = MAX(0, valueIndex - HEMAlarmValueRangeDefaultDiff);
            [[strongSelf minPicker] setIndex:maxIndex];
        }
        [strongSelf setSelectedMaxValue:[value integerValue]];
        [[strongSelf pickerDelegate] didUpdateSelectedValuesFrom:strongSelf];
    }]];
    
    NSInteger maxIndex = [[self values] count] - 1;
    valueIndex = MIN(maxIndex, [self indexOfValue:[self selectedMaxValue]]);
    if (valueIndex >= 0) {
        [[self maxPicker] setIndex:valueIndex];
    }
    
    [self insertSubview:[self maxPicker] aboveSubview:[self rangeDivider]];
}

- (NAPickerView*)pickerWithXOrigin:(CGFloat)xOrigin
                             width:(CGFloat)width
                       onSelection:(void(^)(NSNumber* value))selection {
    CGFloat maxHeight = CGRectGetHeight([self bounds]);
    
    CGRect pickerFrame = CGRectZero;
    pickerFrame.size.height = maxHeight;
    pickerFrame.size.width = width;
    pickerFrame.origin.y = 0.0f;
    pickerFrame.origin.x = xOrigin;

    UIColor* highlightedColor = [SenseStyle colorWithGroup:GroupExpansionRangePicker property:ThemePropertyTextHighlightedColor];
    UIFont* highlightedFont = [SenseStyle fontWithGroup:GroupExpansionRangePicker property:ThemePropertyTextFont];
    UIFont* normalFont = [SenseStyle fontWithGroup:GroupExpansionRangePicker property:ThemePropertyDetailFont];
    UIColor* normalColor = [SenseStyle colorWithGroup:GroupExpansionRangePicker property:ThemePropertyDetailColor];
    
    NAPickerView* pickerView = [[NAPickerView alloc] initWithFrame:pickerFrame
                                                          andItems:[self values]
                                                       andDelegate:nil];
    [pickerView setInfiniteScrolling:NO];
    [pickerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [pickerView setBackgroundColor:[UIColor clearColor]];
    [pickerView setOverlayColor:[UIColor clearColor]];
    [pickerView setConfigureBlock:^(NALabelCell *cell, NSString *item) {
        [[cell textView] setFont:normalFont];
        [[cell textView] setTextColor:normalColor];
        [[cell textView] setBackgroundColor:[UIColor clearColor]];
        [[cell textView] setTextAlignment:NSTextAlignmentCenter];
        [[cell textView] setText:item];
    }];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setHighlightBlock:^(NALabelCell *cell) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSString* text = [[cell textView] text];
        NSInteger value;
        
        if ([strongSelf unitSymbol]) {
            NSRange range = [text rangeOfString:[strongSelf unitSymbol]];
            value = [[text substringToIndex:range.location] integerValue];
        } else {
            value = [text integerValue];
        }
        
        if (selection) {
            selection (@(value));
        }
        
        [[cell textView] setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
        [[cell textView] setFont:highlightedFont];
        [UIView animateWithDuration:0.2f
                         animations:^{
                             [[cell textView] setTransform:CGAffineTransformIdentity];
                             [[cell textView] setTextColor:highlightedColor];
                         }];
    }];

    [pickerView setUnhighlightBlock:^(NALabelCell *cell) {
        if ([[[cell textView] font] pointSize] != [normalFont pointSize]) {
            [[cell textView] setFont:normalFont];
            [[cell textView] setTransform:CGAffineTransformMakeScale(2, 2)];
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 [[cell textView] setTransform:CGAffineTransformIdentity];
                                 [[cell textView] setTextColor:normalColor];
                             }];
        }
    }];
    
    return pickerView;
}


- (void)configureWithMin:(NSInteger)min max:(NSInteger)max {
    [self configureValuesArray:min max:max];

    CGFloat maxWidth = CGRectGetWidth([self bounds]);
    CGFloat pickerWidth = HEMAlarmValueRangePickerWidth * 2; // take space of 2
    CGFloat x = (maxWidth - pickerWidth) / 2.0f;
    
    __weak typeof(self) weakSelf = self;
    [self setMaxPicker:[self pickerWithXOrigin:x width:pickerWidth onSelection:^(NSNumber *value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setSelectedMaxValue:[value integerValue]];
        [strongSelf setSelectedMinValue:[value integerValue]];
        [[strongSelf pickerDelegate] didUpdateSelectedValuesFrom:strongSelf];
    }]];
    
    NSInteger maxIndex = [[self values] count] - 1;
    NSInteger valueIndex = MIN(maxIndex, [self indexOfValue:[self selectedMaxValue]]);
    if (valueIndex >= 0) {
        [[self maxPicker] setIndex:valueIndex];
    }
    
    [self insertSubview:[self maxPicker] atIndex:0];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat maxWidth = CGRectGetWidth([self bounds]);
    
    if (![self minPicker] && ![self rangeDivider]) {
        CGFloat pickerWidth = HEMAlarmValueRangePickerWidth * 2; // take space of 2
        CGFloat x = (maxWidth - pickerWidth) / 2.0f;
        CGRect pickerFrame = [[self maxPicker] frame];
        pickerFrame.origin.x = x;
        pickerFrame.size.width = pickerWidth;
        [[self maxPicker] setFrame:pickerFrame];
    } else {
        CGFloat pickerWidths = (2 *HEMAlarmValueRangePickerWidth);
        CGFloat x = (maxWidth - pickerWidths - HEMAlarmValueRangeDividerWidth) / 2.0f;
        
        CGRect pickerFrame = [[self minPicker] frame];
        pickerFrame.origin.x = x;
        pickerFrame.size.width = HEMAlarmValueRangePickerWidth;
        [[self minPicker] setFrame:pickerFrame];
        
        CGRect dividerFrame = [[self rangeDivider] frame];
        dividerFrame.origin.x = CGRectGetMaxX(pickerFrame);
        dividerFrame.size.width = HEMAlarmValueRangeDividerWidth;
        [[self rangeDivider] setFrame:dividerFrame];
        
        pickerFrame = [[self maxPicker] frame];
        pickerFrame.origin.x = CGRectGetMaxX(dividerFrame);
        pickerFrame.size.width = HEMAlarmValueRangePickerWidth;
        [[self maxPicker] setFrame:pickerFrame];
    }
    
    if (![self configuredGradients]) {
        [self configureGradientViews];
        [self setConfiguredGradients:YES];
    }
}

@end
