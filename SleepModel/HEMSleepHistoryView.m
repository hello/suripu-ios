
#import <SenseKit/SENSettings.h>

#import "HEMSleepHistoryView.h"
#import "HEMSensorValuesView.h"
#import "HEMSleepDataDetailView.h"
#import "HEMSleepEventButton.h"
#import "HelloStyleKit.h"

CGFloat const HEMSleepHistoryViewHorizontalPadding = 20.f;
CGFloat const HEMSleepHistoryViewVerticalPadding = 30.f;
CGFloat const HEMSleepHistoryViewSensorsHeight = 70.f;
CGFloat const HEMSleepHistoryViewEventStripWidth = 28.f;

NSString* const HEMSleepHistoryViewEventStorageKey = @"HEMSleepHistoryViewEventStorage";

@interface HEMSleepHistoryView ()

@property (nonatomic) NSTimeInterval startInterval;
@property (nonatomic) NSTimeInterval endInterval;
@property (nonatomic) NSTimeInterval secondsPerPoint;
@property (nonatomic, strong) NSArray* dataSlices;
@property (nonatomic, strong) NSArray* sleepEvents;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) HEMSensorValuesView* sensorValuesView;
@property (nonatomic, strong) HEMSleepDataDetailView* sleepDataDetailView;
@end

@implementation HEMSleepHistoryView

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _endInterval = [[NSDate date] timeIntervalSince1970];
        _startInterval = _endInterval - (60 * 60 * 8);
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = [SENSettings timeFormat] == SENTimeFormat12Hour ? @"h:mm a" : @"H:mm";
        _sensorValuesView = [[HEMSensorValuesView alloc] init];
        _sleepDataDetailView = [[HEMSleepDataDetailView alloc] init];
        [self addSubview:_sensorValuesView];
        [self addSubview:_sleepDataDetailView];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)awakeFromNib
{
    [self bootstrap];
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [[touches allObjects] lastObject];
    [self updateSensorsForTouch:touch];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [[touches allObjects] lastObject];
    [self updateSensorsForTouch:touch];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [[touches allObjects] lastObject];
    [self updateSensorsForTouch:touch];
}

- (void)updateSensorsForTouch:(UITouch*)touch
{
    CGPoint touchPoint = [touch locationInView:self];
    NSTimeInterval timeAtTouch = ABS([self timeIntervalAtYOffset:touchPoint.y]);
    NSDictionary* dataSlice = [self dataSliceForTimeInterval:timeAtTouch];
    if (dataSlice) {
        [self showDetailsForDataSlice:dataSlice atYOffset:touchPoint.y animated:YES];
    }
}

- (void)handleSleepEvent:(UIButton*)button
{
    CGFloat yOffset = floorf(CGRectGetMidY(button.frame));
    NSTimeInterval interval = [self timeIntervalAtYOffset:yOffset];
    NSDictionary* dataSlice = [self dataSliceForTimeInterval:interval];
    if (dataSlice) {
        [self highlightButtonWithTag:button.tag];
        [self showDetailsForDataSlice:dataSlice atYOffset:yOffset animated:YES];
    }
}

