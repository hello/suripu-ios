//
//  HEMBreakdownViewController.m
//  Sense
//
//  Created by Delisa Mason on 6/15/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import <SenseKit/SenseKit.h>
#import <AttributedMarkdown/markdown_peg.h>

#import "UIColor+HEMStyle.h"
#import "HEMBreakdownViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSplitTextFormatter.h"
#import "NSAttributedString+HEMUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMScreenUtils.h"

@interface HEMBreakdownViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) HEMSplitTextFormatter *valueFormatter;
@property (nonatomic, strong) NSDateFormatter* timestampFormatter;
@property (nonatomic, strong) NSDateFormatter* meridiemFormatter;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *dismissButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, getter=hasLoadedContent) BOOL loadedContent;
@property (nonatomic, assign) BOOL hideStatusBar;
@end

@implementation HEMBreakdownViewController

const CGFloat BreakdownCellItemHeight = 86.f;
const CGFloat BreakdownCellSummaryBaseHeight = 108.f;
const CGFloat BreakdownDismissButtonBottom = 18.f;
const CGFloat BreakdownDismissButtonHide = -40.f;
const CGFloat BreakdownButtonAreaHeight = 80.f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // use same tint as the tutorial dialogs
        UIColor* color = [SenseStyle colorWithGroup:GroupTransparentOverlay property:ThemePropertyBackgroundColor];
        _backgroundImage = [[RootViewController currentRootViewController].view blurredSnapshotWithTint:color];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return [self hideStatusBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSLocale *standardLocale = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
    self.timestampFormatter = [NSDateFormatter new];
    self.timestampFormatter.dateFormat = [SENPreference timeFormat] == SENTimeFormat12Hour
        ? @"h:mm" : @"HH:mm";
    self.timestampFormatter.locale = standardLocale;
    self.meridiemFormatter = [NSDateFormatter new];
    self.meridiemFormatter.dateFormat = @"a";
    self.meridiemFormatter.locale = standardLocale;
    self.valueFormatter = [HEMSplitTextFormatter new];
    self.backgroundImageView.image = self.backgroundImage;
    CGRect windowBounds = HEMKeyWindowBounds();
    self.contentViewTop.constant = floorf(CGRectGetHeight(windowBounds)/2);
    self.contentViewWidth.constant = CGRectGetWidth(windowBounds);
    self.collectionView.alpha = 0;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView applyFillStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self animateExpandContent];
}

