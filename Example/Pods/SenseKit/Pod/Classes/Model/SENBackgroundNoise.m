
#import "SENBackgroundNoise.h"

NSString* const SENBackgroundNoiseSoundNameKey = @"sound_name";
NSString* const SENBackgroundNoiseOnKey = @"on";

@implementation SENBackgroundNoise

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _on = [[aDecoder decodeObjectForKey:SENBackgroundNoiseOnKey] boolValue];
        _soundName = [aDecoder decodeObjectForKey:SENBackgroundNoiseSoundNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.on) forKey:SENBackgroundNoiseOnKey];
    [aCoder encodeObject:self.soundName forKey:SENBackgroundNoiseSoundNameKey];
}

@end
