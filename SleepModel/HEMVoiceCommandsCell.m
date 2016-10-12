//
//  HEMVoiceCommandsCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceCommandsCell.h"

static CGFloat const HEMVoiceCommandCellBaseHeight = 50.0f;
static CGFloat const HEMVoiceCommandViewSize = 80.0f;

@implementation HEMVoiceCommandsCell

+ (CGFloat)heightWithNumberOfCommands:(NSInteger)numberOfCommands {
    return HEMVoiceCommandCellBaseHeight + (HEMVoiceCommandViewSize * numberOfCommands);
}

- (void)setEstimatedNumberOfCommands:(NSInteger)estimatedNumberOfCommands {
    if (_estimatedNumberOfCommands != estimatedNumberOfCommands) {
        NSArray* subviews = [[self commandsContainerView] subviews];
        [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _estimatedNumberOfCommands = estimatedNumberOfCommands;
    }
}

- (void)addCommandWithCategory:(NSString*)category
                       example:(NSString*)example
                          icon:(UIImage*)icon {
    
}

@end
