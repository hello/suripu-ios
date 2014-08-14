
#import <SenseKit/SENSettings.h>

#import "HEMSleepHistoryView.h"
#import "HEMSensorValuesView.h"
#import "HelloStyleKit.h"

CGFloat const HEMSleepHistoryViewPadding = 20.f;
CGFloat const HEMSleepHistoryViewSensorsHeight = 45.f;

@interface HEMSleepHistoryView ()

@property (nonatomic) NSTimeInterval startInterval;
@property (nonatomic) NSTimeInterval endInterval;
@property (nonatomic) NSTimeInterval secondsPerPoint;
@property (nonatomic, strong) NSArray* dataSlices;
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

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [[touches allObjects] lastObject];
    NSTimeInterval timeAtTouch = [self timeIntervalAtYOffset:[touch locationInView:self].y];
    for (NSDictionary* dataSlice in self.dataSlices) {
        NSTimeInterval startTimeInterval = [dataSlice[@"timestamp"] doubleValue] / 1000;
        NSTimeInterval endTimeInterval = [dataSlice[@"duration"] doubleValue] / 1000 + startTimeInterval;
        if (timeAtTouch >= startTimeInterval && timeAtTouch <= endTimeInterval) {
            [self.sensorValuesView updateWithSensorData:dataSlice[@"sensors"]];
            return;
        }
    }
}

- (CGSize)intrinsicContentSize
{
    return [UIScreen mainScreen].bounds.size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.sensorValuesView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), HEMSleepHistoryViewSensorsHeight);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
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
        NSForegroundColorAttributeName : [UIColor grayColor]
    };
    CGFloat xOffset = CGRectGetWidth(self.bounds) * 0.75f;
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
    return (interval - self.startInterval) / self.secondsPerPoint + HEMSleepHistoryViewPadding + HEMSleepHistoryViewSensorsHeight;
}

- (NSTimeInterval)timeIntervalAtYOffset:(CGFloat)yOffset
{
    return (yOffset - HEMSleepHistoryViewPadding - HEMSleepHistoryViewSensorsHeight - (self.startInterval / self.secondsPerPoint)) * self.secondsPerPoint;
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
    self.secondsPerPoint = duration / (CGRectGetHeight(self.bounds) - (HEMSleepHistoryViewPadding * 2) - HEMSleepHistoryViewSensorsHeight);
    _dataSlices = sortedSlices;
    [self.sensorValuesView updateWithSensorData:[_dataSlices firstObject][@"sensors"]];
    [self setNeedsDisplay];
}

- (void)bootstrap
{
    NSMutableArray* slices = [[NSMutableArray alloc] initWithCapacity:80];
    CGFloat startTimeMillis = ([[NSDate date] timeIntervalSince1970] * 1000);
    CGFloat previousDuration = 0;
    for (int i = 0; i < 80; i++) {
        CGFloat timestamp = startTimeMillis + previousDuration;
        CGFloat duration = (arc4random() % 12) * 100000;
        [slices addObject:@{
            @"timestamp" : @(timestamp),
            @"duration" : @(duration),
            @"sleep_depth" : @(ceilf(arc4random() % 3)),
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
        previousDuration += duration;
    }
    [self setDataSlices:slices];
}

@end
