//
//  HEMBreakdownViewController.m
//  Sense
//
//  Created by Delisa Mason on 6/15/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SenseKit.h>
#import <AttributedMarkdown/markdown_peg.h>

#import "HelloStyleKit.h"
#import "HEMBreakdownViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMMarkdown.h"
#import "HEMRootViewController.h"
#import "HEMSplitTextFormatter.h"
#import "NSAttributedString+HEMUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

@interface HEMBreakdownViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) HEMSplitTextFormatter *valueFormatter;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *dismissButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, getter=hasLoadedContent) BOOL loadedContent;
@end

@implementation HEMBreakdownViewController

const CGFloat BreakdownCellItemHeight = 116.f;
const CGFloat BreakdownCellSummaryBaseHeight = 90.f;
const CGFloat BreakdownDismissButtonBottom = 18.f;
const CGFloat BreakdownDismissButtonHide = -40.f;
const CGFloat BreakdownButtonAreaHeight = 80.f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // use same tint as the tutorial dialogs
        _backgroundImage = [[HEMRootViewController rootViewControllerForKeyWindow]
                                .view blurredSnapshotWithTint:[HelloStyleKit tutorialBackgroundColor]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.valueFormatter = [HEMSplitTextFormatter new];
    self.backgroundImageView.image = self.backgroundImage;
    self.contentViewTop.constant = floorf(CGRectGetHeight([[UIScreen mainScreen] bounds])/2);
    self.contentViewWidth.constant = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    self.collectionView.alpha = 0;
    self.collectionView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self animateExpandContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (IBAction)dismissFromView:(id)sender {
    [self animateHideContentWithCompletion:^(BOOL done) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)animateExpandContent {
    CGFloat height = CGRectGetHeight([[UIScreen mainScreen] bounds]) - BreakdownButtonAreaHeight;
    if (self.contentViewHeight.constant != height || self.collectionView.alpha < 1) {
        [self.dismissButton layoutIfNeeded];
        self.contentViewHeight.constant = height;
        self.contentViewTop.constant = 0;
        self.buttonBottom.constant = BreakdownDismissButtonBottom;
        [self.collectionView setNeedsUpdateConstraints];
        [self.dismissButton setNeedsUpdateConstraints];
        CGFloat damping = 0.75f;
        CGFloat duration = 0.4f * (1 + damping);
        [UIView animateWithDuration:duration delay:0.1f usingSpringWithDamping:damping initialSpringVelocity:0 options:0 animations:^{
            self.collectionView.alpha = 1;
            [self.collectionView layoutIfNeeded];
            [self.dismissButton layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.loadedContent = YES;
            self.collectionView.scrollEnabled = YES;
            [UIView animateWithDuration:0.2f animations:^{
                for (UICollectionViewCell* cell in self.collectionView.visibleCells) {
                    cell.hidden = NO;
                    cell.alpha = 1;
                }
            } completion:NULL];
        }];
    }
}

- (void)animateHideContentWithCompletion:(void(^)(BOOL))completion {
    [UIView animateWithDuration:0.2f animations:^{
        for (UICollectionViewCell* cell in self.collectionView.visibleCells) {
            cell.alpha = 0;
        }
    } completion:^(BOOL done) {
        self.contentViewHeight.constant = 0;
        self.contentViewTop.constant = floorf(CGRectGetHeight([[UIScreen mainScreen] bounds])/2);
        self.buttonBottom.constant = 0.3f;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3f animations:^{
            self.collectionView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:completion];
    }];
}

#pragma mark UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.result.statistics.count / 2 + self.result.statistics.count % 2;

        case 2:
            return self.result.sensorInsights.count / 2 + self.result.sensorInsights.count % 2;
        default:
            return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell;
    switch (indexPath.section) {
        case 0:
            cell = [self titleCellInCollectionView:collectionView forIndexPath:indexPath];
            break;

        default:
            cell = [self statCellInCollectionView:collectionView forIndexPath:indexPath];
    }
    if (![self hasLoadedContent]) {
        cell.alpha = 0;
        cell.hidden = YES;
    }
    return cell;
}

- (UICollectionViewCell *)titleCellInCollectionView:(UICollectionView *)collectionView
                                       forIndexPath:(NSIndexPath *)indexPath {
    HEMBreakdownSummaryCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard summaryViewCellReuseIdentifier]
                                                  forIndexPath:indexPath];
    NSDictionary *attrs = [HEMMarkdown attributesForTimelineBreakdownMessage];
    cell.detailLabel.attributedText = [markdown_to_attr_string(self.result.message, 0, attrs) trim];
    return cell;
}

- (UICollectionViewCell *)statCellInCollectionView:(UICollectionView *)collectionView
                                      forIndexPath:(NSIndexPath *)indexPath {
    HEMBreakdownLineCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard breakdownLineCellReuseIdentifier]
                                                  forIndexPath:indexPath];
    cell.itemTitle1.attributedText = [self titleForItemAtIndexPath:indexPath position:0];
    cell.itemTitle2.attributedText = [self titleForItemAtIndexPath:indexPath position:1];
    cell.itemValue1.attributedText = [self valueForItemAtIndexPath:indexPath position:0];
    cell.itemValue2.attributedText = [self valueForItemAtIndexPath:indexPath position:1];
    return cell;
}

