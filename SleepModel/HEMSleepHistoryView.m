
#import <SenseKit/SENSettings.h>

#import "HEMSleepHistoryView.h"
#import "HEMSensorValuesView.h"
#import "HelloStyleKit.h"

CGFloat const HEMSleepHistoryViewPadding = 20.f;
CGFloat const HEMSleepHistoryViewSensorsHeight = 70.f;
CGFloat const HEMSleepHistoryViewEventStripWidth = 22.f;

@interface HEMSleepHistoryView ()

@property (nonatomic) NSTimeInterval startInterval;
@property (nonatomic) NSTimeInterval endInterval;
@property (nonatomic) NSTimeInterval secondsPerPoint;
@property (nonatomic, strong) NSArray* dataSlices;
@property (nonatomic, strong) NSArray* sleepEvents;
@property (nonatomic, strong) NSArray* maskLayers;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) HEMSensorValuesView* sensorValuesView;
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
        [self addSubview:_sensorValuesView];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)awakeFromNib
{
    [self bootstrap];
}

- (void)dealloc
{
    _maskLayers = nil;
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
    NSTimeInterval timeAtTouch = ABS([self timeIntervalAtYOffset:[touch locationInView:self].y]);
    for (NSDictionary* dataSlice in self.dataSlices) {
        NSTimeInterval startTimeInterval = [dataSlice[@"timestamp"] doubleValue] / 1000;
        NSTimeInterval endTimeInterval = [dataSlice[@"duration"] doubleValue] / 1000 + startTimeInterval;
        if (timeAtTouch >= startTimeInterval && timeAtTouch <= endTimeInterval) {
            [self.sensorValuesView updateWithSensorData:dataSlice[@"sensors"]];
            return;
        }
    }
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize
{
    return [UIScreen mainScreen].bounds.size;
}

- (CGFloat)contentHeight
{
    return (CGRectGetHeight(self.bounds) - (HEMSleepHistoryViewPadding * 2) - HEMSleepHistoryViewSensorsHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.sensorValuesView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), HEMSleepHistoryViewSensorsHeight);

    [self layoutAlphaMask];
    [self layoutSleepEvents];
}

- (void)layoutAlphaMask
{
    if (!self.maskLayers) {
        CALayer* topLayer = [[CALayer alloc] init];
        CALayer* leadingLayer = [[CALayer alloc] init];
        CALayer* trailingLayer = [[CALayer alloc] init];
        CALayer* bottomLayer = [[CALayer alloc] init];
        CGColorRef backgroundColor = [UIColor colorWithWhite:1.f alpha:0.7f].CGColor;
        topLayer.frame = CGRectMake(0, HEMSleepHistoryViewSensorsHeight, CGRectGetWidth(self.bounds), HEMSleepHistoryViewPadding);
        leadingLayer.frame = CGRectMake(0, HEMSleepHistoryViewSensorsHeight + HEMSleepHistoryViewPadding, HEMSleepHistoryViewPadding, self.contentHeight);
        trailingLayer.frame = CGRectMake(HEMSleepHistoryViewPadding + HEMSleepHistoryViewEventStripWidth, HEMSleepHistoryViewPadding + HEMSleepHistoryViewSensorsHeight, CGRectGetWidth(self.bounds) - HEMSleepHistoryViewPadding - HEMSleepHistoryViewEventStripWidth, self.contentHeight);
        bottomLayer.frame = CGRectMake(0, self.contentHeight + HEMSleepHistoryViewPadding + HEMSleepHistoryViewSensorsHeight, CGRectGetWidth(self.bounds), HEMSleepHistoryViewPadding);
        topLayer.backgroundColor = backgroundColor;
        trailingLayer.backgroundColor = backgroundColor;
        leadingLayer.backgroundColor = backgroundColor;
        bottomLayer.backgroundColor = backgroundColor;
        [self.layer insertSublayer:topLayer atIndex:0];
        [self.layer insertSublayer:bottomLayer atIndex:0];
        [self.layer insertSublayer:trailingLayer atIndex:0];
        [self.layer insertSublayer:leadingLayer atIndex:0];
        self.maskLayers = @[ topLayer, bottomLayer, trailingLayer, leadingLayer ];
    }
}

