//
//  HEMVoiceCommandsCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMVoiceCommandsCell.h"
#import "HEMVoiceExampleView.h"

static CGFloat const HEMVoiceCommandViewSize = 80.0f;

@implementation HEMVoiceCommandsCell

+ (CGFloat)heightWithNumberOfCommands:(NSInteger)numberOfCommands {
    return (HEMVoiceCommandViewSize * numberOfCommands);
}

+ (CGFloat)heightWithCommands:(NSArray<NSString*>*)commands maxWidth:(CGFloat)maxWidth {
    CGFloat totalHeight = 0.0f;
    for (NSString* command in commands) {
        totalHeight += [HEMVoiceExampleView heightWithExampleText:command withMaxWidth:maxWidth];
    }
    return totalHeight;
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
                                          icon:(NSString*)iconURL
                                     cellWidth:(CGFloat)cellWidth {
    
    NSInteger count = [[[self commandsContainerView] subviews] count];
    if (count == [self estimatedNumberOfCommands]) {
        return nil;
    }
    HEMVoiceExampleView* commandView = [HEMVoiceExampleView exampleViewWithCategoryName:category
                                                                                example:example
                                                                                iconURL:iconURL];
    
    [[commandView iconView] setContentMode:UIViewContentModeScaleAspectFit];
    [[commandView iconView] setBackgroundColor:[[self commandsContainerView] backgroundColor]];
    
    CGFloat currentHeight = CGRectGetHeight([[self commandsContainerView] bounds]);
    CGFloat height = [HEMVoiceExampleView heightWithExampleText:example withMaxWidth:cellWidth];
    CGRect commandFrame = CGRectZero;
    commandFrame.size.width = CGRectGetWidth([[self commandsContainerView] bounds]);
    commandFrame.size.height = height;
    commandFrame.origin.y = count == 0 ? 0.0f : currentHeight;
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
