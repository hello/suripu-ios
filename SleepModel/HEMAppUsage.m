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
@property (nonatomic, assign) NSUInteger count;

@end

@implementation HEMAppUsage

+ (HEMAppUsage *)appUsageForIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    
    NSString *collection = NSStringFromClass([HEMAppUsage class]);
    NSSet *usages = [SENKeyedArchiver objectsForKey:identifier
                                       inCollection:collection];
    
    // only expect 1 app usage per identifier
    HEMAppUsage *appUsage = [[usages objectEnumerator] nextObject];
    if (!appUsage) {
        appUsage = [[HEMAppUsage alloc] initWithIdentifier:identifier];
    }
    
    return appUsage;
}

+ (void)reset {
    NSString* collection = NSStringFromClass([HEMAppUsage class]);
    [SENKeyedArchiver removeAllObjectsInCollection:collection];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        _identifier = [[aDecoder decodeObjectForKey:HEMAppUsageKeyIdentifier] copy];
        _created = [aDecoder decodeObjectForKey:HEMAppUsageKeyCreated];
        _updated = [aDecoder decodeObjectForKey:HEMAppUsageKeyUpdated];
        _count = [[aDecoder decodeObjectForKey:HEMAppUsageKeyCount] integerValue];
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

- (void)setCount:(NSUInteger)count {
    _count = count;
    [self setUpdated:[NSDate date]];
}

- (void)resetCount {
    [self setCount:0];
}

- (void)save {
    if ([self identifier]) {
        [SENKeyedArchiver setObject:self
                             forKey:[self identifier]
                       inCollection:NSStringFromClass([self class])];
    }
}

- (void)clear {
    if ([self identifier]) {
        NSString* key = [self identifier];
        NSString* collection = NSStringFromClass([self class]);
        [SENKeyedArchiver removeAllObjectsForKey:key inCollection:collection];
    }
}

@end
