#import <SenseKit/SENSensor.h>

#import "HEMSensorValuesView.h"
#import "HelloStyleKit.h"

@interface HEMSensorValuesView ()

@property (nonatomic, strong) NSDictionary* sensorData;
@end

@implementation HEMSensorValuesView

- (id)init
{
    if (self = [super init]) {
        [self _configureLayout];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _configureLayout];
    }
    return self;
}

- (void)_configureLayout
{
    self.clearsContextBeforeDrawing = YES;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)updateWithSensorData:(NSDictionary*)sensorData
{
    self.sensorData = sensorData;
    [self setNeedsDisplay];
}

- (UIImage*)imageForSensorWithName:(NSString*)sensorName
{
    if ([sensorName isEqualToString:@"temperature"]) {
        return [HelloStyleKit temperatureIcon];
    } else if ([sensorName isEqualToString:@"humidity"]) {
        return [HelloStyleKit humidityIcon];
    } else if ([sensorName isEqualToString:@"particulates"]) {
        return [HelloStyleKit particleIcon];
    }
    return nil;
}

- (void)drawRect:(CGRect)rect
{
    if (self.sensorData.count == 0) {
        return;
    }

    CGFloat segmentWidth = CGRectGetWidth(self.bounds) / self.sensorData.count;
    __block int index = 0;
    NSDictionary* textAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:25] };
    __block CGFloat previousXOffset = 0;
    [self.sensorData enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        UIImage* sensorImage = [self imageForSensorWithName:key];
        NSString* formattedValue = [SENSensor formatValue:obj[@"value"] withUnit:[SENSensor unitFromValue:obj[@"unit"]]];
        CGSize textSize = [formattedValue sizeWithAttributes:textAttributes];
        CGFloat contentHeight =  MAX(sensorImage.size.height, textSize.height);
        CGRect sensorRect = CGRectMake(previousXOffset + 10.f, CGRectGetHeight(rect) - contentHeight - 10.f, segmentWidth, contentHeight);
        
        CGFloat offset = index == 0 ? 10 : 0;
        CGPoint imagePoint = CGPointMake(CGRectGetMinX(sensorRect) + offset, CGRectGetMidY(sensorRect) - (sensorImage.size.height / 2));
        [sensorImage drawAtPoint:imagePoint];
        
        CGPoint textPoint = CGPointMake(sensorImage.size.width + 10 + imagePoint.x, CGRectGetMidY(sensorRect) - (textSize.height / 2));
        [formattedValue drawAtPoint:textPoint withAttributes:textAttributes];
        previousXOffset = textPoint.x + textSize.width;
        index++;
    }];
}

@end
