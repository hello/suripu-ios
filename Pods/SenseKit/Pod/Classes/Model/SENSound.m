//
//  SENSound.m
//  Pods
//
//  Created by Delisa Mason on 1/6/15.
//
//

#import "SENSound.h"

@implementation SENSound

static NSString* const SENSoundDisplayName = @"name";
static NSString* const SENSoundURLPath = @"url";
static NSString* const SENSoundIdentifier = @"id";

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _displayName = dict[SENSoundDisplayName];
        _URLPath = dict[SENSoundURLPath];
        _identifier = dict[SENSoundIdentifier];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _displayName = [aDecoder decodeObjectForKey:SENSoundDisplayName];
        _URLPath = [aDecoder decodeObjectForKey:SENSoundURLPath];
        _identifier = [aDecoder decodeObjectForKey:SENSoundIdentifier];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.displayName forKey:SENSoundDisplayName];
    [aCoder encodeObject:self.URLPath forKey:SENSoundURLPath];
    [aCoder encodeObject:self.identifier forKey:SENSoundIdentifier];
}

- (BOOL)isEqual:(SENSound*)object
{
    if (![object isKindOfClass:[SENSound class]])
        return NO;
    return ((self.displayName && [self.displayName isEqual:object.displayName]) || (!self.displayName && !object.displayName))
        && ((self.URLPath && [self.URLPath isEqual:object.URLPath]) || (!self.URLPath && !object.URLPath))
        && ((self.identifier && [self.identifier isEqual:object.identifier]) || (!self.identifier && !object.identifier));
}

- (NSUInteger)hash
{
    return [self.identifier hash];
}

@end
