//
//  SENSpeechResult.m
//  Pods
//
//  Created by Jimmy Lu on 7/28/16.
//
//

#import "SENSpeechResult.h"
#import "Model.h"

static NSString* const SENSpeechResultDate = @"datetime_utc";
static NSString* const SENSpeechResultRequestText = @"text";
static NSString* const SENSpeechResultResponseText = @"response_text";
static NSString* const SENSpeechResultCommand = @"command";
static NSString* const SENSpeechResultStatus = @"result";
static NSString* const SENSpeechResultStatusOk = @"ok";
static NSString* const SENSpeechResultStatusRejected = @"rejected";
static NSString* const SENSpeechResultStatusAgain = @"try again";

@interface SENSpeechResult()

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, copy) NSString* requestText;
@property (nonatomic, copy) NSString* responseText;
@property (nonatomic, copy) NSString* command;
@property (nonatomic, assign) SENSpeechStatus status;

@end

@implementation SENSpeechResult

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _date = SENDateFromNumber(dictionary[SENSpeechResultDate]);
        _requestText = SENObjectOfClass(dictionary[SENSpeechResultRequestText], [NSString class]);
        _responseText = SENObjectOfClass(dictionary[SENSpeechResultResponseText], [NSString class]);
        _command = SENObjectOfClass(dictionary[SENSpeechResultCommand], [NSString class]);
        
        NSString* statusText = SENObjectOfClass(dictionary[SENSpeechResultStatus], [NSString class]);
        _status = [self statusFromString:statusText];
    }
    return self;
}

- (SENSpeechStatus)statusFromString:(NSString*)statusText {
    NSString* lower = [statusText lowercaseString];
    SENSpeechStatus status = SENSpeechStatusUnknown;
    if ([lower isEqualToString:SENSpeechResultStatusOk]) {
        status = SENSpeechStatusOk;
    } else if ([lower isEqualToString:SENSpeechResultStatusAgain]) {
        status = SENSpeechStatusTryAgain;
    } else if ([lower isEqualToString:SENSpeechResultStatusRejected]) {
        status = SENSpeechStatusRejected;
    }
    return status;
}

@end