- (IBAction)dismissFromView:(id)sender {
    [self animateHideContentWithCompletion:^(BOOL done) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)animateExpandContent {
    [self setHideStatusBar:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    CGFloat height = CGRectGetHeight(HEMKeyWindowBounds()) - BreakdownButtonAreaHeight;
    if (self.contentViewHeight.constant != height || self.collectionView.alpha < 1) {
        [self.dismissButton layoutIfNeeded];
        self.contentViewHeight.constant = height;
        self.contentViewTop.constant = 0.0f;
        self.buttonBottom.constant = BreakdownDismissButtonBottom;
        [self.collectionView setNeedsUpdateConstraints];
        [self.dismissButton setNeedsUpdateConstraints];
        CGFloat damping = 0.75f;
        CGFloat duration = 0.4f * (1 + damping);
        [UIView animateWithDuration:duration
                              delay:0.1f
             usingSpringWithDamping:damping
              initialSpringVelocity:0
                            options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
            self.collectionView.alpha = 1;
            [self.collectionView layoutIfNeeded];
            [self.dismissButton layoutIfNeeded];
            for (UICollectionViewCell* cell in self.collectionView.visibleCells) {
                cell.hidden = NO;
                cell.alpha = 1;
            }
        } completion:^(BOOL finished) {
            self.loadedContent = YES;
            self.collectionView.scrollEnabled = YES;
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
        self.contentViewTop.constant = floorf(CGRectGetHeight(HEMKeyWindowBounds())/2);
        self.buttonBottom.constant = BreakdownDismissButtonHide;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3f animations:^{
            self.collectionView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:completion];
    }];
}

#pragma mark UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.result.metrics.count / 2 + self.result.metrics.count % 2;
        default:
            return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell;
    if (indexPath.section == 0) {
        cell = [self titleCellInCollectionView:collectionView forIndexPath:indexPath];
    } else {
        cell = [self metricCellInCollectionView:collectionView forIndexPath:indexPath];
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
    [cell applyStyle];
    
    NSDictionary* attributes = [HEMBreakdownSummaryCell summaryAttributes];
    cell.detailLabel.attributedText = [markdown_to_attr_string(self.result.message, 0, attributes) trim];
    return cell;
}

- (UICollectionViewCell *)metricCellInCollectionView:(UICollectionView *)collectionView
                                        forIndexPath:(NSIndexPath *)indexPath {
    HEMBreakdownLineCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard breakdownLineCellReuseIdentifier]
                                                  forIndexPath:indexPath];
    [self collectionView:collectionView updateMetricInCell:cell atIndexPath:indexPath inPosition:0];
    [self collectionView:collectionView updateMetricInCell:cell atIndexPath:indexPath inPosition:1];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    updateMetricInCell:(HEMBreakdownLineCell*)cell
           atIndexPath:(NSIndexPath*)indexPath
            inPosition:(NSUInteger)position {
    UILabel* titleLabel = position == 0 ? cell.itemTitle1 : cell.itemTitle2;
    UILabel* valueLabel = position == 0 ? cell.itemValue1 : cell.itemValue2;
    titleLabel.attributedText = [self titleForItemAtIndexPath:indexPath position:position];
    valueLabel.attributedText = [self valueForItemAtIndexPath:indexPath position:position];
}

- (NSAttributedString *)titleForItemAtIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    NSString *const metricTitleLocalizedFormat = @"sleep-stat.%@";
    NSString *rawTitle = nil;
    if (indexPath.section == 1) {
        SENTimelineMetric *metric = [self metricForIndexPath:indexPath position:position];
        if (metric) {
            NSString *format = [NSString stringWithFormat:metricTitleLocalizedFormat, metric.name];
            rawTitle = NSLocalizedString(format, nil);
        }
    }
    if (rawTitle) {
        return [[NSAttributedString alloc] initWithString:[rawTitle uppercaseString]
                                               attributes:[HEMBreakdownLineCell titleAttributes]];
    }
    return nil;
}

- (NSAttributedString *)valueForItemAtIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    if (indexPath.section == 1) {
        SENTimelineMetric *metric = [self metricForIndexPath:indexPath position:position];
        if (metric)
            return [self valueTextWithValue:[self splitTextForMetric:metric]
                                  condition:metric.condition];
    }
    return nil;
}

- (NSAttributedString *)valueTextWithValue:(HEMSplitTextObject *)value condition:(SENCondition)condition {
    if (!value) {
        NSDictionary *attributes = [HEMBreakdownLineCell valueAttributesWithCondition:SENConditionUnknown];
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"empty-data", nil) attributes:attributes];
    }
    NSDictionary *attributes = [HEMBreakdownLineCell valueAttributesWithCondition:condition];
    return [self.valueFormatter attributedStringForObjectValue:value withDefaultAttributes:attributes];
}

- (SENTimelineMetric *)metricForIndexPath:(NSIndexPath *)indexPath position:(NSUInteger)position {
    SENTimelineMetric *metric = nil;
    NSUInteger index = (indexPath.row * 2) + position;
    if ([self.result.metrics count] > index)
        metric = [self.result metrics][index];
    return metric;
}

- (HEMSplitTextObject *)splitTextForMetric:(SENTimelineMetric *)metric {
    NSString *value = nil, *unit = nil;
    switch (metric.unit) {
        case SENTimelineMetricUnitCondition:
            value = [self conditionTextForMetric:metric];
            break;
        case SENTimelineMetricUnitMinute: {
            if (metric.value) {
                CGFloat minutes = [metric.value floatValue];
                if (minutes < 60) {
                    NSString *format = NSLocalizedString(@"sleep-stat.minute.format", nil);
                    value = [NSString stringWithFormat:format, minutes];
                    unit = NSLocalizedString(@"sleep-stat.minute.unit", nil);
                } else {
                    NSString *format = NSLocalizedString(@"sleep-stat.hour.format", nil);
                    value = [NSString stringWithFormat:format, minutes / 60];
                    unit = NSLocalizedString(@"sleep-stat.hour.unit", nil);
                }
            }
            break;
        }
        case SENTimelineMetricUnitTimestamp: {
            NSDate* date = SENDateFromNumber(metric.value);
            if (date) {
                value = [self.timestampFormatter stringFromDate:date];
                if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
                    unit = [[self.meridiemFormatter stringFromDate:date] lowercaseString];
                }
            }
            break;
        }
        case SENTimelineMetricUnitQuantity:
        case SENTimelineMetricUnitUnknown:
            if (metric.value) {
                value = [NSString stringWithFormat:@"%d", [metric.value integerValue]];
            }
            break;
        default:
            break;
    }

    return value ? [[HEMSplitTextObject alloc] initWithValue:value unit:unit] : nil;
}