- (void)showDetailsForDataSlice:(NSDictionary*)dataSlice atYOffset:(CGFloat)yOffset animated:(BOOL)animated
{
    [self.sensorValuesView updateWithSensorData:dataSlice[@"sensors"]];
    NSTimeInterval interval = [self timeIntervalAtYOffset:yOffset];
    NSString* timeText = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    NSDictionary* event = [self eventForTimeInterval:interval fuzzyRange:600];
    void (^changesBlock)() = ^{
        [self.sleepDataDetailView setTimeLabelText:timeText];
        [self.sleepDataDetailView setSleepDepthLabelText:[self localizedSleepDepthTextForDataSlice:dataSlice]];
        if (event) {
            [self.sleepDataDetailView setEventWithTitle:[self localizedNameForSleepEvent:event] message:[self messageForEvent:event]];
        } else {
            [self.sleepDataDetailView setEventWithTitle:nil message:nil];
        }
        CGFloat detailViewHeight = [self.sleepDataDetailView intrinsicContentSize].height;
        CGFloat minimumFrameYOffset = HEMSleepHistoryViewSensorsHeight + 4.f;
        CGFloat maximumFrameYOffset = CGRectGetHeight(self.bounds) - detailViewHeight - 4.f;
        CGRect frame = CGRectMake(HEMSleepHistoryViewHorizontalPadding + HEMSleepHistoryViewEventStripWidth,
                                  MIN(MAX(yOffset - detailViewHeight/2, minimumFrameYOffset), maximumFrameYOffset),
                                  CGRectGetWidth(self.bounds) - (HEMSleepHistoryViewHorizontalPadding * 2) - HEMSleepHistoryViewEventStripWidth,
                                  detailViewHeight);
        [self.sleepDataDetailView setOffsetForArrow:yOffset - CGRectGetMinY(frame)];
        self.sleepDataDetailView.frame = frame;
    };

    if (animated) {
        NSInteger identifier = event ? [self identifierForEvent:event] : -1;
        [self highlightButtonWithTag:identifier];
        [UIView animateWithDuration:0.35f
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:changesBlock
                         completion:NULL];
    } else {
        changesBlock();
    }
}

- (void)highlightButtonWithTag:(NSInteger)tag
{
    //    NSPredicate* buttonMatcher = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
    //        return [evaluatedObject isKindOfClass:[UIButton class]];
    //    }];
    //    NSArray* buttons = [self.subviews filteredArrayUsingPredicate:buttonMatcher];
    //    [CATransaction begin];
    //    for (int i = 1; i < buttons.count - 1; i++) {
    //        UIButton* button = buttons[i];
    //        CGFloat tranformScale = button.tag == tag ? 1.f : 0.8f;
    //        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //        animation.duration = 0.25f;
    //        animation.repeatCount = 1;
    //        animation.autoreverses = NO;
    //        animation.toValue = @(tranformScale);
    //        animation.removedOnCompletion = NO;
    //        [button.layer removeAnimationForKey:@"scaleAnimation"];
    //        [button.layer addAnimation:animation forKey:@"scaleAnimation"];
    //    }
    //    [CATransaction setCompletionBlock:^{
    //        for (int i = 1; i < buttons.count - 1; i++) {
    //            UIButton* button = buttons[i];
    //            if (button.tag == tag) {
    //                button.layer.transform = CATransform3DIdentity;
    //            } else {
    //                button.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 1.f);
    //            }
    //        }
    //    }];
    //    [CATransaction commit];
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize
{
    return [UIScreen mainScreen].bounds.size;
}

- (CGFloat)contentHeight
{
    return (CGRectGetHeight(self.bounds) - (HEMSleepHistoryViewVerticalPadding * 2) - HEMSleepHistoryViewSensorsHeight);
}

- (void)updateConstraints
{
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.sensorValuesView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), HEMSleepHistoryViewSensorsHeight);
    [self layoutSleepEvents];
}

