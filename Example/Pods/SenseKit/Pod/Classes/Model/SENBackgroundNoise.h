
#import <Foundation/Foundation.h>

@interface SENBackgroundNoise : NSObject <NSCoding>

@property (nonatomic, strong) NSString* soundName;
@property (nonatomic, getter=isOn) BOOL on;
@end