- (void)layoutSleepEvents
{
    for (UIView* subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
    for (NSDictionary* event in self.sleepEvents) {
        UIImage* image = nil;
        if ([event[@"type"] isEqualToString:@"AWAKE"]) {
            image = [HelloStyleKit wakeupEventIcon];
        } else if ([event[@"type"] isEqualToString:@"SLEEP"]) {
            image = [HelloStyleKit sleepEventIcon];
        } else if ([event[@"type"] isEqualToString:@"LIGHT"]) {
            image = [HelloStyleKit lightEventIcon];
        } else if ([event[@"type"] isEqualToString:@"NOISE"]) {
            image = [HelloStyleKit noiseEventIcon];
        } else {
            continue;
        }
        CGFloat yOffset = [self yOffsetForTimeInterval:[event[@"timestamp"] doubleValue] / 1000];
        CGRect buttonFrame = CGRectMake(HEMSleepHistoryViewPadding,
                                        yOffset - (HEMSleepHistoryViewEventStripWidth / 2),
                                        HEMSleepHistoryViewEventStripWidth,
                                        HEMSleepHistoryViewEventStripWidth);
        UIButton* button = [[UIButton alloc] initWithFrame:buttonFrame];
        [button setImage:image forState:UIControlStateNormal];
        button.contentMode = UIViewContentModeCenter;
        button.backgroundColor = [UIColor whiteColor];
        button.layer.borderColor = [HelloStyleKit intermediateSleepColor].CGColor;
        button.layer.borderWidth = 2.f;
        button.layer.cornerRadius = HEMSleepHistoryViewEventStripWidth / 2;
        button.layer.shadowOpacity = 0;

        [self addSubview:button];
    }
}

#pragma mark - Custom Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit currentConditionsBackgroundColor].CGColor);
    CGContextFillRect(ctx, rect);
    for (NSDictionary* dataSlice in self.dataSlices) {
        NSTimeInterval sliceStartInterval = [dataSlice[@"timestamp"] doubleValue] / 1000;
        NSTimeInterval sliceEndInterval = sliceStartInterval + ([dataSlice[@"duration"] doubleValue] / 1000);
        CGFloat startYOffset = [self yOffsetForTimeInterval:sliceStartInterval];
        CGFloat endYOffset = [self yOffsetForTimeInterval:sliceEndInterval];
        NSInteger sleepDepth = [dataSlice[@"sleep_depth"] integerValue];
        CGFloat endXOffset = [self xOffsetForSleepDepth:sleepDepth];
        UIColor* color = [self colorForSleepDepth:sleepDepth];
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, CGRectMake(HEMSleepHistoryViewPadding, startYOffset, endXOffset, endYOffset - startYOffset));
    }

    NSCalendar* gregorian = [[NSCalendar alloc]
        initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate* dateForCurrentHour = [NSDate dateWithTimeIntervalSince1970:self.startInterval];
    NSDateComponents* dateComponents = [gregorian components:(NSHourCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit)
                                                    fromDate:dateForCurrentHour];
    dateComponents.hour += 1;
    dateForCurrentHour = [gregorian dateFromComponents:dateComponents];
    NSDictionary* textAttributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:8],
        NSForegroundColorAttributeName : [UIColor colorWithWhite:0.f alpha:0.8]
    };
    CGFloat xOffset = CGRectGetWidth(self.bounds) * 0.85f;
    while ([dateForCurrentHour timeIntervalSince1970] < self.endInterval) {
        CGFloat yOffset = [self yOffsetForTimeInterval:[dateForCurrentHour timeIntervalSince1970]];
        CGContextMoveToPoint(ctx, HEMSleepHistoryViewPadding, yOffset);
        CGContextAddLineToPoint(ctx, xOffset - 5.f, yOffset);
        NSString* text = [self.dateFormatter stringFromDate:dateForCurrentHour];
        CGSize textSize = [text sizeWithAttributes:textAttributes];
        CGPoint textLocation = CGPointMake(xOffset, yOffset - (textSize.height / 2));
        [text drawAtPoint:textLocation withAttributes:textAttributes];
        dateComponents.hour++;
        dateForCurrentHour = [gregorian dateFromComponents:dateComponents];
    }
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.1f].CGColor);
    CGContextStrokePath(ctx);
}

- (CGFloat)yOffsetForTimeInterval:(NSTimeInterval)interval
{
    return floorf((interval - self.startInterval) / self.secondsPerPoint + HEMSleepHistoryViewPadding + HEMSleepHistoryViewSensorsHeight);
}

- (NSTimeInterval)timeIntervalAtYOffset:(CGFloat)yOffset
{
    return (yOffset - HEMSleepHistoryViewPadding - HEMSleepHistoryViewSensorsHeight + (self.startInterval / self.secondsPerPoint)) * self.secondsPerPoint;
}

- (CGFloat)xOffsetForSleepDepth:(NSInteger)sleepDepth
{
    switch (sleepDepth) {
    case 0:
        return HEMSleepHistoryViewPadding;
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

- (void)setDataSlices:(NSArray*)dataSlices
{
    NSArray* sortedSlices = [dataSlices sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        return [obj1[@"timestamp"] compare:obj2[@"timestamp"]];
    }];
    self.startInterval = [[sortedSlices firstObject][@"timestamp"] doubleValue] / 1000;
    self.endInterval = ([[sortedSlices lastObject][@"timestamp"] doubleValue] + [[sortedSlices lastObject][@"duration"] doubleValue]) / 1000;
    CGFloat duration = (self.endInterval - self.startInterval);
    self.secondsPerPoint = duration / self.contentHeight;
    _dataSlices = sortedSlices;
    [self.sensorValuesView updateWithSensorData:[_dataSlices firstObject][@"sensors"]];
    [self setNeedsDisplay];
}

#pragma mark - Fake Data Generation

- (void)bootstrap
{
    NSMutableArray* slices = [[NSMutableArray alloc] initWithCapacity:40];
    CGFloat startTimeMillis = ([[NSDate date] timeIntervalSince1970] * 1000);
    CGFloat totalDuration = 0;
    for (int i = 0; i < 40; i++) {
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
                         @"type" : @"AWAKE",
                         @"message" : @"You woke up!",
                         @"duration" : @0 }];
    for (int i = 0; i < eventCount; i++) {
        CGFloat duration = (arc4random() % 10) * 10000;
        NSString* message = [NSString stringWithFormat:@"Something unexplainable occurred for %.f seconds.", duration / 1000];
        [events addObject:@{ @"timestamp" : @(startTimeMillis + ((arc4random() % 280) * 125000 + 360000)),
                             @"type" : @[ @"LIGHT", @"NOISE" ][arc4random() % 2],
                             @"message" : message,
                             @"duration" : @(duration) }];
    }
    [events addObject:@{ @"timestamp" : @(startTimeMillis + totalDuration),
                         @"type" : @"SLEEP",
                         @"message" : @"You fell asleep a little late today",
                         @"duration" : @0 }];
    self.sleepEvents = events;
    self.dataSlices = slices;
}

@end
