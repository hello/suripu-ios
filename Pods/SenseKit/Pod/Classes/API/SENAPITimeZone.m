//
//  SENAPITimeZone.m
//  Pods
//
//  Created by Jimmy Lu on 10/29/14.
//
//

#import "SENAPITimeZone.h"

static NSString* const kSENAPITimeZoneErrorDomain = @"is.hello.api.timezone";
static NSString* const kSENAPITimeZoneResourceName = @"timezone";
static NSString* const kSENAPITimeZoneParamOffset = @"timezone_offset";
static NSString* const kSENAPITimeZoneParamId = @"timezone_id";

@implementation SENAPITimeZone

#pragma mark - Updating Time Zone

+ (void)setCurrentTimeZone:(SENAPIDataBlock)completion {
    [self setTimeZone:[NSTimeZone localTimeZone] completion:completion];
}

+ (void)setTimeZone:(NSTimeZone*)timeZone completion:(SENAPIDataBlock)completion {
    if (timeZone == nil) {
        if (completion) completion (nil, [NSError errorWithDomain:kSENAPITimeZoneErrorDomain
                                                        code:SENAPITimeZoneErrorInvalidArgument
                                                    userInfo:nil]);
        return;
    }
    
    NSNumber* timeZoneInMillis = @([timeZone secondsFromGMT] * 1000);
    NSString* timeZoneId = [timeZone name];
    
    [SENAPIClient POST:kSENAPITimeZoneResourceName
            parameters:@{kSENAPITimeZoneParamOffset : timeZoneInMillis,
                         kSENAPITimeZoneParamId : timeZoneId}
            completion:completion];
}

#pragma mark - Time Zone Retrieval

+ (NSTimeZone*)timeZoneFromResponse:(id)data error:(NSError**)error {
    NSTimeZone* timeZone = nil;
    
    if ([data isKindOfClass:[NSDictionary class]]) {
        id zoneIdObj = [data objectForKey:kSENAPITimeZoneParamId];
        if ([zoneIdObj isKindOfClass:[NSString class]]) {
            timeZone = [NSTimeZone timeZoneWithName:zoneIdObj];
        }
    }
    
    if (timeZone == nil && error != NULL) {
        *error = [NSError errorWithDomain:kSENAPITimeZoneErrorDomain
                                     code:SENAPITimeZoneErrorInvalidResponse
                                 userInfo:nil];
    }
    
    return timeZone;
}

+ (void)getConfiguredTimeZone:(SENAPIDataBlock)completion {
    if (!completion) return;
    
    [SENAPIClient GET:kSENAPITimeZoneResourceName parameters:nil completion:^(id data, NSError *error) {
        if (error) {
            completion (nil, error);
        } else {
            NSError* parseError = nil;
            NSTimeZone* timeZone = [self timeZoneFromResponse:data error:&parseError];
            completion (timeZone, parseError);
        }
    }];
}

@end
