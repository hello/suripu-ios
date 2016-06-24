//
//  HEMInsightsFeedPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>

#import <SenseKit/Model.h>
#import "SENRemoteImage+HEMDeviceSpecific.h"
#import "UIActivityViewController+HEMSharing.h"

#import "NSDate+HEMRelative.h"
#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"

#import "HEMInsightsFeedPresenter.h"
#import "HEMStyle.h"
#import "HEMInsightsService.h"
#import "HEMQuestionsService.h"
#import "HEMUnreadAlertService.h"
#import "HEMQuestionCell.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMActivityIndicatorView.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMMarkdown.h"
#import "HEMURLImageView.h"
#import "HEMMainStoryboard.h"
#import "HEMAppUsage.h"
#import "HEMWhatsNewHeaderView.h"
#import "HEMCardFlowLayout.h"
#import "HEMWhatsNewService.h"
#import "HEMActivityCoverView.h"
#import "HEMShareService.h"
#import "HEMShareContentProvider.h"
#import "HEMConfirmationView.h"

static NSString* const HEMInsightsFeedWhatsNewReuseId = @"whatsNew";

static CGFloat const HEMInsightsFeedImageParallaxMultipler = 2.0f;
static NSInteger const HEMInsightsFeedShareUrlCacheLimit = 5;

@interface HEMInsightsFeedPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
>

@property (strong, nonatomic) NSArray* data;
@property (strong, nonatomic) NSArray<SENQuestion*>* questions;
@property (weak, nonatomic) HEMInsightsService* insightsService;
@property (weak, nonatomic) HEMQuestionsService* questionsService;
@property (weak, nonatomic) HEMUnreadAlertService* unreadService;
@property (weak, nonatomic) HEMWhatsNewService* whatsNewService;
@property (weak, nonatomic) HEMShareService* shareService;
@property (weak, nonatomic) UICollectionView* collectionView;
@property (weak, nonatomic) UIView* tutorialContainerView;
@property (weak, nonatomic) UITabBarItem* tabBarItem;
@property (weak, nonatomic) HEMActivityIndicatorView* activityIndicator;
@property (weak, nonatomic) HEMActivityCoverView* shareActivityCover;
@property (strong, nonatomic) NSCache* heightCache;
@property (strong, nonatomic) NSCache* attributedBodyCache;
// imageCache is needed for scroll performance and to reduce image flickering
@property (strong, nonatomic) NSCache* imageCache;
@property (strong, nonatomic) NSError* dataError;
@property (strong, nonatomic) NSCache* shareUrlCache;
@property (assign, nonatomic) CGFloat whatsNewHeaderHeight;

@end

@implementation HEMInsightsFeedPresenter

- (nonnull instancetype)initWithInsightsService:(HEMInsightsService*)insightsService
                               questionsService:(HEMQuestionsService*)questionsService
                                  unreadService:(HEMUnreadAlertService*)unreadService
                                whatsNewService:(HEMWhatsNewService*)whatsNewService
                                   shareService:(HEMShareService*)shareService {
    
    self = [super init];
    if (self) {
        _insightsService = insightsService;
        _questionsService = questionsService;
        _unreadService = unreadService;
        _whatsNewService = whatsNewService;
        _shareService = shareService;
        _heightCache = [NSCache new];
        _attributedBodyCache = [NSCache new];
        _imageCache = [NSCache new];
        _shareUrlCache = [NSCache new];
        
        [_shareUrlCache setCountLimit:HEMInsightsFeedShareUrlCacheLimit];
    }
    return self;
}

- (void)bindWithCollectionView:(nonnull UICollectionView*)collectionView {
    [self setCollectionView:collectionView];
    [[self collectionView] setAlwaysBounceVertical:YES];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setDataSource:self];
}

- (void)bindWithActivityIndicator:(nonnull HEMActivityIndicatorView*)activityIndicator {
    [activityIndicator stop]; // in case it's visible currently
    [self setActivityIndicator:activityIndicator];
}

- (void)bindWithTutorialContainerView:(UIView*)tutorialContainerView {
    [self setTutorialContainerView:tutorialContainerView];
}

- (void)showLoadingActivity:(BOOL)show {
    if (show) {
        if ([[self data] count] == 0) {
            [[self activityIndicator] start];
        }
    } else {
        [[self activityIndicator] stop];
    }
}

