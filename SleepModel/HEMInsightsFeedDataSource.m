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

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"

#import "HEMInsightsFeedDataSource.h"
#import "HEMQuestionCell.h"
#import "HEMInsightCollectionViewCell.h"

static NSString* const HEMInsightsFeedReuseIdQuestion = @"question";
static NSString* const HEMInsightsFeedReuseIdInsight = @"insight";

@interface HEMInsightsFeedDataSource()

@property (nonatomic, strong) NSMutableArray* data;
@property (nonatomic, strong) NSCache* heightCache;
@property (nonatomic, assign, getter=isLoadingInsights) BOOL loadingInsights;

@end

@implementation HEMInsightsFeedDataSource

- (id)init {
    self = [super init];
    if (self) {
        [self setData:[NSMutableArray array]];
        [self setHeightCache:[[NSCache alloc] init]];
    }
    return self;
}

- (BOOL)isLoading {
    return [self isLoadingInsights] || [[SENServiceQuestions sharedService] isUpdating];
}

- (void)refresh:(void(^)(void))completion {
    __block NSMutableArray* tmpData = [NSMutableArray array];
    __block BOOL insightsRefreshed = NO;
    __block BOOL questionsRefreshed = NO;
    __weak typeof(self) weakSelf = self;
    
    void(^refreshCompletion)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (insightsRefreshed && questionsRefreshed) {
            if (strongSelf) [strongSelf setData:tmpData];
            if (completion) completion ();
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
        [[SENServiceQuestions sharedService] updateQuestions:^(NSArray *questions, NSError *error) {
            if (error) DDLogVerbose(@"error updating questions %@", error);
            NSArray* updatedQuestions = error != nil ? nil : [[SENServiceQuestions sharedService] todaysQuestions];
            if (completion) completion (updatedQuestions);
        }];
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
        date = [[insight dateCreated] elapsed];
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

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width {
    NSString* body = [self bodyTextForCellAtIndexPath:indexPath];
    if ([body length] == 0) return 0.0f;
    
    if ([[self heightCache] objectForKey:body] != nil) {
        return [[[self heightCache] objectForKey:body] floatValue];
    }
    
    CGFloat baseHeight = 0.0f;
    CGFloat maxHeight = MAXFLOAT;
    UIFont* font = nil;
    NSDictionary* textAttributes = nil;
    
    id dataObj = [self data][[indexPath row]];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        baseHeight = HEMQuestionCellBaseHeight;
        font = [UIFont feedQuestionFont];
        textAttributes = [HEMQuestionCell questionTextAttributes];
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        maxHeight = HEMInsightCellMaxMessageHeight;
        baseHeight = HEMInsightCellBaseHeight;
        font = [UIFont feedInsightMessageFont];
        textAttributes = [HEMInsightCollectionViewCell messageTextAttributes];
    }
    
    CGSize size = CGSizeMake(width, maxHeight);
    CGRect rect = [body boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                             |NSStringDrawingUsesFontLeading
                                  attributes:textAttributes
                                     context:nil];
    CGFloat calculatedHeight = ceilf(CGRectGetHeight(rect)) + baseHeight;
    [[self heightCache] setObject:@(calculatedHeight) forKey:body];
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
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    return cell;
}

@end
