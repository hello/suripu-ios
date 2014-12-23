//
//  HEMInsightViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>

#import <SenseKit/SENInsight.h>

#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

#import "HEMInsightViewController.h"
#import "HEMScrollableView.h"
#import "HEMMarkdown.h"

static CGFloat const HEMInsightTitleWithoutImageYOffset = 70.0f;

@interface HEMInsightViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation HEMInsightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureContent];
}

- (void)configureContent {
    NSAttributedString* title =
        [[NSAttributedString alloc] initWithString:[[[self insight] title] uppercaseString]
                                        attributes:[HEMMarkdown attributesForInsightTitleViewText][@(PARA)]];

    NSDictionary* attributes = [HEMMarkdown attributesForInsightViewText];
    NSAttributedString* message = markdown_to_attr_string([[self insight] message], 0, attributes);

    [[self contentView] addAttributedTitle:title withYOffset:HEMInsightTitleWithoutImageYOffset];
    [[self contentView] addDescription:message];
}

#pragma mark - Actions

- (IBAction)share:(id)sender {
    UIActivityViewController *activityController =
        [[UIActivityViewController alloc] initWithActivityItems:@[[[self insight] message]] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
