//
//  SENFeatures.m
//  Pods
//
//  Created by Jimmy Lu on 8/4/16.
//
//

#import "SENFeatures.h"
#import "SENKeyedArchiver.h"
#import "Model.h"

static NSString* const SENFeaturesTypeVoice = @"VOICE";

@interface SENFeatures()

@property (nonatomic, assign, getter=hasVoice) BOOL voice;

@end

@implementation SENFeatures

+ (instancetype)savedFeatures {
    NSString *key = [self collectionName];
    return [SENKeyedArchiver objectsForKey:key inCollection:key];
}

+ (NSString*)collectionName {
    return NSStringFromClass(self);
}

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

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        _voice = [[aDecoder decodeObjectForKey:SENFeaturesTypeVoice] boolValue];
    }
    return self;
}

- (NSString*)description {
    static NSString* const SENFeaturesStringFormat = @"<SENFeatures @voice=%@>";
    return [NSString stringWithFormat:SENFeaturesStringFormat, [self hasVoice] ? @"yes" : @"no"];
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:@([self hasVoice]) forKey:SENFeaturesTypeVoice];
}

- (void)save {
    NSString* collection = [[self class] collectionName];
    [SENKeyedArchiver setObject:self forKey:collection inCollection:collection];
}

- (void)remove {
    NSString* collection = [[self class] collectionName];
    [SENKeyedArchiver removeAllObjectsInCollection:collection];
}

@end
