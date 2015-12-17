//
//  RoomInterfaceController.m
//  Sense
//
//  Created by Delisa Mason on 1/17/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSensor.h>
#import "RoomInterfaceController.h"
#import "ModelCache.h"
#import "UIColor+HEMStyle.h"

@interface SensorRowItem : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceImage *iconImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *valueLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *unitLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@end

@implementation SensorRowItem
@end

@interface RoomInterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@end

@implementation RoomInterfaceController

- (void)willActivate {
    [super willActivate];
    [self updateTable];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTable)
                                                 name:ModelCacheUpdatedNotification
                                               object:ModelCacheUpdatedObjectSensors];
}

- (void)didDeactivate {
    [super didDeactivate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTable {
    NSArray *sensors = [ModelCache sensors];
    [self.table setNumberOfRows:sensors.count withRowType:@"watchSensor"];
    [sensors enumerateObjectsUsingBlock:^(SENSensor *sensor, NSUInteger idx, BOOL *stop) {
      SensorRowItem *row = [self.table rowControllerAtIndex:idx];
      NSString *value = [NSString stringWithFormat:@"%.0f", [[sensor valueInPreferredUnit] floatValue]];
      NSString *imageName = [NSString stringWithFormat:@"%@.png", sensor.name];
      UIColor *textColor = [UIColor colorForCondition:sensor.condition];
      [row.valueLabel setText:value];
      [row.valueLabel setTextColor:textColor];
      [row.unitLabel setText:[self unitTextForSensor:sensor]];
      [row.unitLabel setTextColor:textColor];
      [row.titleLabel setText:sensor.localizedName];
      [row.iconImage setImageNamed:imageName];
    }];
}

- (NSString *)unitTextForSensor:(SENSensor *)sensor {
    switch (sensor.unit) {
        case SENSensorUnitAQI:
            return NSLocalizedString(@"measurement.particle.unit", nil);
        case SENSensorUnitDecibel:
            return NSLocalizedString(@"measurement.sound.unit", nil);
        case SENSensorUnitDegreeCentigrade:
            return NSLocalizedString(@"measurement.temperature.unit", nil);
        case SENSensorUnitLux:
            return NSLocalizedString(@"measurement.light.unit", nil);
        case SENSensorUnitPercent:
            return NSLocalizedString(@"measurement.percentage.unit", nil);
        case SENSensorUnitUnknown:
        default:
            return nil;
    }
}

@end