- (NSAttributedString *)titleForItemAtIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    NSString *const statTitleLocalizedFormat = @"sleep-stat.%@";
    NSString *rawTitle = nil;
    switch (indexPath.section) {
        case 1: {
            SENSleepResultStatistic *stat = [self statisticForIndexPath:indexPath position:position];
            if (stat) {
                NSString *format = [NSString stringWithFormat:statTitleLocalizedFormat, stat.name];
                rawTitle = NSLocalizedString(format, nil);
            }
            break;
        }

        case 2: {
            SENSleepResultSensorInsight *stat = [self insightForIndexPath:indexPath position:position];
            if (stat) {
                NSString *const sensorKeyFormat = @"sensor.%@";
                NSString *sensorKey = [NSString stringWithFormat:sensorKeyFormat, stat.name];
                NSString *name = NSLocalizedString(sensorKey, nil);
                if ([name isEqualToString:sensorKey]) {
                    name = stat.name;
                }
                rawTitle = name;
            }
        }
        default:
            break;
    }
    if (rawTitle) {
        return [[NSAttributedString alloc] initWithString:[rawTitle uppercaseString]
                                               attributes:[HEMMarkdown attributesForTimelineBreakdownTitle][@(PARA)]];
    }
    return nil;
}

- (NSAttributedString *)valueForItemAtIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    switch (indexPath.section) {
        case 1: {
            SENSleepResultStatistic *stat = [self statisticForIndexPath:indexPath position:position];
            return [self valueTextWithValue:[self splitTextForStatistic:stat] condition:SENSensorConditionIdeal];
        }
        case 2: {
            SENSleepResultSensorInsight *stat = [self insightForIndexPath:indexPath position:position];
            if (stat) {
                return [self valueTextWithValue:[self splitTextForInsight:stat] condition:stat.condition];
            }
        }
        default:
            return nil;
    }
}

- (NSAttributedString *)valueTextWithValue:(HEMSplitTextObject *)value condition:(SENSensorCondition)condition {
    if (!value) {
        NSDictionary *attributes =
            [HEMMarkdown attributesForTimelineBreakdownValueWithColor:
                             [UIColor colorForSensorWithCondition:SENSensorConditionUnknown]][@(PARA)];
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"empty-data", nil) attributes:attributes];
    }
    NSDictionary *attributes = [HEMMarkdown
        attributesForTimelineBreakdownValueWithColor:[UIColor colorForSensorWithCondition:condition]][@(PARA)];
    return [self.valueFormatter attributedStringForObjectValue:value withDefaultAttributes:attributes];
}

- (SENSleepResultStatistic *)statisticForIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    SENSleepResultStatistic *stat = nil;
    NSUInteger index = (indexPath.row * 2) + position;
    if ([self.result.statistics count] > index)
        stat = [self.result statistics][index];
    return stat;
}

- (SENSleepResultSensorInsight *)insightForIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    SENSleepResultSensorInsight *stat = nil;
    NSUInteger index = (indexPath.row * 2) + position;
    if ([self.result.sensorInsights count] > index)
        stat = [self.result sensorInsights][index];
    return stat;
}

- (HEMSplitTextObject *)splitTextForStatistic:(SENSleepResultStatistic *)stat {
    NSString *const timesAwakeKey = @"times_awake";
    CGFloat minutes = [stat.value floatValue];
    NSString *value, *unit;
    if ([stat.name isEqualToString:timesAwakeKey]) {
        unit = nil;
        value = [NSString stringWithFormat:@"%d", [stat.value integerValue]];
    } else if (minutes < 60) {
        NSString *format = NSLocalizedString(@"sleep-stat.minute.format", nil);
        value = [NSString stringWithFormat:format, minutes];
        unit = NSLocalizedString(@"sleep-stat.minute.unit", nil);
    } else {
        NSString *format = NSLocalizedString(@"sleep-stat.hour.format", nil);
        value = [NSString stringWithFormat:format, minutes / 60];
        unit = NSLocalizedString(@"sleep-stat.hour.unit", nil);
    }
    return [[HEMSplitTextObject alloc] initWithValue:value unit:unit];
}

- (HEMSplitTextObject *)splitTextForInsight:(SENSleepResultSensorInsight *)stat {
    return [[HEMSplitTextObject alloc] initWithValue:[self valueTextForInsight:stat] unit:nil];
}

- (NSString *)valueTextForInsight:(SENSleepResultSensorInsight *)insight {
    switch (insight.condition) {
        case SENSensorConditionUnknown:
            return NSLocalizedString(@"empty-data", nil);
        case SENSensorConditionAlert:
            return NSLocalizedString(@"sleep-stat.condition.alert", nil);
        case SENSensorConditionWarning:
            return NSLocalizedString(@"sleep-stat.condition.warning", nil);
        case SENSensorConditionIdeal:
            return NSLocalizedString(@"sleep-stat.condition.ideal", nil);
        default:
            return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0) {
        CGFloat const BreakdownSummaryHInset = 40.f;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        NSDictionary *attrs = [HEMMarkdown attributesForTimelineBreakdownMessage];
        NSAttributedString *text = [markdown_to_attr_string(self.result.message, 0, attrs) trim];
        height = [text sizeWithWidth:CGRectGetWidth(screenBounds) - BreakdownSummaryHInset].height
                 + BreakdownCellSummaryBaseHeight;
    } else {
        height = BreakdownCellItemHeight;
    }
    return CGSizeMake(CGRectGetWidth(self.view.bounds), height);
}

@end

@implementation HEMBreakdownSummaryCell
@end

@implementation HEMBreakdownLineCell
@end