- (void)refresh {
    [self setDataError:nil];
    [self showLoadingActivity:YES];
    
    if ([[self data] count] == 0) {
        [[self collectionView] reloadData];
    }
    
    dispatch_group_t dataGroup = dispatch_group_create();
    
    __block NSArray* insightsData = nil;
    __block NSError* insightsError = nil;
    
    dispatch_group_enter(dataGroup);
    [[self insightsService] getListOfInsightSummaries:^(NSArray<SENInsight *> * _Nullable insights, NSError * _Nullable error) {
        if (!error) {
            insightsData = insights;
        } else {
            insightsError = error;
        }
        dispatch_group_leave(dataGroup);
    }];
    
    __block NSArray* questionsData = nil;
    __block NSError* questionsError = nil;
    
    dispatch_group_enter(dataGroup);
    [[self questionsService] refreshQuestions:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
        if (!error) {
            questionsData = questions;
        } else {
            questionsError = error;
        }
        dispatch_group_leave(dataGroup);
    }];
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(dataGroup, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!insightsError && !questionsError) {
            HEMUnreadTypes types = HEMUnreadTypeInsights | HEMUnreadTypeQuestions;
            [[strongSelf unreadService] updateLastViewFor:types completion:^(BOOL hasUnread, NSError *error) {
                if (error) {
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
                }
            }];
            [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageInsightsShownWithData];
        } else if (insightsError && questionsError ) { // if error from both requests
            [strongSelf setDataError:insightsError ?: questionsError];
        }
        
        [strongSelf showLoadingActivity:NO];
        [strongSelf updateViewWith:insightsData questions:questionsData];
    });
}

- (void)updateViewWith:(NSArray<SENInsight*>*)insights
             questions:(NSArray<SENQuestion*>*)questions {
    NSMutableArray* combinedData = [NSMutableArray array];
    
    if ([questions count] > 0) {
        // only show the first question
        [combinedData addObject:[questions firstObject]];
    }
    if ([insights count] > 0) {
        [combinedData addObjectsFromArray:insights];
    }
    
    [self setData:combinedData];
    [self setQuestions:questions];
    [[self collectionView] reloadData];
    
    if ([self onLoadCallback]) {
        [self onLoadCallback] (combinedData);
    }

}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    [self refresh];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self refresh];
}

- (void)didScrollContentIn:(UIScrollView *)scrollView {
    [super didScrollContentIn:scrollView];
    [self updateInsightImageParallax];
}

- (void)lowMemory {
    [super lowMemory];
    [[self imageCache] removeAllObjects];
    [[self heightCache] removeAllObjects];
    [[self attributedBodyCache] removeAllObjects];
}

#pragma mark - UICollectionView

#pragma mark Helpers

- (id)objectAtIndexPath:(NSIndexPath*)indexPath {
    return [indexPath row] >= [[self data] count] ? nil : [self data][[indexPath row]];
}

- (NSString*)dateForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* date = nil;
    
    id dataObj = [self objectAtIndexPath:indexPath];
    
    if ([dataObj isKindOfClass:[SENInsight class]]) {
        SENInsight* insight = (SENInsight*)dataObj;
        date = [[insight dateCreated] elapsed];
    }
    
    return date;
}

- (NSAttributedString*)attributedBodyForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* body = nil;
    id dataObj = [self objectAtIndexPath:indexPath];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        SENQuestion* quest = (SENQuestion*)dataObj;
        body = [[quest text] trim];
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        SENInsight* insight = (SENInsight*)dataObj;
        body = [[insight message] trim];
    }
    
    NSAttributedString* attributedBody = [[self attributedBodyCache] objectForKey:body];
    if (!attributedBody) {
        if ([dataObj isKindOfClass:[SENQuestion class]]) {
            attributedBody = [[NSAttributedString alloc] initWithString:body
                                                             attributes:[self questionTextAttributes]];
        } else if ([dataObj isKindOfClass:[SENInsight class]]) {
            attributedBody = markdown_to_attr_string(body, 0, [HEMMarkdown attributesForInsightSummaryText]);
        }
        
        attributedBody = [attributedBody trim];
        [[self attributedBodyCache] setObject:attributedBody forKey:body];
    }

    return attributedBody;
}

