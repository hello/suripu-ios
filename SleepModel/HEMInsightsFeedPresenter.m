//
//  HEMInsightsFeedPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENQuestion.h>
#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAppUnreadStats.h>

#import "NSDate+HEMRelative.h"
#import "NSString+HEMUtils.h"

#import "HEMInsightsFeedPresenter.h"
#import "HEMInsightsService.h"
#import "HEMQuestionsService.h"
#import "HEMUnreadAlertService.h"
#import "HEMQuestionCell.h"
#import "HEMInsightCollectionViewCell.h"
#import "HelloStyleKit.h"

static NSString* const HEMInsightsFeedReuseIdQuestion = @"question";
static NSString* const HEMInsightsFeedReuseIdInsight = @"insight";

@interface HEMInsightsFeedPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray* data;
@property (strong, nonatomic) NSArray<SENQuestion*>* questions;
@property (assign, nonatomic, getter=isLoading) BOOL loading;
@property (weak, nonatomic) HEMInsightsService* insightsService;
@property (weak, nonatomic) HEMQuestionsService* questionsService;
@property (weak, nonatomic) HEMUnreadAlertService* unreadService;
@property (weak, nonatomic) UICollectionView* collectionView;
@property (weak, nonatomic) UITabBarItem* tabBarItem;
@property (strong, nonatomic) NSCache* heightCache;

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
    }
    return self;
}

- (void)bindWithCollectionView:(nonnull UICollectionView*)collectionView {
    [self setCollectionView:collectionView];
    [[self collectionView] setAlwaysBounceVertical:YES];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setDataSource:self];
}

- (void)bindWithTabBarItem:(nonnull UITabBarItem*)tabBarItem {
    tabBarItem.title = NSLocalizedString(@"insights.title", nil);
    tabBarItem.image = [HelloStyleKit senseBarIcon];
    tabBarItem.selectedImage = [UIImage imageNamed:@"senseBarIconActive"];
    [self setTabBarItem:tabBarItem];
}

- (void)updateTabBarItemUnreadIndicator {
    if ([self tabBarItem]) {
        SENAppUnreadStats* unreadStats = [[self unreadService] unreadStats];
        BOOL hasUnread = [unreadStats hasUnreadInsights] || [unreadStats hasUnreadQuestions];
        [[self tabBarItem] setBadgeValue:hasUnread ? @"1" : nil];
    }
}

- (void)refresh {
    [self setLoading:YES];

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
        
        NSMutableArray* combinedData = [NSMutableArray array];
        
        if ([questionsData count] > 0) {
            // only show the first question
            [combinedData addObject:[questionsData firstObject]];
        }
        if ([insightsData count] > 0) {
            [combinedData addObjectsFromArray:insightsData];
        }
        
        [weakSelf setData:combinedData];
        [weakSelf setQuestions:questionsData];
        
        // TODO: show something if there is an error
        [[weakSelf collectionView] reloadData];
        
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

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    [self refresh];
}

- (void)didDisappear {
    [super didDisappear];
    [self updateTabBarItemUnreadIndicator];
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

- (SENInsight*)insightAtIndexPath:(NSIndexPath*)indexPath {
    id dataObj = [self objectAtIndexPath:indexPath];
    return [dataObj isKindOfClass:[SENInsight class]] ? dataObj : nil;
}

- (SENQuestion*)questionAtIndexPath:(NSIndexPath*)indexPath {
    id dataObj = [self objectAtIndexPath:indexPath];
    return [dataObj isKindOfClass:[SENQuestion class]] ? dataObj : nil;
}

- (CGFloat)bodyTextPaddingForCellAtIndexPath:(NSIndexPath*)indexPath {
    CGFloat padding = 0.0f;
    id dataObj = [self objectAtIndexPath:indexPath];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        padding = HEMQuestionCellTextPadding;
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        padding = HEMInsightCellMessagePadding;
    }
    
    return padding;
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

- (NSString*)insightTitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* title = nil;
    id dataObj = [self objectAtIndexPath:indexPath];;
    
    if ([dataObj isKindOfClass:[SENInsight class]]) {
        SENInsight* insight = (SENInsight*)dataObj;
        title = [[insight title] uppercaseString];
    }
    
    return title;
}

