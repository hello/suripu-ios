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

#import "NSDate+HEMRelative.h"
#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMInsightsFeedPresenter.h"
#import "HEMInsightsService.h"
#import "HEMQuestionsService.h"
#import "HEMUnreadAlertService.h"
#import "HEMQuestionCell.h"
#import "HEMInsightCollectionViewCell.h"
#import "HelloStyleKit.h"
#import "HEMActivityIndicatorView.h"
#import "HEMMarkdown.h"
#import "HEMURLImageView.h"

static NSString* const HEMInsightsFeedReuseIdQuestion = @"question";
static NSString* const HEMInsightsFeedReuseIdInsight = @"insight";

@interface HEMInsightsFeedPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray* data;
@property (strong, nonatomic) NSArray<SENQuestion*>* questions;
@property (weak, nonatomic) HEMInsightsService* insightsService;
@property (weak, nonatomic) HEMQuestionsService* questionsService;
@property (weak, nonatomic) HEMUnreadAlertService* unreadService;
@property (weak, nonatomic) UICollectionView* collectionView;
@property (weak, nonatomic) UITabBarItem* tabBarItem;
@property (weak, nonatomic) HEMActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) NSCache* heightCache;
@property (strong, nonatomic) NSCache* attributedBodyCache;

@end

@implementation HEMInsightsFeedPresenter

- (nonnull instancetype)initWithInsightsService:(nonnull HEMInsightsService*)insightsService
                               questionsService:(nonnull HEMQuestionsService*)questionsService
                                  unreadService:(nonnull HEMUnreadAlertService*)unreadService {
    
    self = [super init];
    if (self) {
        _insightsService = insightsService;
        _questionsService = questionsService;
        _unreadService = unreadService;
        _heightCache = [NSCache new];
        _attributedBodyCache = [NSCache new];
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
    [self showLoadingActivity:YES];
    
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
        
        [strongSelf showLoadingActivity:NO];
        [strongSelf updateViewWith:insightsData questions:questionsData];
        
        if (!insightsError && !questionsError) {
            HEMUnreadTypes types = HEMUnreadTypeInsights | HEMUnreadTypeQuestions;
            [[strongSelf unreadService] updateLastViewFor:types completion:^(BOOL hasUnread, NSError *error) {
                if (error) {
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
                }
            }];
        }
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
        date = [[[insight dateCreated] elapsed] uppercaseString];
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
        calculatedHeight = [HEMInsightCollectionViewCell contentHeightWithMessage:attributedBody inWidth:width];
    }
    
    [[self heightCache] setObject:@(calculatedHeight) forKey:cacheKey];
    return calculatedHeight;
    
}

- (NSString*)insightImageUriForCellAtIndexPath:(NSIndexPath*)indexPath {
    SENInsight* insight = SENObjectOfClass([self objectAtIndexPath:indexPath], [SENInsight class]);
    SENRemoteImage* remoteImage = [insight remoteImage];
    return [remoteImage uriForCurrentDevice];
}

- (NSString*)insightCategoryNameForCellAtIndexPath:(NSIndexPath*)indexPath {
    SENInsight* insight = SENObjectOfClass([self objectAtIndexPath:indexPath], [SENInsight class]);
    return [insight category];
}

#pragma mark - End of helpers

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[self data] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* reuseId = nil;
    id dataObj = [self objectAtIndexPath:indexPath];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        reuseId = HEMInsightsFeedReuseIdQuestion;
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        reuseId = HEMInsightsFeedReuseIdInsight;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    
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
        [[qCell questionLabel] setAttributedText:attrBody];
        [[qCell answerButton] addTarget:self action:@selector(answerQuestion:) forControlEvents:UIControlEventTouchUpInside];
        [[qCell skipButton] addTarget:self action:@selector(skipQuestion:) forControlEvents:UIControlEventTouchUpInside];
        [[qCell answerButton] setTag:[indexPath row]];
        [[qCell skipButton] setTag:[indexPath row]];
    } else if ([cell isKindOfClass:[HEMInsightCollectionViewCell class]]) {
        HEMInsightCollectionViewCell* iCell = (id)cell;
        [[iCell messageLabel] setAttributedText:attrBody];
        [[iCell dateLabel] setText:[self dateForCellAtIndexPath:indexPath]];
        [[iCell uriImageView] setImageWithURL:[self insightImageUriForCellAtIndexPath:indexPath]];
        [[iCell categoryLabel] setText:[self insightCategoryNameForCellAtIndexPath:indexPath]];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // skip questions as those interactions are handled through button events
    SENInsight* insight = SENObjectOfClass([self objectAtIndexPath:indexPath], [SENInsight class]);
    if (insight) {
        [[self delegate] presenter:self showInsight:insight];
    }
}

#pragma mark - Actions

- (void)removeQuestionFromData:(nonnull SENQuestion*)question {
    NSMutableArray* mutableData = [[self data] mutableCopy];
    [mutableData removeObject:question];
    [self setData:mutableData];
    
    NSMutableArray* mutableQuestions = [[self questions] mutableCopy];
    [mutableQuestions removeObject:question];
    [self setQuestions:mutableQuestions];
}

- (void)removeQuestion:(nonnull SENQuestion*)question atIndexPath:(nonnull NSIndexPath*)indexPath {
    [[self collectionView] performBatchUpdates:^{
        [self removeQuestionFromData:question];
        [[self collectionView] deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [[self collectionView] reloadData];
    }];
}

- (void)skipQuestion:(UIButton*)skipButton {
    NSIndexPath* path = [NSIndexPath indexPathForRow:[skipButton tag] inSection:0];
    SENQuestion* question = SENObjectOfClass([self objectAtIndexPath:path], [SENQuestion class]);
    if (question) {
        // optimistically skip the question
        [self removeQuestion:question atIndexPath:path];
        
        __weak typeof(self) weakSelf = self;
        [[self questionsService] skipQuestion:question completion:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (!error) {
                [strongSelf setQuestions:questions];
                if ([questions count] > 0) {
                    NSMutableArray* mutableData = [[strongSelf data] mutableCopy];
                    [mutableData insertObject:questions[0] atIndex:0];
                    [strongSelf setData:mutableData];
                    [[strongSelf collectionView] reloadData];
                }
            }

        }];
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
