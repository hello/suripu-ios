//
//  SENAPISpeech.m
//  Pods
//
//  Created by Jimmy Lu on 7/28/16.
//
//
#import "Model.h"
#import "SENAPISpeech.h"

static NSString* const SENAPISpeechResource = @"v1/speech";
static NSString* const SENAPISpeechOnboarding = @"onboarding";
static NSString* const SENAPIVoiceResource = @"v2/voice";
static NSString* const SENAPIVoiceCommandsParam = @"voice_command_topics";

@implementation SENAPISpeech

+ (void)getRecentVoiceCommands:(SENAPIDataBlock)completion {
    NSString* path = [SENAPISpeechResource stringByAppendingPathComponent:SENAPISpeechOnboarding];
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

+ (void)getSupportedVoiceCommands:(SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPIVoiceResource parameters:nil completion:^(id data, NSError *error) {
        NSMutableArray<SENVoiceCommandGroup*>* commands = nil;
        if ([data isKindOfClass:[NSDictionary class]] && !error) {
            NSArray* commandObjs = SENObjectOfClass(data[SENAPIVoiceCommandsParam], [NSArray class]);
            commands = [NSMutableArray arrayWithCapacity:[commandObjs count]];
            NSDictionary* commandDict = nil;
            for (id commandObj in commandObjs) {
                commandDict = SENObjectOfClass(commandObj, [NSDictionary class]);
                if (commandDict) {
                    [commands addObject:[[SENVoiceCommandGroup alloc] initWithDictionary:commandDict]];
                }
            }
        }
        completion (commands, error);
    }];
}

@end