- (NSDictionary*)questionTextAttributes {
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    return  @{NSFontAttributeName : [UIFont feedQuestionFont],
              NSParagraphStyleAttributeName : style};
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withCellWith:(CGFloat)width {
    if ([indexPath row] == 0 && [self dataError]) {
        NSString* text = NSLocalizedString(@"insights.feed.error.message", nil);
        UIFont* font = [UIFont errorStateDescriptionFont];
        CGFloat maxWidth = width - (HEMStyleCardErrorTextHorzMargin * 2);
        CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
        return textHeight + (HEMStyleCardErrorTextVertMargin * 2);
    }
    
    NSAttributedString* attributedBody = [self attributedBodyForCellAtIndexPath:indexPath];
    if ([attributedBody length] == 0) {
        return 0.0f;
    }
    
    NSString* cacheKey = [attributedBody string];
    if ([[self heightCache] objectForKey:cacheKey] != nil) {
        return [[[self heightCache] objectForKey:cacheKey] floatValue];
    }
    
    CGFloat calculatedHeight = 0;
    id dataObj = [self data][[indexPath row]];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        calculatedHeight = [HEMQuestionCell heightForCellWithQuestion:attributedBody cellWidth:width];
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        BOOL shareable = [[self shareService] isShareable:dataObj];
        calculatedHeight = [HEMInsightCollectionViewCell contentHeightWithMessage:attributedBody
                                                                          inWidth:width
                                                                        shareable:shareable];
    }
    
    [[self heightCache] setObject:@(calculatedHeight) forKey:cacheKey];
    return calculatedHeight;
    
}

- (BOOL)isItemShareableAtIndexPath:(NSIndexPath*)indexPath {
    id object = [self objectAtIndexPath:indexPath];
    return [[self shareService] isShareable:object];
}

- (NSString*)insightImageUriForCellAtIndexPath:(NSIndexPath*)indexPath {
    SENInsight* insight = SENObjectOfClass([self objectAtIndexPath:indexPath], [SENInsight class]);
    SENRemoteImage* remoteImage = [insight remoteImage];
    return [remoteImage uriForCurrentDevice];
}

- (NSString*)insightCategoryNameForCellAtIndexPath:(NSIndexPath*)indexPath {
    SENInsight* insight = SENObjectOfClass([self objectAtIndexPath:indexPath], [SENInsight class]);
    return [[insight categoryName] uppercaseString];
}

#pragma mark - End of helpers

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self dataError] ? 1 : [[self data] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = HEMInsightsFeedWhatsNewReuseId;
    HEMWhatsNewHeaderView* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:reuseId
                                                                              forIndexPath:indexPath];
    [[header dismissButton] addTarget:self
                               action:@selector(dismissWhatsNew)
                     forControlEvents:UIControlEventTouchUpInside];
    [header setTitle:[[self whatsNewService] title] andMessage:[[self whatsNewService] message]];
    [[header actionButton] setTitle:[[self whatsNewService] buttonTitle] forState:UIControlStateNormal];
    [[header actionButton] addTarget:self
                              action:@selector(showWhatsNew)
                    forControlEvents:UIControlEventTouchUpInside];
    
    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* reuseId = nil;
    id dataObj = [self objectAtIndexPath:indexPath];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        reuseId = [HEMMainStoryboard questionReuseIdentifier];
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        reuseId = [HEMMainStoryboard insightReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard errorReuseIdentifier];
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeZero;
    if ([[self whatsNewService] shouldShow]) {
        NSString* title = [[self whatsNewService] title];
        NSString* message = [[self whatsNewService] message];
        CGFloat cellWidth = CGRectGetWidth([collectionView bounds]);
        CGFloat height = [HEMWhatsNewHeaderView heightWithTitle:title message:message andMaxWidth:cellWidth];
        headerSize = CGSizeMake(cellWidth, height);
        [self setWhatsNewHeaderHeight:headerSize.height];
    }
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = [layout itemSize];
    itemSize.height = [self heightForCellAtIndexPath:indexPath withCellWith:itemSize.width];
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSAttributedString* attrBody = [self attributedBodyForCellAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMQuestionCell class]]) {
        HEMQuestionCell* qCell = (HEMQuestionCell*)cell;
        [self configureQuestionCell:qCell forIndexPath:indexPath withBody:attrBody];
    } else if ([cell isKindOfClass:[HEMInsightCollectionViewCell class]]) {
        HEMInsightCollectionViewCell* iCell = (id)cell;
        [self configureInsightCell:iCell forIndexPath:indexPath withBody:attrBody];
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) {
        if ([self dataError]) {
            HEMTextCollectionViewCell* textCell = (id)cell;
            [[textCell textLabel] setText:NSLocalizedString(@"insights.feed.error.message", nil)];
            [[textCell textLabel] setFont:[UIFont errorStateDescriptionFont]];
            [textCell displayAsACard:YES];
        }
    }
    
}

