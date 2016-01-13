//
//  HEMInsightPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>

#import <SenseKit/SENInsight.h>
#import "SENRemoteImage+HEMDeviceSpecific.h"

#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "NSShadow+HEMStyle.h"
#import "UIImage+HEMPixelColor.h"

#import "HEMInsightPresenter.h"
#import "HEMInsightsService.h"
#import "HEMMainStoryboard.h"
#import "HEMMarkdown.h"
#import "HEMURLImageView.h"
#import "HEMImageCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMRootViewController.h"
#import "HEMLoadingCollectionViewCell.h"
#import "HEMActivityIndicatorView.h"

typedef NS_ENUM(NSInteger, HEMInsightRow) {
    HEMInsightRowImage = 0,
    HEMInsightRowTitleOrLoading,
    HEMInsightRowDetail,
    HEMInsightAbout,
    HEMInsightRowSummary,
    HEMInsightRowCount
};

static NSString* const HEMInsightHeaderReuseId = @"header";

static NSInteger const HEMInsightRowCountWhileLoading = 2;
static NSInteger const HEMInsightRowCountForGenerics = 3;

static CGFloat const HEMInsightCellSummaryTopMargin = 20.0f;
static CGFloat const HEMInsightCellSummaryBotMargin = 33.0f;
static CGFloat const HEMInsightCellSummaryLeftMargin = 58.0f; // 48 + 2 for divider + 8 magic iOS 9 pixels from collection view
static CGFloat const HEMInsightCellSummaryRightMargin = 32.0f; // 24 + 8 magic iOS 9 pixels

static CGFloat const HEMInsightCellTitleTopMargin = 32.0f;
static CGFloat const HEMInsightCellTitleBotMargin = 12.0f;

static CGFloat const HEMInsightCellDetailBotMarginForGenerics = 32.0f;

static CGFloat const HEMInsightCellAboutTopMargin = 36.0f;

static CGFloat const HEMInsightCellTextHorizontalMargin = 24.0f;
static CGFloat const HEMInsightCellHeightImage = 178.66f; // keep aspect ratio relatively the same as insight card
static CGFloat const HEMInsightCloseButtonAnimation = 0.5f;
static CGFloat const HEMInsightTextAppearanceAnimation = 0.6f;
static CGFloat const HEMInsightCloseButtonBorderWidth = 0.5f;

@interface HEMInsightPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) HEMInsightsService* insightsService;
@property (nonnull, strong) SENInsight* insight;
@property (nonnull, strong) SENInsightInfo* insightDetail;
@property (nonnull, strong) NSError* loadError;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSAttributedString* attributedSummary;
@property (nonatomic, strong) NSAttributedString* attributedTitle;
@property (nonatomic, strong) NSAttributedString* attributedDetail;
@property (nonatomic, strong) NSAttributedString* attributedAbout;
@property (nonatomic, weak) UIButton* closeButton;
@property (nonatomic, weak) UIImageView* buttonShadow;
@property (nonatomic, weak) NSLayoutConstraint* closeBottomConstraint;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) UIColor* imageColor;

@end

@implementation HEMInsightPresenter

- (instancetype)initWithInsightService:(HEMInsightsService*)insightsService
                            forInsight:(SENInsight*)insight {
    self = [super init];
    if (self) {
        _insightsService = insightsService;
        _insight = insight;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView withImageColor:(UIColor*)imageColor {
    [self setImageColor:imageColor];
    [self setCollectionView:collectionView];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setDataSource:self];
    [self loadInfo];
}

- (void)bindWithCloseButton:(UIButton*)button
           bottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [[button layer] setBorderColor:[[UIColor borderColor] CGColor]];
    [[button layer] setBorderWidth:HEMInsightCloseButtonBorderWidth];
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [[button titleLabel] setFont:[UIFont insightDismissButtonFont]];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(closeInsight)
     forControlEvents:UIControlEventTouchUpInside];
    [self setCloseButton:button];
  
    [bottomConstraint setConstant:-CGRectGetHeight([button bounds])];
    [self setCloseBottomConstraint:bottomConstraint];
}

- (void)bindWithButtonShadow:(UIImageView*)buttonShadow {
    [buttonShadow setAlpha:0.0f];
    [self setButtonShadow:buttonShadow];
}

