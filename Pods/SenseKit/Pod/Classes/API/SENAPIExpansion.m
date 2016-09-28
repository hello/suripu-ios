//
//  SENAPIExpansion.m
//  Pods
//
//  Created by Jimmy Lu on 9/27/16.
//
//

#import "SENAPIExpansion.h"
#import "SENExpansion.h"

static NSString* const kSENAPIExpansionResource = @"v2/expansions";
static NSString* const kSENaPIExpansionConfigPath = @"configurations";

@implementation SENAPIExpansion

+ (void)getSupportedExpansions:(SENAPIDataBlock)completion {
    [SENAPIClient GET:kSENAPIExpansionResource parameters:nil completion:^(id data, NSError *error) {
        NSMutableArray<SENExpansion*>* expansions = nil;
        if (!error && [data isKindOfClass:[NSArray class]]) {
            expansions = [NSMutableArray arrayWithCapacity:[data count]];
            for (id dataObj in data) {
                if ([dataObj isKindOfClass:[NSDictionary class]]) {
                    [expansions addObject:[[SENExpansion alloc] initWithDictionary:dataObj]];
                }
            }
        }
        completion (expansions, error);
    }];
}

+ (void)getExpansionById:(NSString*)expansionId completion:(SENAPIDataBlock)completion {
    NSString* path = [kSENAPIExpansionResource stringByAppendingPathComponent:kSENaPIExpansionConfigPath];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENExpansion* expansion = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            expansion = [[SENExpansion alloc] initWithDictionary:data];
        }
        completion (expansion, error);
    }];
}

+ (void)updateExpansionStateFor:(SENExpansion*)expansion completion:(SENAPIDataBlock)completion {
    NSString* path = [kSENAPIExpansionResource stringByAppendingPathComponent:[expansion identifier]];
    NSDictionary* params = [expansion dictionaryValueForUpdate];
    [SENAPIClient PATCH:path parameters:params completion:completion];
}

+ (void)getExpansionConfigurationsFor:(SENExpansion*)expansion completion:(SENAPIDataBlock)completion {
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@",
                      kSENAPIExpansionResource,
                      [expansion identifier],
                      kSENaPIExpansionConfigPath];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        NSMutableArray<SENExpansionConfig*>* configs = nil;
        if (!error && [data isKindOfClass:[NSArray class]]) {
            configs = [NSMutableArray arrayWithCapacity:[data count]];
            for (id dataObj in data) {
                if ([dataObj isKindOfClass:[NSDictionary class]]) {
                    [configs addObject:[[SENExpansionConfig alloc] initWithDictionary:dataObj]];
                }
            }
        }
        completion (configs, error);
    }];
}

+ (void)setExpansionConfiguration:(SENExpansionConfig*)config
                     forExpansion:(SENExpansion*)expansion
                       completion:(SENAPIDataBlock)completion {
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@",
                      kSENAPIExpansionResource,
                      [expansion identifier],
                      kSENaPIExpansionConfigPath];
    NSDictionary* params = [config dictionaryValue];
    [SENAPIClient PUT:path parameters:params completion:completion];
}

@end