- (void)configureQuestionCell:(HEMQuestionCell*)qCell
                 forIndexPath:(NSIndexPath*)indexPath
                     withBody:(NSAttributedString*)body {
    [[qCell questionLabel] setAttributedText:body];
    [[qCell answerButton] addTarget:self action:@selector(answerQuestion:) forControlEvents:UIControlEventTouchUpInside];
    [[qCell skipButton] addTarget:self action:@selector(skipQuestion:) forControlEvents:UIControlEventTouchUpInside];
    [[qCell answerButton] setTag:[indexPath row]];
    [[qCell skipButton] setTag:[indexPath row]];
}

- (void)configureInsightCell:(HEMInsightCollectionViewCell*)iCell
                forIndexPath:(NSIndexPath*)indexPath
                    withBody:(NSAttributedString*)body{
    
    [[iCell messageLabel] setAttributedText:body];
    [[iCell dateLabel] setText:[self dateForCellAtIndexPath:indexPath]];
    
    NSString* url = [self insightImageUriForCellAtIndexPath:indexPath];
    UIImage* cachedImage = nil;
    
    if (url) {
        cachedImage = [[self imageCache] objectForKey:url];
    }
    
    if (cachedImage) {
        [[iCell uriImageView] setImage:cachedImage];
    } else { // even if there's no url, just set it to clear the image
        __weak typeof(self) weakSelf = self;
        [[iCell uriImageView] setImageWithURL:url completion:^(UIImage * image, NSString * url, NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [SENAnalytics trackError:error];
            } else if (image && url) {
                [[strongSelf imageCache] setObject:image forKey:url];
            }
        }];
    }
    
    [[iCell categoryLabel] setText:[self insightCategoryNameForCellAtIndexPath:indexPath]];
    
    [[iCell shareButton] setTitle:[NSLocalizedString(@"actions.share", nil) uppercaseString]
                         forState:UIControlStateNormal];
    [[iCell shareButton] addTarget:self
                            action:@selector(shareInsight:)
                  forControlEvents:UIControlEventTouchUpInside];
    [[iCell shareButton] setTag:[indexPath row]];
    [iCell enableShare:[self isItemShareableAtIndexPath:indexPath]];

    [self updateInsightImageOffsetOn:iCell];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // skip questions as those interactions are handled through button events
    SENInsight* insight = SENObjectOfClass([self objectAtIndexPath:indexPath], [SENInsight class]);
    if (insight) {
        HEMInsightCollectionViewCell* cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
        [[self delegate] presenter:self showInsight:insight fromCell:cell];
    }
}

#pragma mark Scroll delegate (for parallax)

- (void)updateInsightImageOffsetOn:(HEMInsightCollectionViewCell*)insightCell {
    CGFloat imageHeight = CGRectGetHeight([[insightCell uriImageView] bounds]);
    if (imageHeight > 0) {
        CGFloat diff = [[self collectionView] contentOffset].y - CGRectGetMinY([insightCell frame]);
        CGFloat imageOffset = diff / imageHeight;
        imageOffset = imageOffset * HEMInsightsFeedImageParallaxMultipler;
        
        [[insightCell imageTopConstraint] setConstant:imageOffset];
        [[insightCell imageBottomConstraint] setConstant:-imageOffset];
        [[insightCell uriImageView] updateConstraintsIfNeeded];
    } // TODO: else, see if we can send some analytics up to see what the problem is
}

