//
//  HEMDeviceWarning.m
//  Sense
//
//  Created by Jimmy Lu on 11/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMDeviceWarning.h"

static NSUInteger const HEMDeviceWarningHashPrime = 31;

@interface HEMDeviceWarning()

@property (nonatomic, copy, nonnull) NSString* localizedSummary;
@property (nonatomic, copy, nonnull) NSAttributedString* localizedMessage;
@property (nonatomic, copy, nullable) NSString* supportPage;
@property (nonatomic, assign) HEMDeviceWarningType type;

@end

@implementation HEMDeviceWarning

- (nonnull instancetype)initWithType:(HEMDeviceWarningType)type
                             summary:(nonnull NSString*)localizedSummary
                             message:(nonnull NSAttributedString*)localizedMessage
                         supportPage:(nullable NSString*)supportPage {
    
    self = [super init];
    if (self) {
        _type = type;
        _localizedSummary = [localizedSummary copy];
        _localizedMessage = [localizedMessage copy];
        _supportPage = [supportPage copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[HEMDeviceWarning class]]) {
        return NO;
    }
    
    HEMDeviceWarning* other = object;
    return [self type] == [other type]
        && [[self localizedMessage] isEqualToAttributedString:[object localizedMessage]]
        && [[self supportPage] isEqualToString:[other supportPage]]
        && [[self localizedSummary] isEqualToString:[other localizedSummary]];
}

- (NSUInteger)hash {
    NSUInteger result = HEMDeviceWarningHashPrime + [[self localizedSummary] hash];
    result = HEMDeviceWarningHashPrime * result + [[self localizedMessage] hash];
    result = HEMDeviceWarningHashPrime * result + [[self supportPage] hash];
    result = HEMDeviceWarningHashPrime * result + [self type];
    return result;
}

@end
