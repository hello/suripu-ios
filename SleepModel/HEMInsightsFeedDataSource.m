//
//  HEMInsightsFeedDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENQuestion.h>
#import <SenseKit/SENAPIInsight.h>
#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAppUnreadStats.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"
#import "NSString+HEMUtils.h"
#import "HEMInsightsFeedDataSource.h"
#import "HEMQuestionCell.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMAppReview.h"
#import "HEMUnreadAlertService.h"

static NSString* const HEMInsightsFeedReuseIdQuestion = @"question";
static NSString* const HEMInsightsFeedReuseIdInsight = @"insight";
static NSString* const HEMInsightsFeedErrorDomain = @"is.hello.app.insight";

@interface HEMInsightsFeedDataSource()

@property (nonatomic, weak)   id questionsTarget;
@property (nonatomic, assign) SEL questionsSkipSelector;
@property (nonatomic, assign) SEL questionsAnswerSelector;
@property (nonatomic, strong) NSMutableArray* data;
@property (nonatomic, strong) NSCache* heightCache;
@property (nonatomic, assign, getter=isLoadingInsights) BOOL loadingInsights;

@end

@implementation HEMInsightsFeedDataSource

- (id)initWithQuestionTarget:(id)target
        questionSkipSelector:(SEL)skipSelector
      questionAnswerSelector:(SEL)answerSelector {
    self = [super init];
    if (self) {
        [self setData:[NSMutableArray array]];
        [self setHeightCache:[[NSCache alloc] init]];
        [self setQuestionsTarget:target];
        [self setQuestionsSkipSelector:skipSelector];
        [self setQuestionsAnswerSelector:answerSelector];
    }
    return self;
}

- (BOOL)isLoading {
    return [self isLoadingInsights] || [[SENServiceQuestions sharedService] isUpdating];
}

- (BOOL)hasData {
    return [[self data] count] > 0;
}

- (BOOL)hasUnreadItems {
    // we only care about insights and questions here, not everything that can be new
    HEMUnreadAlertService* service = [HEMUnreadAlertService sharedService];
    return [[service unreadStats] hasUnreadInsights]
        || [[service unreadStats] hasUnreadQuestions];
}

- (void)refresh:(void(^)(BOOL))completion {
    __block NSMutableArray* tmpData = [NSMutableArray array];
    __block BOOL insightsRefreshed = NO;
    __block BOOL questionsRefreshed = NO;
    __weak typeof(self) weakSelf = self;
    
    void(^refreshCompletion)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (insightsRefreshed && questionsRefreshed) {
            BOOL didUpdate = NO;
            if (![strongSelf.data isEqualToArray:tmpData]) {
                [strongSelf setData:tmpData];
                didUpdate = YES;
            }
            if (completion)
                completion(didUpdate);
        }
    };
    
    [self refreshInsights:^(NSArray* insights){
        insightsRefreshed = YES;
        if ([insights count] > 0) [tmpData addObjectsFromArray:insights];
        refreshCompletion();
    }];
    [self refreshQuestions:^(NSArray* questions){
        questionsRefreshed = YES;
        if ([questions count] > 0) [tmpData insertObject:questions[0] atIndex:0];
        refreshCompletion();
    }];
    
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath {
    return [indexPath row] >= [[self data] count] ? nil : [self data][[indexPath row]];
}

#pragma mark - Insights

- (SENInsight*)insightAtIndexPath:(NSIndexPath*)indexPath {
    id dataObj = [self objectAtIndexPath:indexPath];
    return [dataObj isKindOfClass:[SENInsight class]] ? dataObj : nil;
}

- (void)refreshInsights:(void(^)(NSArray* insights))completion {
    [self setLoadingInsights:YES];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIInsight getInsights:^(NSArray* insights, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setLoadingInsights:NO];
            if (completion) completion (insights);
        }
    }];
}

#pragma mark - Questions

- (void)removeQuestionAtIndexPath:(NSIndexPath*)indexPath {
    id dataObj = [self objectAtIndexPath:indexPath];
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        NSMutableArray* mutableData = [[self data] mutableCopy];
        [mutableData removeObjectAtIndex:[indexPath row]];
        [self setData:mutableData];
    }
}

- (SENQuestion*)questionAtIndexPath:(NSIndexPath*)indexPath {
    id dataObj = [self objectAtIndexPath:indexPath];
    return [dataObj isKindOfClass:[SENQuestion class]] ? dataObj : nil;
}

- (void)updateDataWithQuestions:(NSMutableArray*)data {
    NSArray* questions = [[SENServiceQuestions sharedService] todaysQuestions];
    NSInteger count = [questions count];
    if (count > 0) {
        [data insertObject:questions[0] atIndex:0];
    }
}

- (void)refreshQuestions:(void(^)(NSArray* questions))completion {
    void(^done)(NSArray* questions) = ^(NSArray* questions){
        if (completion) {
            completion (questions);
        }
    };
    
    [HEMAppReview shouldAskUserToRateTheApp:^(HEMAppReviewQuestion* question) {
        if (question) {
            [SENAnalytics track:HEMAnalyticsEventAppReviewShown];
            done(@[question]);
        } else {
            [[SENServiceQuestions sharedService] updateQuestions:^(NSArray *questions, NSError *error) {
                NSArray* updatedQuestions = nil;
                if (error) {
                    DDLogVerbose(@"error updating questions %@", error);
                } else {
                    updatedQuestions = [[SENServiceQuestions sharedService] todaysQuestions];
                }
                done(updatedQuestions);
            }];
        }
    }];
}

- (void)updateLastViewed:(HEMUnreadTypes)types completion:(void(^)(NSError* error))completion {
    void(^done)(BOOL unread, NSError* error) = ^(BOOL unread, NSError* error) {
        if (completion) {
            completion (error);
        }
    };
    
    if ([self hasData]) {
        HEMUnreadAlertService* unreadService = [HEMUnreadAlertService sharedService];
        [unreadService updateLastViewFor:types completion:done];
    } else {
        done (NO, [NSError errorWithDomain:HEMInsightsFeedErrorDomain
                                      code:HEMInsightsFeedErrorNoData
                                  userInfo:nil]);
    }
}

#pragma mark - CollectionView

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
    if ([body length] == 0) return 0.0f;
    
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

- (void)displayCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    NSString* body = [self bodyTextForCellAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMQuestionCell class]]) {
        HEMQuestionCell* qCell = (HEMQuestionCell*)cell;
        NSDictionary* attributes = [HEMQuestionCell questionTextAttributes];
        NSMutableAttributedString* attrBody
        = [[NSMutableAttributedString alloc] initWithString:body attributes:attributes];
        [[qCell questionLabel] setAttributedText:attrBody];
        [[qCell answerButton] addTarget:[self questionsTarget]
                                 action:[self questionsAnswerSelector]
                       forControlEvents:UIControlEventTouchUpInside];
        [[qCell answerButton] setTag:[indexPath row]];
        [[qCell skipButton] addTarget:[self questionsTarget]
                               action:[self questionsSkipSelector]
                     forControlEvents:UIControlEventTouchUpInside];
        [[qCell skipButton] setTag:[indexPath row]];
    } else if ([cell isKindOfClass:[HEMInsightCollectionViewCell class]]) {
        HEMInsightCollectionViewCell* iCell = (HEMInsightCollectionViewCell*)cell;
        [iCell setMessage:body];
        [iCell setInfoPreview:[self infoPreviewTextForCellAtIndexPath:indexPath]];
        [[iCell dateLabel] setText:[self dateForCellAtIndexPath:indexPath]];
    }
}

@end
