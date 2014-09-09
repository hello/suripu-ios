
#import "SENBackgroundNoise.h"
#import "SENKeyedArchiver.h"

NSString* const SENBackgroundNoiseSoundNameKey = @"sound_name";
NSString* const SENBackgroundNoiseStorageKey = @"SENBackgroundNoise";

@implementation SENBackgroundNoise

+ (instancetype)savedBackgroundNoise
{
    SENBackgroundNoise* noise = [SENKeyedArchiver objectsForKey:SENBackgroundNoiseStorageKey inCollection:NSStringFromClass([self class])];
    if (!noise) {
        noise = [[SENBackgroundNoise alloc] initWithSoundName:NSLocalizedString(@"noise.sound-name.none", nil)];
    }
    return noise;
}

- (instancetype)initWithSoundName:(NSString*)soundName
{
    if (self = [super init]) {
        _soundName = soundName;
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _soundName = [aDecoder decodeObjectForKey:SENBackgroundNoiseSoundNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.soundName forKey:SENBackgroundNoiseSoundNameKey];
}

- (void)save
{
    [SENKeyedArchiver setObject:self forKey:SENBackgroundNoiseStorageKey inCollection:NSStringFromClass([SENBackgroundNoise class])];
}

- (BOOL)isOn
{
    return ![self.soundName isEqualToString:NSLocalizedString(@"noise.sound-name.none", nil)];
}

@end
