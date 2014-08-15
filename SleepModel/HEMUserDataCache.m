
#import "HEMUserDataCache.h"

static HEMUserDataCache* sharedUserDataCache = nil;

@implementation HEMUserDataCache

+ (instancetype)sharedUserDataCache
{
    if (!sharedUserDataCache) {
        sharedUserDataCache = [HEMUserDataCache new];
    }
    return sharedUserDataCache;
}

+ (void)clearSharedUserDataCache
{
    sharedUserDataCache = nil;
}

+ (void)updateAccountWithSharedUserDataWithCompletion:(void (^)(NSError*))block
{
    HEMUserDataCache* cache = [self sharedUserDataCache];
    [SENAPIAccount updateUserAccountWithAge:cache.age gender:cache.gender height:cache.heightInCentimeters weight:cache.weightInKilograms completion:^(id data, NSError* error) {
        if (block)
        block(error);
    }];
}

@end
