//
//  SENDFUStatus.m
//  Pods
//
//  Created by Jimmy Lu on 7/18/16.
//
//

#import "SENDFUStatus.h"
#import "Model.h"

static NSString* const SENDFUStatusPropStatus = @"status";
static NSString* const SENDFUStatusNotRequired = @"NOT_REQUIRED";
static NSString* const SENDFUStatusRequired = @"REQUIRED";
static NSString* const SENDFUStatusRequestSent = @"RESPONSE_SENT"; // EH?  should be request?
static NSString* const SENDFUStatusInProgress = @"IN_PROGRESS";
static NSString* const SENDFUStatusComplete = @"COMPLETE";
static NSString* const SENDFUStatusError = @"ERROR";

@implementation SENDFUStatus

- (instancetype)initWithDictionary:(NSDictionary*)response {
    self = [super init];
    if (self) {
        NSString* status = response[SENDFUStatusPropStatus];
        _currentState = [self enumValueFromString:status];
    }
    return self;
}

- (SENDFUState)enumValueFromString:(NSString*)status {
    SENDFUState enumValue = SENDFUStateUnknown;
    if ([status isEqualToString:SENDFUStatusNotRequired]) {
        enumValue = SENDFUStateNotRequired;
    } else if ([status isEqualToString:SENDFUStatusRequired]) {
        enumValue = SENDFUStateRequired;
    } else if ([status isEqualToString:SENDFUStatusRequestSent]) {
        enumValue = SENDFUStateRequestSent;
    } else if ([status isEqualToString:SENDFUStatusInProgress]) {
        enumValue = SENDFUStateInProgress;
    } else if ([status isEqualToString:SENDFUStatusComplete]) {
        enumValue = SENDFUStateComplete;
    } else if ([status isEqualToString:SENDFUStatusError]) {
        enumValue = SENDFUStateError;
    }
    return enumValue;
}

- (BOOL)isRequired {
    return [self currentState] == SENDFUStateRequired;
}

- (BOOL)isInProgress {
    switch ([self currentState]) {
        case SENDFUStateRequestSent:
        case SENDFUStateInProgress:
            return YES;
        default:
            return NO;
    }
}

@end