- (void)updateInsightImageParallax {
    for (UICollectionViewCell* cell in [[self collectionView] visibleCells]) {
        if ([cell isKindOfClass:[HEMInsightCollectionViewCell class]]) {
            [self updateInsightImageOffsetOn:(id)cell];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Actions

- (void)shareInsight:(UIButton*)shareButton {
    DDLogVerbose(@"sharing");
    NSInteger row = [shareButton tag];
    NSIndexPath* insightPath = [NSIndexPath indexPathForRow:row inSection:0];
    id object = [self objectAtIndexPath:insightPath];
    if ([object conformsToProtocol:@protocol(SENShareable)]) {
        id<SENShareable> shareable = object;
        
        NSString* shareUrl = [[self shareUrlCache] objectForKey:[shareable identifier]];
        if (shareUrl) {
            [self showShareOptionsWithUrl:shareUrl forType:[object shareType]];
        } else {
            UIView* containerView = [[self delegate] activityContainerViewFor:self];
            HEMActivityCoverView* coverView = [HEMActivityCoverView transparentCoverView];
            [coverView showInView:containerView activity:YES completion:nil];
            [self setShareActivityCover:coverView];
            
            __weak typeof(self) weakSelf = self;
            [[self shareService] shareUrlFor:shareable completion:^(NSString *url, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (url) {
                    [[strongSelf shareUrlCache] setObject:url forKey:[shareable identifier]];
                    [strongSelf showShareOptionsWithUrl:url forType:[shareable shareType]];
                } else {
                    void(^showError)(void) = ^(void){
                        NSString* title = NSLocalizedString(@"share.error.no-link.title", nil);
                        NSString* message = NSLocalizedString(@"share.error.no-link.message", nil);
                        [[strongSelf delegate] presenter:strongSelf
                                          showErrorTitle:title
                                                 message:message];
                    };
                    [[strongSelf shareActivityCover] dismissWithResultText:nil
                                                           showSuccessMark:NO
                                                                    remove:YES
                                                                completion:showError];
                }
            }];
        }

    } else {
        [SENAnalytics trackWarningWithMessage:@"share object is not shareable"];
    }

}

- (void)showShareOptionsWithUrl:(NSString*)url forType:(NSString*)type {
    DDLogVerbose(@"show a share sheet for %@", url);
    [[self shareActivityCover] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
        [self setShareActivityCover:nil];
    }];
    
    UIView* containerView = [[self collectionView] superview];
    UIActivityViewController* shareVC = [UIActivityViewController share:url
                                                                 ofType:type
                                                               fromView:containerView];
    
    [[self delegate] presenter:self showController:shareVC];
}

- (void)showWhatsNew {
    HEMWhatsNewLocation loc = [[self whatsNewService] location];
    switch (loc) {
        case HEMWhatsNewLocationSettings:
            [[self delegate] presenter:self showTab:HEMRootDrawerTabSettings];
            break;
        case HEMWhatsNewLocationNone:
        default:
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    int64_t delay = (int64_t)(1.0f * NSEC_PER_SEC);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf dismissWhatsNew];
    });
}

- (void)dismissWhatsNew {
    [[self whatsNewService] dismiss];
    if ([[self collectionView] numberOfItemsInSection:0] == 0) {
        [[self collectionView] reloadData];
        return;
    }
    
    // since there is no method to delete a section header in an animated fashion,
    // we need to do it ourselves, which basically is to scroll to the first actual
    // item in the list, then quickly update the content offset back to the top
    // and reload the view without the header
    [UIView animateWithDuration:0.5f animations:^{
        NSIndexPath* firstItem = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewCell* firstCell = [[self collectionView] cellForItemAtIndexPath:firstItem];
        if (firstCell) {
            CGPoint offset = CGPointMake(0.0f, [self whatsNewHeaderHeight]);
            [[self collectionView] setContentOffset:offset];
        }
    } completion:^(BOOL finished) {
        [[self collectionView] setContentOffset:CGPointZero];
        [[self collectionView] reloadData];
    }];
}

- (BOOL)removeQuestionFromData:(nonnull SENQuestion*)question {
    NSMutableArray* mutableData = [[self data] mutableCopy];
    NSInteger dataCount = [mutableData count];
    [mutableData removeObject:question];
    [self setData:mutableData];
    
    NSMutableArray* mutableQuestions = [[self questions] mutableCopy];
    [mutableQuestions removeObject:question];
    [self setQuestions:mutableQuestions];
    
    return dataCount > [[self data] count];
}

- (void)removeQuestion:(nonnull SENQuestion*)question atIndexPath:(nonnull NSIndexPath*)indexPath {
    if ([self removeQuestionFromData:question]) {
        [[self collectionView] deleteItemsAtIndexPaths:@[indexPath]];
    }
}

- (void)skipQuestion:(UIButton*)skipButton {
    NSIndexPath* path = [NSIndexPath indexPathForRow:[skipButton tag] inSection:0];
    SENQuestion* question = SENObjectOfClass([self objectAtIndexPath:path], [SENQuestion class]);
    if (question) {
        // optimistically skip the question
        [self removeQuestion:question atIndexPath:path];
        [[self questionsService] skipQuestion:question completion:nil];
    }
}

- (void)answerQuestion:(UIButton*)answerButton {
    [[self delegate] presenter:self showQuestions:[self questions] completion:^{
        NSIndexPath* path = [NSIndexPath indexPathForRow:[answerButton tag] inSection:0];
        SENQuestion* question = SENObjectOfClass([self objectAtIndexPath:path], [SENQuestion class]);
        [self removeQuestion:question atIndexPath:path];
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end