- (NSString *)conditionTextForMetric:(SENTimelineMetric *)metric {
    NSString* format = @"sleep-stat.%@.condition.%@";
    NSString* name = [[metric name] lowercaseString];
    NSString* condition = nil;

    switch ([metric condition]) {
        case SENConditionAlert:
            condition = @"alert";
            break;
        case SENConditionWarning:
            condition = @"warning";
            break;
        case SENConditionIdeal:
            condition = @"ideal";
            break;
        case SENConditionUnknown:
        case SENConditionIncomplete:
        default:
            condition = @"unknown";
    }

    NSString* key = [NSString stringWithFormat:format, name, condition];
    return NSLocalizedString(key, nil);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0) {
        CGFloat const BreakdownSummaryHInset = 40.f;
        CGRect windowBounds = HEMKeyWindowBounds();
        NSDictionary *attrs = [HEMBreakdownSummaryCell summaryAttributes];
        NSAttributedString *text = [markdown_to_attr_string(self.result.message, 0, attrs) trim];
        height = [text sizeWithWidth:CGRectGetWidth(windowBounds) - BreakdownSummaryHInset].height
                 + BreakdownCellSummaryBaseHeight;
    } else {
        height = BreakdownCellItemHeight;
    }
    return CGSizeMake(CGRectGetWidth(self.view.bounds), height);
}

@end

@implementation HEMBreakdownSummaryCell

+ (NSDictionary*)summaryAttributes {
    UIFont* font = [SenseStyle fontWithAClass:self property:ThemePropertyTextFont];
    UIColor* textColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextColor];
    UIColor* boldColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextHighlightedColor];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle senseStyle];
    style.alignment = NSTextAlignmentLeft;
    return @{@(PLAIN) : @{ NSFontAttributeName : font,
                           NSForegroundColorAttributeName : textColor,
                           NSParagraphStyleAttributeName : style},
             @(PARA) : @{ NSFontAttributeName : font,
                          NSForegroundColorAttributeName : textColor,
                          NSParagraphStyleAttributeName : style},
             @(EMPH) : @{NSFontAttributeName : font,
                         NSForegroundColorAttributeName : boldColor,
                         NSParagraphStyleAttributeName : style},
             @(STRONG) : @{NSFontAttributeName : font,
                           NSForegroundColorAttributeName : boldColor,
                           NSParagraphStyleAttributeName : style}};
}

- (void)applyStyle {
    self.titleLabel.font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    self.titleLabel.textColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
}

@end

@implementation HEMBreakdownLineCell

+ (NSDictionary*)titleAttributes {
    UIColor* color = [SenseStyle colorWithAClass:self property:ThemePropertyTitleColor];
    UIFont* font = [SenseStyle fontWithAClass:self property:ThemePropertyTitleFont];
    return @{ NSFontAttributeName : font,
              NSForegroundColorAttributeName : color,
              NSKernAttributeName : @1 };
}

+ (NSDictionary*)valueAttributesWithCondition:(SENCondition)condition {
    UIColor* color = [SenseStyle colorWithCondition:condition defaultColor:nil];
    UIFont* font = [SenseStyle fontWithAClass:self property:ThemePropertyTextFont];
    return @{ NSFontAttributeName : font, NSForegroundColorAttributeName : color };
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.verticalBorder applySeparatorStyle];
    [self.horizontalBorder applySeparatorStyle];
}

@end
