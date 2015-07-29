//
//  HEMAppUsage.m
//  Sense
//
//  Created by Jimmy Lu on 7/27/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENKeyedArchiver.h>

#import "NSDate+HEMRelative.h"

#import "HEMAppUsage.h"

// types of app usage
NSString* const HEMAppUsageSystemAlertShown = @"system.alert";
NSString* const HEMAppUsageAppLaunched = @"app.launched";
NSString* const HEMAppUsageTimelineShownWithData = @"timeline.with.data";

// days to keep counts of usage for
static NSUInteger const HEMAppUsageRollingDays = 31;
static NSString* const HEMAppUsageKeyIdentifier = @"identifier";
static NSString* const HEMAppUsageKeyCreated = @"created";
static NSString* const HEMAppUsageKeyUpdated = @"updated";
static NSString* const HEMAppUsageKeyRollingCount = @"rollingCount";

@interface HEMAppUsage()

@property (nonatomic, copy)   NSString* identifier;
@property (nonatomic, strong) NSDate* created;
@property (nonatomic, strong) NSDate* updated;
@property (nonatomic, strong) NSMutableArray* rollingCountPerDay;

@end

@implementation HEMAppUsage

+ (HEMAppUsage*)appUsageForIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    
    NSString *collection = NSStringFromClass([HEMAppUsage class]);
    id usages = [SENKeyedArchiver objectsForKey:identifier
                                  inCollection:collection];
    
    // only expect 1 app usage per identifier
    HEMAppUsage* appUsage = nil;
    if ([usages isKindOfClass:[NSSet class]]) {
        appUsage = [[usages objectEnumerator] nextObject];
    } else if ([usages isKindOfClass:[self class]]) {
        appUsage = usages;
    }
    
    if (!appUsage) {
        appUsage = [[HEMAppUsage alloc] initWithIdentifier:identifier];
    }
    
    return appUsage;
}

+ (void)incrementUsageForIdentifier:(NSString *)identifier {
    HEMAppUsage* appUsage = [self appUsageForIdentifier:identifier];
    if (appUsage) {
        [appUsage increment:YES];
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        _identifier = [[aDecoder decodeObjectForKey:HEMAppUsageKeyIdentifier] copy];
        _created = [aDecoder decodeObjectForKey:HEMAppUsageKeyCreated];
        _updated = [aDecoder decodeObjectForKey:HEMAppUsageKeyUpdated];
        _rollingCountPerDay = [aDecoder decodeObjectForKey:HEMAppUsageKeyRollingCount];
        [self initializeRollingCounts];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:[self identifier] ?: @"" forKey:HEMAppUsageKeyIdentifier];
    [aCoder encodeObject:[self created] ?: [NSDate date] forKey:HEMAppUsageKeyCreated];
    [aCoder encodeObject:[self updated] ?: [NSDate date] forKey:HEMAppUsageKeyUpdated];
    [aCoder encodeObject:[self rollingCountPerDay] forKey:HEMAppUsageKeyRollingCount];
}

#pragma mark -

- (instancetype)initWithIdentifier:(NSString*)identifier {
    if (!identifier) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _created = [NSDate date];
        [self initializeRollingCounts];
    }
    return self;
}

- (void)initializeRollingCounts {
    if (![self rollingCountPerDay]) {
        [self setRollingCountPerDay:[NSMutableArray arrayWithCapacity:HEMAppUsageRollingDays]];
        for (NSUInteger day = 0; day < HEMAppUsageRollingDays; day++) {
            [[self rollingCountPerDay] addObject:@0];
        }
    } else if ([[self rollingCountPerDay] count] < HEMAppUsageRollingDays) {
        // increase days if rolling days have changed
        NSUInteger daysNeeded = HEMAppUsageRollingDays - [[self rollingCountPerDay] count];
        for (NSUInteger i = 0; i < daysNeeded; i++) {
            [[self rollingCountPerDay] addObject:@0];
        }
    }
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

- (BOOL)isEqual:(id)other {
    if (![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    HEMAppUsage* usage = other;
    return [[self identifier] isEqualToString:[usage identifier]]
        && [[self created] isEqual:[usage created]]
        && [[self updated] isEqual:[usage updated]]
        && [[self rollingCountPerDay] isEqual:[other rollingCountPerDay]];
}

- (NSUInteger)todaysRollingIndex {
    NSUInteger daysSinceCreation = [[self created] daysElapsed];
    return daysSinceCreation % HEMAppUsageRollingDays;
}

- (void)increment:(BOOL)autosave {
    NSUInteger daysSinceLastUpdate = [[self updated] daysElapsed];
    NSUInteger rollingIndex = [self todaysRollingIndex];
    
    NSNumber* countForDay = nil;
    if (daysSinceLastUpdate == 0) {
        countForDay = [self rollingCountPerDay][rollingIndex];
    } else {
        countForDay = @0;
    }
    
    [self rollingCountPerDay][rollingIndex] = @([countForDay integerValue] + 1);
    
    DDLogVerbose(@"incrementing usage for %@", [self identifier]);
    
    if (autosave) {
        [self save];
    }
}

- (NSUInteger)usageWithin:(HEMAppUsageInterval)interval {
    [self clearCountBetweenLastUpdateAndNow];
    
    NSUInteger countIndex = [self todaysRollingIndex];
    
    NSUInteger daysToInclude = 0;
    if (interval == HEMAppUsageIntervalLast7Days) {
        daysToInclude = 7;
    } else if (interval == HEMAppUsageIntervalLast31Days) {
        daysToInclude = 31;
    }
    
    NSUInteger totalCount = 0;
    NSInteger nextIndex = countIndex;
    for (NSUInteger i = 0; i < daysToInclude; i++) {
        totalCount += [[self rollingCountPerDay][countIndex] integerValue];
        nextIndex = countIndex - 1;
        if (nextIndex < 0) {
            nextIndex = HEMAppUsageRollingDays + nextIndex;
        }
        countIndex = nextIndex % HEMAppUsageRollingDays;
    }
    
    return totalCount;
}

- (void)clearCountBetweenLastUpdateAndNow {
    NSUInteger daysFromLastUpdatedToStartClearing = [[self updated] daysElapsed] - 1;
    NSUInteger currentRollingIndex = [self todaysRollingIndex];
    NSUInteger rollingIndex = daysFromLastUpdatedToStartClearing % HEMAppUsageRollingDays;
    
    while (daysFromLastUpdatedToStartClearing > 1 && rollingIndex != currentRollingIndex) {
        [self rollingCountPerDay][rollingIndex] = @0;
        rollingIndex = --daysFromLastUpdatedToStartClearing % HEMAppUsageRollingDays;
    }
}

- (void)save {
    if ([self identifier]) {
        [self clearCountBetweenLastUpdateAndNow];
        [self setUpdated:[NSDate date]];
        [SENKeyedArchiver setObject:self
                             forKey:[self identifier]
                       inCollection:NSStringFromClass([self class])];
    }
}

@end
