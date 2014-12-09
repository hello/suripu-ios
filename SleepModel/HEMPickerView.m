//
//  HEMPickerView.m
//  Sense
//
//  Created by Jimmy Lu on 12/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPickerView.h"

@interface HEMPickerView()

@property (nonatomic, strong) NSMutableDictionary* animationCompletionBlocks;

@end

@implementation HEMPickerView

- (void)animationDidFinish:(NSString*)animationId finished:(BOOL)finished context:(void*)context {
    HEMPickerSelectionCompletion block = [[self animationCompletionBlocks] objectForKey:animationId];
    if (block) block();
}

- (void)selectRow:(NSInteger)row
      inComponent:(NSInteger)component
       completion:(void(^)(void))completion {
    NSString* uuid = [[NSUUID UUID] UUIDString];
    
    if ([self animationCompletionBlocks] == nil) {
        [self setAnimationCompletionBlocks:[NSMutableDictionary dictionary]];
    }
    [[self animationCompletionBlocks] setValue:[completion copy] forKey:uuid];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self selectRow:row inComponent:component animated:YES];
    [CATransaction commit];
}

@end
