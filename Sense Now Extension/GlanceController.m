//
//  GlanceController.m
//  Sense Now Extension
//
//  Created by Delisa Mason on 10/12/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENTimeline.h>
#import "GlanceController.h"
#import "ModelCache.h"
#import "UIColor+HEMStyle.h"

@interface GlanceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *messageLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *sleepScoreLabel;
@end

@implementation GlanceController

- (void)willActivate {
    [super willActivate];
    [self updateLabels];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLabels)
                                                 name:ModelCacheUpdatedNotification
                                               object:ModelCacheUpdatedObjectSleepResult];
}

- (void)didDeactivate {
    [super didDeactivate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateLabels {
    SENTimeline *timeline = [ModelCache lastNightTimeline];
    NSInteger score = [timeline.score integerValue];
    [self.messageLabel setText:[self textForSleepMessage:timeline.message]];
    [self.sleepScoreLabel setText:[self textForSleepScore:score]];
    [self.sleepScoreLabel setTextColor:[UIColor colorForSleepScore:score]];
}

- (NSString *)textForSleepMessage:(NSString *)message {
    return [message stringByReplacingOccurrencesOfString:@"*" withString:@""];
}

- (NSString *)textForSleepScore:(NSInteger)score {
    return [NSString stringWithFormat:@"%ld", (long)score];
}

@end
