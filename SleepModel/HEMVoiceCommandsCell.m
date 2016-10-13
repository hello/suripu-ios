//
//  HEMVoiceCommandsCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceCommandsCell.h"
#import "HEMVoiceExampleView.h"

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

- (HEMVoiceExampleView*)addCommandWithCategory:(NSString*)category
                                       example:(NSString*)example
                                          icon:(UIImage*)icon {
    NSInteger count = [[[self commandsContainerView] subviews] count];
    if (count == [self estimatedNumberOfCommands]) {
        return nil;
    }
    HEMVoiceExampleView* commandView = [HEMVoiceExampleView exampleViewWithCategoryName:category
                                                                                example:example
                                                                              iconImage:icon];

    CGRect commandFrame = CGRectZero;
    commandFrame.size.width = CGRectGetWidth([[self commandsContainerView] bounds]);
    commandFrame.size.height = HEMVoiceCommandViewSize;
    commandFrame.origin.y = count * HEMVoiceCommandViewSize;
    [commandView setFrame:commandFrame];
    [commandView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if (count == [self estimatedNumberOfCommands]) {
        [[commandView separatorView] removeFromSuperview];
    }
    
    CGRect containerFrame = [[self commandsContainerView] frame];
    containerFrame.size.height = CGRectGetMaxY(commandFrame);
    [[self commandsContainerView] setFrame:containerFrame];
    
    [[self commandsContainerView] addSubview:commandView];
    
    [self setNeedsUpdateConstraints];
    
    return commandView;
}

@end