- (void)layoutSleepEvents
{
    for (UIView* subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
    for (int i = 0; i < self.sleepEvents.count; i++) {
        NSDictionary* event = self.sleepEvents[i];
        NSTimeInterval eventInterval = [self timeIntervalForEvent:event];
        NSDictionary* dataSlice = [self dataSliceForTimeInterval:eventInterval];
        UIImage* image = [self imageForEvent:event];
        CGFloat yOffset = [self yOffsetForTimeInterval:eventInterval];
        CGRect buttonFrame = CGRectMake(HEMSleepHistoryViewHorizontalPadding,
                                        yOffset - (HEMSleepHistoryViewEventStripWidth / 2),
                                        HEMSleepHistoryViewEventStripWidth,
                                        HEMSleepHistoryViewEventStripWidth);
        HEMSleepEventButton* button = [[HEMSleepEventButton alloc] initWithFrame:buttonFrame];
        [button setImage:image forState:UIControlStateNormal];
        button.contentMode = UIViewContentModeCenter;
        button.tag = [self identifierForEvent:event];
        if (dataSlice) {
            button.layer.borderColor = [self colorForSleepDepth:[dataSlice[@"sleep_depth"] integerValue]].CGColor;
        } else {
            button.layer.borderColor = [HelloStyleKit intermediateSleepColor].CGColor;
        }
        button.layer.shadowOpacity = 0;
        if (i > 0 && i < self.sleepEvents.count - 1) {
            button.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.f);
        }
        [button addTarget:self action:@selector(handleSleepEvent:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:button];
    }
}

- (NSDictionary*)dataSliceForTimeInterval:(NSTimeInterval)timeInterval
{
    for (NSDictionary* dataSlice in self.dataSlices) {
        NSTimeInterval startTimeInterval = [self timeIntervalForDataSlice:dataSlice];
        NSTimeInterval endTimeInterval = [self durationForDataSlice:dataSlice] + startTimeInterval;
        if (timeInterval >= startTimeInterval && timeInterval <= endTimeInterval) {
            return dataSlice;
        }
    }
    if (timeInterval > [self timeIntervalForDataSlice:[self.dataSlices lastObject]]) {
        return [self.dataSlices lastObject];
    }
    return nil;
}

- (NSDictionary*)eventForTimeInterval:(NSTimeInterval)timeInterval fuzzyRange:(NSTimeInterval)searchRange
{
    for (NSDictionary* event in self.sleepEvents) {
        NSTimeInterval startTimeInterval = [self timeIntervalForEvent:event];
        NSTimeInterval endTimeInterval = [self durationForEvent:event] + startTimeInterval;
        if (timeInterval >= (startTimeInterval - searchRange) && timeInterval <= (endTimeInterval + searchRange)) {
            return event;
        }
    }
    return nil;
}

#pragma mark - Custom Drawing

- (void)drawRect:(CGRect)rect
{
    [self drawSleepDepthInRect:rect];
    [self drawSaturationOverlayInRect:rect];
    [self drawShadowGradientInRect:rect];
    [self drawHourMarkersInRect:rect];
    [self drawSleepEventTimeMarkersInRect:rect];
}

- (void)drawSleepDepthInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit currentConditionsBackgroundColor].CGColor);
    CGContextFillRect(ctx, rect);
    for (NSDictionary* dataSlice in self.dataSlices) {
        NSTimeInterval sliceStartInterval = [self timeIntervalForDataSlice:dataSlice];
        NSTimeInterval sliceEndInterval = sliceStartInterval + [self durationForDataSlice:dataSlice];
        CGFloat startYOffset = [self yOffsetForTimeInterval:sliceStartInterval];
        CGFloat endYOffset = [self yOffsetForTimeInterval:sliceEndInterval];
        NSInteger sleepDepth = [dataSlice[@"sleep_depth"] integerValue];
        CGFloat endXOffset = [self xOffsetForSleepDepth:sleepDepth];
        UIColor* color = [self colorForSleepDepth:sleepDepth];
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, CGRectMake(HEMSleepHistoryViewHorizontalPadding, startYOffset, endXOffset, endYOffset - startYOffset));
    }
}

