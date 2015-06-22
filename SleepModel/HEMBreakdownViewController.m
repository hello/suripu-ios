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
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBottom;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImage *backgroundImage;
@end

@implementation HEMBreakdownViewController

const CGFloat BreakdownCellItemHeight = 96.f;
const CGFloat BreakdownCellSummaryHeight = 120.f;
const CGFloat BreakdownDismissButtonBottom = 26.f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _backgroundImage = [[HEMRootViewController rootViewControllerForKeyWindow]
                                .view snapshotWithTint:[UIColor colorWithWhite:0 alpha:0.7f]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.valueFormatter = [HEMSplitTextFormatter new];
    self.backgroundImageView.image = self.backgroundImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateBottomButton];
}

- (IBAction)dismissFromView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)animateBottomButton {
    if (self.buttonBottom.constant != BreakdownDismissButtonBottom) {
        self.buttonBottom.constant = BreakdownDismissButtonBottom;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.5f
                              delay:0.05f
             usingSpringWithDamping:0.75f
              initialSpringVelocity:0
                            options:0
                         animations:^{
                           [self.view layoutIfNeeded];
                         }
                         completion:NULL];
    }
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.result.statistics.count > 0 ? 3 : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HEMBreakdownSummaryCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard summaryViewCellReuseIdentifier]
                                                      forIndexPath:indexPath];
        NSDictionary *attrs = [HEMMarkdown attributesForTimelineBreakdownMessage];
        cell.detailLabel.attributedText = [markdown_to_attr_string(self.result.message, 0, attrs) trim];
        return cell;
    } else {
        HEMBreakdownLineCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard breakdownLineCellReuseIdentifier]
                                                      forIndexPath:indexPath];
        cell.itemTitle1.attributedText = [self titleForItemAtIndexPath:indexPath position:0];
        cell.itemTitle2.attributedText = [self titleForItemAtIndexPath:indexPath position:1];
        cell.itemValue1.attributedText = [self valueForItemAtIndexPath:indexPath position:0];
        cell.itemValue2.attributedText = [self valueForItemAtIndexPath:indexPath position:1];
        return cell;
    }
}

- (NSAttributedString *)titleForItemAtIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    SENSleepResultStatistic *stat = [self statisticForIndexPath:indexPath position:position];
    NSString *const statTitleLocalizedFormat = @"sleep-stat.%@";
    if (stat) {
        NSString *format = [NSString stringWithFormat:statTitleLocalizedFormat, stat.name];
        return [[NSAttributedString alloc] initWithString:[NSLocalizedString(format, nil) uppercaseString]
                                               attributes:[HEMMarkdown attributesForTimelineBreakdownTitle][@(PARA)]];
    }
    return nil;
}

- (NSAttributedString *)valueForItemAtIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    SENSleepResultStatistic *stat = [self statisticForIndexPath:indexPath position:position];
    if (stat) {
        if (!stat.value) {
            NSDictionary *attributes =
                [HEMMarkdown attributesForTimelineBreakdownValueWithColor:[UIColor lightGrayColor]][@(PARA)];
            return
                [[NSAttributedString alloc] initWithString:NSLocalizedString(@"empty-data", nil) attributes:attributes];
        }
        NSDictionary *attributes =
            [HEMMarkdown attributesForTimelineBreakdownValueWithColor:[HelloStyleKit idealSensorColor]][@(PARA)];
        return [self.valueFormatter attributedStringForObjectValue:[self splitTextForStatistic:stat]
                                             withDefaultAttributes:attributes];
    }
    return nil;
}

- (SENSleepResultStatistic *)statisticForIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    SENSleepResultStatistic *stat = nil;
    NSUInteger index = ((indexPath.row - 1) * 2) + position;
    if ([self.result.statistics count] > index)
        stat = [self.result statistics][index];
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

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = indexPath.row == 0 ? BreakdownCellSummaryHeight : BreakdownCellItemHeight;
    return CGSizeMake(CGRectGetWidth(self.view.bounds), height);
}

@end

@implementation HEMBreakdownSummaryCell
@end

@implementation HEMBreakdownLineCell
@end
