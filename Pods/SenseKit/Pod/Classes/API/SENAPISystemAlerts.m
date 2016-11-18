//
//  SENAPISystemAlerts.m
//  Pods
//
//  Created by Jimmy Lu on 11/8/16.
//
//

#import "SENAPISystemAlerts.h"
#import "SENSystemAlert.h"

static NSString* const kSENAPISystemAlertsResource = @"v2/alerts";

@implementation SENAPISystemAlerts

+ (void)getSystemAlerts:(SENAPIDataBlock)completion {
    NSString* path = kSENAPISystemAlertsResource;
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        NSMutableArray<SENSystemAlert*>* alerts = nil;
        if (!error && [data isKindOfClass:[NSArray class]]) {
            alerts = [NSMutableArray arrayWithCapacity:[data count]];
            for (id obj in data) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    [alerts addObject:[[SENSystemAlert alloc] initWithDictionary:obj]];
                }
            }
        }
        completion (alerts, error);
    }];
}

@end
