//
//  SENAPISpeech.m
//  Pods
//
//  Created by Jimmy Lu on 7/28/16.
//
//
#import "SENAPISpeech.h"
#import "SENSpeechResult.h"

static NSString* const SENAPISpeechResource = @"v1/speech";
static NSString* const SENAPISpeechOnboarding = @"onboarding";

@implementation SENAPISpeech

+ (void)getRecentVoiceCommands:(SENAPIDataBlock)completion {
    NSString* path = [SENAPISpeechResource stringByAppendingString:SENAPISpeechOnboarding];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        NSMutableArray* results = nil;
        if (!error && [data isKindOfClass:[NSArray class]]) {
            results = [NSMutableArray arrayWithCapacity:[data count]];
            for (id object in data) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    [results addObject:[[SENSpeechResult alloc] initWithDictionary:object]];
                }
            }
        }
        completion (results, error);
    }];
}

@end
