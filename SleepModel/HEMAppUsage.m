//
//  HEMAppUsage.m
//  Sense
//
//  Created by Jimmy Lu on 7/27/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENKeyedArchiver.h>

#import "HEMAppUsage.h"

static NSString* const HEMAppUsageKeyIdentifier = @"identifier";
static NSString* const HEMAppUsageKeyCreated = @"created";
static NSString* const HEMAppUsageKeyUpdated = @"updated";
static NSString* const HEMAppUsageKeyCount = @"count";

@interface HEMAppUsage()

@property (nonatomic, copy)   NSString* identifier;
@property (nonatomic, strong) NSDate* created;
@property (nonatomic, strong) NSDate* updated;
@property (nonatomic, assign) long count;

@end

@implementation HEMAppUsage

+ (void)appUsageForIdentifier:(NSString *)identifier
                   completion:(void(^)(HEMAppUsage* usage))completion {
    
    if (!completion) {
        return;
    }
    
    if (!identifier) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *collection = NSStringFromClass([HEMAppUsage class]);
        NSSet *usages = [SENKeyedArchiver objectsForKey:identifier
                                           inCollection:collection];
        
        // only expect 1 app usage per identifier
        HEMAppUsage *appUsage = [[usages objectEnumerator] nextObject];
        if (!appUsage) {
            appUsage = [[HEMAppUsage alloc] initWithIdentifier:identifier];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion (appUsage);
        });
    });
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        _identifier = [[aDecoder decodeObjectForKey:HEMAppUsageKeyIdentifier] copy];
        _created = [aDecoder decodeObjectForKey:HEMAppUsageKeyCreated];
        _updated = [aDecoder decodeObjectForKey:HEMAppUsageKeyUpdated];
        _count = [[aDecoder decodeObjectForKey:HEMAppUsageKeyCount] longValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:[self identifier] ?: @"" forKey:HEMAppUsageKeyIdentifier];
    [aCoder encodeObject:[self created] ?: [NSDate date] forKey:HEMAppUsageKeyCreated];
    [aCoder encodeObject:[self updated] ?: [NSDate date] forKey:HEMAppUsageKeyUpdated];
    [aCoder encodeObject:@([self count]) forKey:HEMAppUsageKeyCount];
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
    }
    return self;
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

- (NSDate*)today {
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate* now = [NSDate date];
    NSCalendarUnit flags = NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [calendar components:flags fromDate:now];
    return [calendar dateFromComponents:components];
}

- (BOOL)isEqual:(id)other {
    if (![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    HEMAppUsage* usage = other;
    return [[self identifier] isEqualToString:[usage identifier]]
        && [[self created] isEqual:[usage created]]
        && [[self updated] isEqual:[usage updated]]
        && [self count] == [other count];
}

- (void)increment {
    [self setCount:[self count] + 1];
}

- (void)setCount:(long)count {
    _count = count;
    [self setUpdated:[NSDate date]];
}

- (void)resetCount {
    [self setCount:0];
}

- (void)save {
    if ([self identifier]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [SENKeyedArchiver setObject:strongSelf
                                 forKey:[strongSelf identifier]
                           inCollection:NSStringFromClass([strongSelf class])];
        });
    }
}

@end