- (NSString*)bodyTextForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* body = nil;
    id dataObj = [self objectAtIndexPath:indexPath];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        SENQuestion* quest = (SENQuestion*)dataObj;
        body = [quest text];
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        SENInsight* insight = (SENInsight*)dataObj;
        body = [insight message];
    }
    
    return body;
}

- (NSString*)infoPreviewTextForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* preview = nil;
    id dataObj = [self objectAtIndexPath:indexPath];
    
    if ([dataObj isKindOfClass:[SENInsight class]]) {
        SENInsight* insight = (SENInsight*)dataObj;
        preview = [insight infoPreview];
        if ([preview length] == 0 && [insight isGeneric]) {
            preview = [insight title];
        }
    }
    
    return preview;
}

- (NSString*)keyForHeightCachedForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* body = [self bodyTextForCellAtIndexPath:indexPath];
    NSString* preview = [self infoPreviewTextForCellAtIndexPath:indexPath];
    NSString* key = body;
    
    if (preview) {
        key = [body stringByAppendingString:preview];
    }
    
    return key;
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width {
    NSString* body = [self bodyTextForCellAtIndexPath:indexPath];
    if ([body length] == 0) {
        return 0.0f;
    }
    
    NSString* cacheKey = [self keyForHeightCachedForCellAtIndexPath:indexPath];
    if ([[self heightCache] objectForKey:cacheKey] != nil) {
        return [[[self heightCache] objectForKey:cacheKey] floatValue];
    }
    
    CGFloat calculatedHeight = 0;
    id dataObj = [self data][[indexPath row]];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        CGFloat textHeight = [body heightBoundedByWidth:width attributes:[HEMQuestionCell questionTextAttributes]];
        calculatedHeight = textHeight + HEMQuestionCellBaseHeight;
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        NSString* preview = [self infoPreviewTextForCellAtIndexPath:indexPath];
        calculatedHeight = [HEMInsightCollectionViewCell contentHeightWithMessage:body
                                                                      infoPreview:preview
                                                                          inWidth:width];
    }
    
    [[self heightCache] setObject:@(calculatedHeight) forKey:cacheKey];
    return calculatedHeight;
    
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
    CGFloat textPadding = [self bodyTextPaddingForCellAtIndexPath:indexPath];
    itemSize.height = [self heightForCellAtIndexPath:indexPath withWidth:itemSize.width - (textPadding*2)];
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* body = [self bodyTextForCellAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMQuestionCell class]]) {
        HEMQuestionCell* qCell = (HEMQuestionCell*)cell;
        NSDictionary* attributes = [HEMQuestionCell questionTextAttributes];
        NSMutableAttributedString* attrBody
        = [[NSMutableAttributedString alloc] initWithString:body attributes:attributes];
        [[qCell questionLabel] setAttributedText:attrBody];
        [[qCell answerButton] addTarget:self action:@selector(answerQuestion:) forControlEvents:UIControlEventTouchUpInside];
        [[qCell skipButton] addTarget:self action:@selector(skipQuestion:) forControlEvents:UIControlEventTouchUpInside];
        [[qCell answerButton] setTag:[indexPath row]];
        [[qCell skipButton] setTag:[indexPath row]];
    } else if ([cell isKindOfClass:[HEMInsightCollectionViewCell class]]) {
        HEMInsightCollectionViewCell* iCell = (HEMInsightCollectionViewCell*)cell;
        [iCell setMessage:body];
        [iCell setInfoPreview:[self infoPreviewTextForCellAtIndexPath:indexPath]];
        [[iCell dateLabel] setText:[self dateForCellAtIndexPath:indexPath]];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // skip questions as those interactions are handled through button events
    SENInsight* insight = [self insightAtIndexPath:indexPath];
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
    SENQuestion* question = [self questionAtIndexPath:path];
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
        SENQuestion* question = [self questionAtIndexPath:path];
        [self removeQuestion:question atIndexPath:path];
    }];
}

@end
