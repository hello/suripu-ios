//
//  HEMInsightViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>

#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAPIInsight.h>

#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

#import "HEMInsightViewController.h"
#import "HEMScrollableView.h"
#import "HEMMarkdown.h"
#import "HEMActivityCoverView.h"

static CGFloat const HEMInsightTitleWithoutImageYOffset = 20.0f;
static CGFloat const HEMInsightMessageYOffset = 24.0f;

@interface HEMInsightViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) SENInsightInfo* info;

@end

@implementation HEMInsightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInfo];
    [SENAnalytics track:kHEMAnalyticsEventInsight];
}

- (void)loadInfo {
    if ([[self insight] isGeneric]) {
        
        [self showContent];
        
    } else {
        
        __block HEMActivityCoverView* activity = [[HEMActivityCoverView alloc] init];
        [activity showInView:[self view] activity:YES completion:^{
            __weak typeof(self) weakSelf = self;
            [SENAPIInsight getInfoForInsight:[self insight] completion:^(SENInsightInfo* info, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf setInfo:info];
                [strongSelf showContent];
                // show the content before we remove the activity
                [activity dismissWithResultText:nil showSuccessMark:NO remove:YES completion:nil];
                
            }];
        }];
        
    }
}

- (NSString*)titleToShow {
    NSString* title = nil;
    if ([[self insight] isGeneric]) {
        title = [[self insight] title];
    } else if ([[[self info] title] length] > 0) {
        title = [[self info] title];
    } else {
        title = NSLocalizedString(@"sleep.insight.info.title.no-text", nil);
    }
    return title;
}

- (NSString*)messageToShow {
    NSString* message = nil;
    if ([[self insight] isGeneric]) {
        message = [[self insight] message];
    } else if ([[[self info] info] length] > 0) {
        message = [[self info] info];
    } else {
        message = NSLocalizedString(@"sleep.insight.info.message.no-text", nil);
    }
    return message;
}

- (void)showContent {
    NSDictionary* messageAttrs = [HEMMarkdown attributesForInsightViewText];
    NSDictionary* titleAttrs = [HEMMarkdown attributesForInsightTitleViewText][@(PARA)];
    NSAttributedString* attrTitle =
        [[NSAttributedString alloc] initWithString:[self titleToShow] attributes:titleAttrs];
    [[self contentView] addAttributedTitle:attrTitle withYOffset:HEMInsightTitleWithoutImageYOffset];
    [[self contentView] addDescription:markdown_to_attr_string([self messageToShow], 0, messageAttrs)
                           withYOffset:HEMInsightMessageYOffset];
    [[self contentView] setNeedsLayout];
}

#pragma mark - Actions

- (IBAction)share:(id)sender {
    UIActivityViewController *activityController =
        [[UIActivityViewController alloc] initWithActivityItems:@[[self messageToShow]] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
