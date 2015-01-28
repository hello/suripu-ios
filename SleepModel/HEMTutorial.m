//
//  HEMTutorial.m
//  Sense
//
//  Created by Delisa Mason on 1/28/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import "HEMTutorial.h"
#import "HEMFullscreenDialogView.h"

@implementation HEMTutorial

static NSString* const HEMTutorialTimelineKey = @"HEMTutorialTimeline";

+ (void)showTutorialForTimelineIfNeeded
{
    if (![SENAuthorizationService isAuthorized])
        return;
    if ([self shouldShowTutorialForKey:HEMTutorialTimelineKey]) {
        HEMDialogContent* content1 = [HEMDialogContent new];
        content1.title = NSLocalizedString(@"tutorial.timeline.title1", nil);
        content1.content = NSLocalizedString(@"tutorial.timeline.message1", nil);
        content1.image = [UIImage imageNamed:@"timeline_explain_sleep"];
        HEMDialogContent* content2 = [HEMDialogContent new];
        content2.content = NSLocalizedString(@"tutorial.timeline.message2", nil);
        content2.image = [UIImage imageNamed:@"timeline_explain_score"];
        HEMDialogContent* content3 = [HEMDialogContent new];
        content3.content = NSLocalizedString(@"tutorial.timeline.message3", nil);
        content3.image = [UIImage imageNamed:@"timeline_explain_before"];
        HEMDialogContent* content4 = [HEMDialogContent new];
        content4.content = NSLocalizedString(@"tutorial.timeline.message4", nil);
        content4.image = [UIImage imageNamed:@"timeline_explain_graph"];
        [HEMFullscreenDialogView showDialogsWithContent:@[content1, content2, content3, content4]];
        [self markTutorialViewed:HEMTutorialTimelineKey];
    }
}

+ (BOOL)shouldShowTutorialForKey:(NSString*)key
{
    BOOL hasBeenViewed = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return !hasBeenViewed;
}

+ (void)markTutorialViewed:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
}

@end
