//
//  SENRemoteImage.m
//  Pods
//
//  Created by Jimmy Lu on 12/2/15.
//
//

#import "SENRemoteImage.h"

static NSString* const HEMRemoteImageScale1 = @"phone_1x";
static NSString* const HEMRemoteImageScale2 = @"phone_2x";
static NSString* const HEMRemoteImageScale3 = @"phone_3x";

@interface SENRemoteImage()

@property (nullable, nonatomic, copy) NSString* normalUri;
@property (nullable, nonatomic, copy) NSString* doubleScaleUri;
@property (nullable, nonatomic, copy) NSString* tripeScaleUri;

@end

@implementation SENRemoteImage

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _normalUri = [dictionary[HEMRemoteImageScale1] copy];
        _doubleScaleUri = [dictionary[HEMRemoteImageScale2] copy];
        _tripeScaleUri = [dictionary[HEMRemoteImageScale3] copy];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _normalUri = [aDecoder decodeObjectForKey:HEMRemoteImageScale1];
        _doubleScaleUri = [aDecoder decodeObjectForKey:HEMRemoteImageScale2];
        _tripeScaleUri = [aDecoder decodeObjectForKey:HEMRemoteImageScale3];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if ([self normalUri]) {
        [aCoder encodeObject:[self normalUri] forKey:HEMRemoteImageScale1];
    }
    if ([self doubleScaleUri]) {
        [aCoder encodeObject:[self doubleScaleUri] forKey:HEMRemoteImageScale2];
    }
    if ([self tripeScaleUri]) {
        [aCoder encodeObject:[self tripeScaleUri] forKey:HEMRemoteImageScale3];
    }
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[self class]]) {
        return NO;
    } else {
        return ((![self normalUri] && ![other normalUri]) || [[self normalUri] isEqualToString:[other normalUri]])
            && ((![self doubleScaleUri] && ![other doubleScaleUri]) || [[self doubleScaleUri] isEqualToString:[other doubleScaleUri]])
            && ((![self tripeScaleUri] && ![other tripeScaleUri]) || [[self tripeScaleUri] isEqualToString:[other tripeScaleUri]]);
    }
}

- (NSUInteger)hash {
    return [[self normalUri] hash] + [[self doubleScaleUri] hash] + [[self tripeScaleUri] hash];
}

@end