- (void)updateCloseButtonShadowOpacity {
    CGFloat contentHeight = [[self collectionView] contentSize].height;
    CGFloat scrollHeight = CGRectGetHeight([[self collectionView] bounds]);
    if (contentHeight > scrollHeight) {
        CGFloat yOffset = [[self collectionView] contentOffset].y;
        CGFloat amountDisplayed = contentHeight - yOffset;
        CGFloat percentage = MIN(1.0f, (amountDisplayed / scrollHeight) - 1.0f);
        [[self buttonShadow] setAlpha:percentage];
    }
}

- (void)loadInfo {
    [self setLoading:YES];
    __weak typeof(self) weakSelf = self;
    [[self insightsService] getInsightForSummary:[self insight] completion:^(SENInsightInfo * _Nullable insight, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoading:NO];
        [strongSelf setLoadError:error];
        [strongSelf setInsightDetail:insight];
        [[strongSelf collectionView] reloadData];
        [strongSelf updateCloseButtonShadowOpacity];
    }];
}

#pragma mark - Actions

- (void)closeInsight {
    [[self actionDelegate] closeInsightFromPresenter:self];
}

#pragma mark - Presenter events

- (void)willAppear {
    [super willAppear];
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    [rootVC hideStatusBar];
}

- (void)didAppear {
    [super didAppear];
    
    [[self closeBottomConstraint] setConstant:0.0f];
    [UIView animateWithDuration:HEMInsightCloseButtonAnimation animations:^{
        [[self closeButton] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self updateCloseButtonShadowOpacity];
    }];
    
}

- (void)didDisappear {
    [super didDisappear];
    [[self closeBottomConstraint] setConstant:-CGRectGetHeight([[self closeButton] bounds])];
}

- (void)didRelayout {
    [super didRelayout];
    
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    
    itemSize.width = CGRectGetWidth([[[self collectionView] superview] bounds]);
    [layout setItemSize:itemSize];
    [[self collectionView] reloadData];
}

#pragma mark - Collection View

#pragma mark Helpers

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        default:
        case HEMInsightRowImage:
            return [HEMMainStoryboard imageReuseIdentifier];
        case HEMInsightAbout:
            return [HEMMainStoryboard aboutReuseIdentifier];
        case HEMInsightRowSummary:
            return [HEMMainStoryboard summaryReuseIdentifier];
        case HEMInsightRowTitleOrLoading:
            return [self isLoading] ? [HEMMainStoryboard loadingReuseIdentifier] : [HEMMainStoryboard titleReuseIdentifier];
        case HEMInsightRowDetail:
            return [HEMMainStoryboard detailReuseIdentifier];
            
    }
}

- (NSAttributedString*)attributedAbout {
    if (!_attributedAbout) {
        NSString* about = [NSLocalizedString(@"insight.about", nil) uppercaseString];
        NSDictionary* attributes = @{NSFontAttributeName : [UIFont insightAboutFont],
                                     NSForegroundColorAttributeName : [UIColor insightAboutTextColor]};
        _attributedAbout = [[NSAttributedString alloc] initWithString:about attributes:attributes];
    }
    return _attributedAbout;
}

- (NSAttributedString*)attributedSummary {
    if (!_attributedSummary) {
        NSString* summary = [[[self insight] message] trim];
        if (summary) {
            NSDictionary* attributes = [HEMMarkdown attributesForInsightSummaryText];
            _attributedSummary = [markdown_to_attr_string(summary, 0, attributes) trim];
        }
    }
    return _attributedSummary;
}

- (NSAttributedString*)attributedTitle {
    if (!_attributedTitle) {
        NSString* title = [[[self insightDetail] title] trim];
        if (title) {
            NSDictionary* attributes = [HEMMarkdown attributesForInsightTitleViewText][@(PARA)];
            _attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                               attributes:attributes];
        }
    }
    return _attributedTitle;
}

- (NSAttributedString*)attributedDetail {
    if (!_attributedDetail) {
        NSString* detail = [[[self insightDetail] info] trim];
        if (detail) {
            NSDictionary* attributes = [HEMMarkdown attributesForInsightViewText];
            _attributedDetail = [markdown_to_attr_string(detail, 0, attributes) trim];
        }
    }
    return _attributedDetail;
}

