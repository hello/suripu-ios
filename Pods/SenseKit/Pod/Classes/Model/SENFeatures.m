//
//  SENFeatures.m
//  Pods
//
//  Created by Jimmy Lu on 8/4/16.
//
//

#import "SENFeatures.h"
#import "Model.h"

static NSString* const SENFeaturesTypeVoice = @"VOICE";

@interface SENFeatures()

@property (nonatomic, assign, getter=hasVoice) BOOL voice;

@end

@implementation SENFeatures

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        NSArray* keys = [dictionary allKeys];
        NSString* key = nil;
        for (id object in keys) {
            key = SENObjectOfClass(object, [NSString class]);
            if ([[key uppercaseString] isEqualToString:SENFeaturesTypeVoice]) {
                _voice = YES;
            }
        }
    }
    return self;
}

@end
