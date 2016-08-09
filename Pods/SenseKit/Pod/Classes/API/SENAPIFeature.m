//
//  SENAPIFeature.m
//  Pods
//
//  Created by Jimmy Lu on 8/4/16.
//
//

#import "SENAPIFeature.h"
#import "SENFeatures.h"

static NSString* const SENAPIFeatureResource = @"v2/features";

@implementation SENAPIFeature

+ (void)getFeatures:(SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPIFeatureResource parameters:nil completion:^(id data, NSError *error) {
        SENFeatures* features = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            features = [[SENFeatures alloc] initWithDictionary:data];
        }
        completion (features, error);
    }];
}

@end
