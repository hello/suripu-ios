//
//  HEMVoiceCommand.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceCommandGroup.h"

@implementation HEMVoiceCommandExamples

@end

@implementation HEMVoiceCommandGroup

- (NSString*)example {
    HEMVoiceCommandExamples* examples = [[self examples] firstObject];
    return [[examples commands] firstObject];
}

@end
