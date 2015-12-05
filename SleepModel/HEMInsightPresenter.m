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

#import "HEMInsightPresenter.h"
#import "HEMInsightsService.h"
#import "HEMMainStoryboard.h"
#import "HEMActivityCoverView.h"
#import "HEMMarkdown.h"
#import "HEMURLImageView.h"
#import "HEMImageCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMRootViewController.h"

typedef NS_ENUM(NSInteger, HEMInsightRow) {
    HEMInsightRowImage = 0,
    HEMInsightRowSummary,
    HEMInsightRowTitle,
    HEMInsightRowDetail,
    HEMINsightRowCount
};

// FIXME: there is an extra pixel here (should be 32.0f), but required or else
// height calculations are wrong and i'm not sure why
static CGFloat const HEMInsightCellSummaryVerticalMargin = 33.0f;
static CGFloat const HEMInsightCellSummaryLeftMargin = 48.0f;
static CGFloat const HEMInsightCellSummaryRightMargin = 24.0f;
static CGFloat const HEMInsightCellTextHorizontalMargin = 24.0f;
static CGFloat const HEMInsightCellHeightImage = 188.0f;
static CGFloat const HEMInsightDetailVerticalMargin = 16.0f;

@interface HEMInsightPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) HEMInsightsService* insightsService;
@property (nonnull, strong) SENInsight* insight;
@property (nonnull, strong) SENInsightInfo* insightDetail;
@property (nonnull, strong) NSError* loadError;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSAttributedString* attributedSummary;
@property (nonatomic, strong) NSAttributedString* attributedTitle;
@property (nonatomic, strong) NSAttributedString* attributedDetail;
@property (nonatomic, weak) UIButton* closeButton;

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

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [self setCollectionView:collectionView];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setDataSource:self];
    [self loadInfo];
}

- (void)bindWithCloseButton:(UIButton*)button {
    [button setBackgroundColor:[UIColor whiteColor]];
    
    NSShadow* shadow = [NSShadow contentShadow];
    CALayer* buttonLayer = [button layer];
    [buttonLayer setShadowColor:[[shadow shadowColor] CGColor]];
    [buttonLayer setShadowOffset:[shadow shadowOffset]];
    [buttonLayer setShadowOpacity:0.0f];
    [buttonLayer setShadowRadius:[shadow shadowBlurRadius]];
    
    [[button titleLabel] setFont:[UIFont insightDismissButtonFont]];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(closeInsight)
     forControlEvents:UIControlEventTouchUpInside];
    [self setCloseButton:button];
}

- (void)updateCloseButtonShadowOpacity {
    CGFloat contentHeight = [[self collectionView] contentSize].height;
    CGFloat scrollHeight = CGRectGetHeight([[self collectionView] bounds]);
    if (contentHeight > scrollHeight) {
        CGFloat yOffset = [[self collectionView] contentOffset].y;
        CGFloat amountDisplayed = contentHeight - yOffset;
        CGFloat percentage = MIN(1.0f, (amountDisplayed / scrollHeight) - 1.0f);
        [[[self closeButton] layer] setShadowOpacity:percentage];
    }
}

- (void)loadInfo {
    __block HEMActivityCoverView* activity = [[HEMActivityCoverView alloc] init];
    [activity showInView:[[self collectionView] superview] activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        [[self insightsService] getInsightForSummary:[self insight] completion:^(SENInsightInfo * _Nullable insight, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setLoadError:error];
            [strongSelf setInsightDetail:insight];
            [[strongSelf collectionView] reloadData];
            [activity dismissWithResultText:nil showSuccessMark:NO remove:YES completion:nil];
        }];
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

- (void)willDisappear {
    [super willDisappear];
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    [rootVC showStatusBar];
}

- (void)didRelayout {
    [super didRelayout];
    
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    itemSize.width = CGRectGetWidth([[self collectionView] bounds]);
    [layout setItemSize:itemSize];
    [[self collectionView] reloadData];
    
    [self updateCloseButtonShadowOpacity];
}

#pragma mark - Collection View

#pragma mark Helpers

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        default:
        case HEMInsightRowImage:
            return [HEMMainStoryboard imageReuseIdentifier];
        case HEMInsightRowSummary:
            return [HEMMainStoryboard summaryReuseIdentifier];
        case HEMInsightRowTitle:
            return [HEMMainStoryboard titleReuseIdentifier];
        case HEMInsightRowDetail:
            return [HEMMainStoryboard detailReuseIdentifier];

    }
}

- (NSAttributedString*)attributedTextForCellAtIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        case HEMInsightRowSummary: {
            if (![self attributedSummary]) {
                NSString* summary = [[[self insight] message] trim];
                if (summary) {
                    NSDictionary* attributes = [HEMMarkdown attributesForInsightSummaryText];
                    [self setAttributedSummary:[markdown_to_attr_string(summary, 0, attributes) trim]];
                }
            }
            return [self attributedSummary];
        }
        case HEMInsightRowTitle: {
            if (![self attributedTitle]) {
                NSString* title = [[[self insightDetail] title] trim];
                if (title) {
                    NSDictionary* attributes = [HEMMarkdown attributesForInsightTitleViewText][@(PARA)];
                    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:title
                                                                             attributes:attributes]];
                }
            }
            return [self attributedTitle];
        }
        case HEMInsightRowDetail: {
            if (![self attributedDetail]) {
                NSString* detail = [[[self insightDetail] info] trim];
                if (detail) {
                    NSDictionary* attributes = [HEMMarkdown attributesForInsightViewText];
                    [self setAttributedDetail:[markdown_to_attr_string(detail, 0, attributes) trim]];
                }
            }
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
        case HEMInsightRowTitle:
        case HEMInsightRowDetail:
            horizontalMargins = HEMInsightCellTextHorizontalMargin * 2;
            break;
        default:
            break;
    }
    return [attrText sizeWithWidth:itemSize.width - horizontalMargins].height;
}

#pragma mark End of helpers

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return HEMINsightRowCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [self reuseIdentifierForIndexPath:indexPath];
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
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
        case HEMInsightRowSummary:
        case HEMInsightRowTitle:
        case HEMInsightRowDetail: {
            HEMTextCollectionViewCell* textCell = (id)cell;
            [textCell setBackgroundColor:[UIColor whiteColor]];
            
            NSAttributedString* attributedText = [self attributedTextForCellAtIndexPath:indexPath];
            if (attributedText) {
                [[textCell textLabel] setAttributedText:attributedText];
            }
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
        case HEMInsightRowSummary: {
            CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
            itemSize.height = textHeight + (HEMInsightCellSummaryVerticalMargin * 2);
            break;
        }
        case HEMInsightRowTitle:
            itemSize.height = [self heightForTextCellAtIndexPath:indexPath];
            break;
        case HEMInsightRowDetail: {
            CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
            itemSize.height = textHeight + (HEMInsightDetailVerticalMargin * 2);
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
}

@end