- (void)drawSaturationOverlayInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.95f green:0.95f blue:1.f alpha:0.9f].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, HEMSleepHistoryViewSensorsHeight, CGRectGetWidth(self.bounds), HEMSleepHistoryViewVerticalPadding));
    CGContextFillRect(ctx, CGRectMake(0, HEMSleepHistoryViewSensorsHeight + HEMSleepHistoryViewVerticalPadding, HEMSleepHistoryViewHorizontalPadding, self.contentHeight));
    CGContextFillRect(ctx, CGRectMake(HEMSleepHistoryViewHorizontalPadding + HEMSleepHistoryViewEventStripWidth, HEMSleepHistoryViewVerticalPadding + HEMSleepHistoryViewSensorsHeight, CGRectGetWidth(self.bounds) - HEMSleepHistoryViewHorizontalPadding - HEMSleepHistoryViewEventStripWidth, self.contentHeight));
    CGContextFillRect(ctx, CGRectMake(0, self.contentHeight + HEMSleepHistoryViewVerticalPadding + HEMSleepHistoryViewSensorsHeight, CGRectGetWidth(self.bounds), HEMSleepHistoryViewVerticalPadding));
}

- (void)drawHourMarkersInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NSCalendar* gregorian = [[NSCalendar alloc]
        initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate* dateForCurrentHour = [NSDate dateWithTimeIntervalSince1970:self.startInterval];
    NSDateComponents* dateComponents = [gregorian components:(NSHourCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit)
                                                    fromDate:dateForCurrentHour];
    dateComponents.hour += 1;
    dateForCurrentHour = [gregorian dateFromComponents:dateComponents];
    NSDictionary* textAttributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:6],
        NSForegroundColorAttributeName : [UIColor colorWithWhite:0.f alpha:0.3]
    };
    CGFloat xOffset = CGRectGetWidth(self.bounds) * 0.85f;
    while ([dateForCurrentHour timeIntervalSince1970] < self.endInterval) {
        CGFloat yOffset = [self yOffsetForTimeInterval:[dateForCurrentHour timeIntervalSince1970]];
        CGContextMoveToPoint(ctx, HEMSleepHistoryViewHorizontalPadding + HEMSleepHistoryViewEventStripWidth, yOffset);
        CGContextAddLineToPoint(ctx, xOffset - 5.f, yOffset);
        NSString* text = [self.dateFormatter stringFromDate:dateForCurrentHour];
        CGSize textSize = [text sizeWithAttributes:textAttributes];
        CGPoint textLocation = CGPointMake(xOffset, yOffset - (textSize.height / 2));
        [text drawAtPoint:textLocation withAttributes:textAttributes];
        dateComponents.hour++;
        dateForCurrentHour = [gregorian dateFromComponents:dateComponents];
    }
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.025f].CGColor);
    CGContextStrokePath(ctx);
}

- (void)drawSleepEventTimeMarkersInRect:(CGRect)rect
{
    CGFloat xOffset = CGRectGetWidth(self.bounds) * 0.8f;
    NSDictionary* textAttributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:11.f],
        NSForegroundColorAttributeName : [UIColor colorWithWhite:0.4f alpha:1.f]
    };
    for (NSDictionary* event in self.sleepEvents) {
        NSString* eventName = [self localizedNameForSleepEvent:event];
        if (!eventName) {
            continue;
        }
        NSTimeInterval timestamp = [self timeIntervalForEvent:event];
        CGFloat yOffset = [self yOffsetForTimeInterval:timestamp];
        CGSize textSize = [eventName sizeWithAttributes:textAttributes];
        [eventName drawAtPoint:CGPointMake(HEMSleepHistoryViewHorizontalPadding + HEMSleepHistoryViewEventStripWidth + 10.f, yOffset - textSize.height / 2) withAttributes:textAttributes];

        NSString* dateText = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
        textSize = [dateText sizeWithAttributes:textAttributes];
        [dateText drawAtPoint:CGPointMake(xOffset, yOffset - textSize.height / 2) withAttributes:textAttributes];
    }
}

