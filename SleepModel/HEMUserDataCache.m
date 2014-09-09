
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAccount.h>

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

@end