- (NSAttributedString*)attributedTextForCellAtIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        case HEMInsightAbout:
            return [self attributedAbout];
        case HEMInsightRowSummary:
            return [self attributedSummary];
        case HEMInsightRowTitleOrLoading: {
            if ([self isLoading]) {
                return nil;
            }
            return [self attributedTitle];
        }
        case HEMInsightRowDetail: {
            return [self attributedDetail];
        }
        case HEMInsightRowImage:
        default:
            return nil;
            
    }
}

- (CGFloat)heightForTextCellAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    NSAttributedString* attrText = [self attributedTextForCellAtIndexPath:indexPath];
    CGFloat horizontalMargins = 0.0f;
    
    switch ([indexPath row]) {
        case HEMInsightRowSummary:
            horizontalMargins = HEMInsightCellSummaryLeftMargin + HEMInsightCellSummaryRightMargin;
            break;
        case HEMInsightAbout:
        case HEMInsightRowTitleOrLoading: // if it's asking for text, assume is for summary
        case HEMInsightRowDetail:
            horizontalMargins = HEMInsightCellTextHorizontalMargin * 2;
            break;
        default:
            break;
    }

    CGSize textSize = [attrText sizeWithWidth:itemSize.width - horizontalMargins];
    return textSize.height;
}

- (void)setAttributedText:(NSAttributedString*)attributedText
               inTextCell:(HEMTextCollectionViewCell*)cell {
    
    [[cell textLabel] setAttributedText:attributedText];
    
    [UIView animateWithDuration:HEMInsightTextAppearanceAnimation animations:^{
        [[cell textLabel] setAlpha:1.0f];
    }];
    
}

#pragma mark End of helpers

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger count = HEMInsightRowCount;
    if ([self isLoading]) {
        count = HEMInsightRowCountWhileLoading;
    } else if ([[self insightsService] isGenericInsight:[self insight]]) {
        count = HEMInsightRowCountForGenerics;
    }
    return count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [self reuseIdentifierForIndexPath:indexPath];
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView* view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:HEMInsightHeaderReuseId
                                                         forIndexPath:indexPath];
    }
    
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view
        forElementKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath {
    [view setBackgroundColor:[self imageColor]];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case HEMInsightRowImage: {
            HEMImageCollectionViewCell* imageCell = (id)cell;
            SENRemoteImage* remoteImage = [[self insight] remoteImage];
            [[imageCell urlImageView] setBackgroundColor:[UIColor backgroundColorForRemoteImageView]];
            [[imageCell urlImageView] setImageWithURL:[remoteImage uriForCurrentDevice]];
            break;
        }
        case HEMInsightRowTitleOrLoading:
            if ([self isLoading]) {
                HEMLoadingCollectionViewCell* loadingCell = (id)cell;
                [[loadingCell activityIndicator] start];
                break;
            }
        case HEMInsightAbout:
        case HEMInsightRowSummary:
        case HEMInsightRowDetail: {
            HEMTextCollectionViewCell* textCell = (id)cell;
            [textCell setBackgroundColor:[UIColor whiteColor]];
            NSAttributedString* attributedText = [self attributedTextForCellAtIndexPath:indexPath];
            [self setAttributedText:attributedText inTextCell:textCell];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewFlowLayout* layout = (id)[collectionView collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    
    switch ([indexPath row]) {
        case HEMInsightRowImage:
            itemSize.height = HEMInsightCellHeightImage;
            break;
        case HEMInsightAbout: {
            CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
            itemSize.height = textHeight + HEMInsightCellAboutTopMargin;
            break;
        }
        case HEMInsightRowSummary: {
            CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
            itemSize.height = textHeight + HEMInsightCellSummaryTopMargin + HEMInsightCellSummaryBotMargin;
            break;
        }
        case HEMInsightRowTitleOrLoading:
            if ([self isLoading]) {
                itemSize.height = CGRectGetHeight([collectionView bounds]) - HEMInsightCellHeightImage;
            } else {
                CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
                itemSize.height = textHeight + HEMInsightCellTitleTopMargin + HEMInsightCellTitleBotMargin;
            }
            break;
        case HEMInsightRowDetail: {
            itemSize.height = [self heightForTextCellAtIndexPath:indexPath];
            if ([[self insightsService] isGenericInsight:[self insight]]) {
                itemSize.height += HEMInsightCellDetailBotMarginForGenerics;
            }
            break;
        }
        default:
            break;
    }
    
    return itemSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCloseButtonShadowOpacity];
}

#pragma mark - Clean up

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
    
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    [rootVC showStatusBar];
}

@end