- (void)drawShadowGradientInRect:(CGRect)rect
{
    CGFloat colors[] = {
        0.91, 0.92, 0.92, 1.0,
        0.902, 0.91, 0.906, 0.0,
    };
    CGRect shadowRect = CGRectMake(0, HEMSleepHistoryViewSensorsHeight, CGRectGetWidth(rect), 10.f);
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGContextAddRect(context, shadowRect);
    CGContextClip(context);

    CGPoint startPoint = CGPointMake(CGRectGetMinX(shadowRect), CGRectGetMinY(shadowRect));
    CGPoint endPoint = CGPointMake(CGRectGetMinX(shadowRect), CGRectGetMaxY(shadowRect));

    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;

    CGContextRestoreGState(context);
}

- (CGFloat)yOffsetForTimeInterval:(NSTimeInterval)interval
{
    return (self.endInterval - interval) / self.secondsPerPoint + HEMSleepHistoryViewVerticalPadding + HEMSleepHistoryViewSensorsHeight;
}

- (NSTimeInterval)timeIntervalAtYOffset:(CGFloat)yOffset
{
    return (yOffset - HEMSleepHistoryViewVerticalPadding - HEMSleepHistoryViewSensorsHeight - (self.endInterval / self.secondsPerPoint)) * -self.secondsPerPoint;
}

- (CGFloat)xOffsetForSleepDepth:(NSInteger)sleepDepth
{
    switch (sleepDepth) {
    case 0:
        return HEMSleepHistoryViewHorizontalPadding;
    default:
        return (CGRectGetWidth(self.bounds) / 4) * sleepDepth;
    }
}

- (UIColor*)colorForSleepDepth:(NSInteger)sleepDepth
{
    switch (sleepDepth) {
    case 0:
        return [HelloStyleKit awakeSleepColor];
    case 1:
        return [HelloStyleKit lightSleepColor];
    case 2:
        return [HelloStyleKit intermediateSleepColor];
    default:
        return [HelloStyleKit deepSleepColor];
    }
}

#pragma mark - Data Parsing

- (void)setDataSlices:(NSArray*)dataSlices
{
    NSArray* sortedSlices = [dataSlices sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        return [obj1[@"timestamp"] compare:obj2[@"timestamp"]];
    }];
    self.startInterval = [self timeIntervalForDataSlice:[sortedSlices firstObject]];
    self.endInterval = [self timeIntervalForDataSlice:[sortedSlices lastObject]] + [self durationForDataSlice:[sortedSlices lastObject]];
    CGFloat duration = (self.endInterval - self.startInterval);
    self.secondsPerPoint = duration / self.contentHeight;
    _dataSlices = sortedSlices;
    [self resetDetailViewLocation];
    [self setNeedsDisplay];
}

- (void)setSleepEvents:(NSArray*)sleepEvents
{
    _sleepEvents = sleepEvents;
    [self resetDetailViewLocation];
}

- (void)resetDetailViewLocation
{
    if (self.sleepEvents.count > 0 && self.dataSlices.count > 0) {
        [self showDetailsForDataSlice:[self.dataSlices lastObject]
                            atYOffset:[self yOffsetForTimeInterval:[self timeIntervalForEvent:[self.sleepEvents lastObject]]]
                             animated:NO];
    }
}

- (NSTimeInterval)timeIntervalForDataSlice:(NSDictionary*)dataSlice
{
    return [dataSlice[@"timestamp"] doubleValue] / 1000;
}

- (NSTimeInterval)durationForDataSlice:(NSDictionary*)dataSlice
{
    return [dataSlice[@"duration"] doubleValue] / 1000;
}

- (NSTimeInterval)timeIntervalForEvent:(NSDictionary*)event
{
    return [event[@"timestamp"] doubleValue] / 1000;
}

- (NSTimeInterval)durationForEvent:(NSDictionary*)event
{
    return [event[@"duration"] doubleValue] / 1000;
}

- (NSString*)messageForEvent:(NSDictionary*)event
{
    return event[@"message"];
}

- (NSInteger)identifierForEvent:(NSDictionary*)event
{
    return [event[@"id"] integerValue];
}

