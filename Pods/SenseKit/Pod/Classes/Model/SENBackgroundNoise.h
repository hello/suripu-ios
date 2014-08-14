
#import <Foundation/Foundation.h>

@interface SENBackgroundNoise : NSObject <NSCoding>

+ (instancetype)savedBackgroundNoise;

- (instancetype)initWithSoundName:(NSString*)soundName;
- (void)save;
- (BOOL)isOn;

@property (nonatomic, strong) NSString* soundName;
@end