- (NSString*)localizedSleepDepthTextForDataSlice:(NSDictionary*)dataSlice
{
    switch ([dataSlice[@"sleep_depth"] integerValue]) {
    case 0:
        return NSLocalizedString(@"sleep-history.depth.awake", nil);
    case 1:
        return NSLocalizedString(@"sleep-history.depth.light", nil);
    case 2:
        return NSLocalizedString(@"sleep-history.depth.medium", nil);
    default:
        return NSLocalizedString(@"sleep-history.depth.deep", nil);
    }
}

- (NSString*)localizedNameForSleepEvent:(NSDictionary*)event
{
    NSString* localizedFormat = [NSString stringWithFormat:@"sleep-event.type.%@.name", event[@"type"]];
    NSString* eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return nil;
    }
    return eventName;
}

- (UIImage*)imageForEvent:(NSDictionary*)event
{
    if ([event[@"type"] isEqualToString:@"awake"]) {
        return [HelloStyleKit wakeupEventIcon];
    } else if ([event[@"type"] isEqualToString:@"sleep"]) {
        return [HelloStyleKit sleepEventIcon];
    } else if ([event[@"type"] isEqualToString:@"light"]) {
        return [HelloStyleKit lightEventIcon];
    } else if ([event[@"type"] isEqualToString:@"noise"]) {
        return [HelloStyleKit noiseEventIcon];
    }
    return nil;
}

#pragma mark - Fake Data Generation

- (void)bootstrap
{
    NSMutableArray* slices = [[NSMutableArray alloc] initWithCapacity:30];
    CGFloat startTimeMillis = (([[NSDate date] timeIntervalSince1970] - 10 * 60 * 60) * 1000);
    CGFloat totalDuration = 0;
    for (int i = 0; i < 30; i++) {
        CGFloat timestamp = startTimeMillis + totalDuration;
        CGFloat duration = (arc4random() % 20) * 100000;
        [slices addObject:@{
            @"timestamp" : @(timestamp),
            @"duration" : @(duration),
            @"sleep_depth" : @(floorf(arc4random() % 3) + 1),
            @"sensors" : @{
                @"temperature" : @{
                    @"value" : @(arc4random() % 33),
                    @"unit" : @"c"
                },
                @"humidity" : @{
                    @"value" : @(arc4random() % 100),
                    @"unit" : @"%"
                },
                @"particulates" : @{
                    @"value" : @(arc4random() % 700),
                    @"unit" : @"ppm"
                },
            }
        }];
        totalDuration += duration;
    }
    NSInteger eventCount = arc4random() % 6;
    NSMutableArray* events = [[NSMutableArray alloc] initWithCapacity:eventCount];
    [events addObject:@{ @"timestamp" : @(startTimeMillis),
                         @"type" : @"sleep",
                         @"message" : @"You fell asleep a little late today",
                         @"duration" : @0,
                         @"id" : @0 }];
    for (int i = 0; i < eventCount; i++) {
        CGFloat duration = (arc4random() % 10) * 10000;
        NSString* message = [NSString stringWithFormat:@"Something unexplainable occurred for %.f seconds.", duration / 1000];
        NSTimeInterval startTime = startTimeMillis + ((arc4random() % 280) * 125000 + 360000);
        if (startTime > startTimeMillis + totalDuration) {
            continue;
        }
        [events addObject:@{ @"timestamp" : @(startTime),
                             @"type" : @[ @"light", @"noise" ][arc4random() % 2],
                             @"message" : message,
                             @"duration" : @(duration),
                             @"id" : @(i + 1) }];
    }
    [events addObject:@{ @"timestamp" : @(startTimeMillis + totalDuration),
                         @"type" : @"awake",
                         @"message" : @"You woke up!",
                         @"duration" : @0,
                         @"id" : @(eventCount + 1) }];
    self.sleepEvents = events;
    self.dataSlices = slices;
}

@end
