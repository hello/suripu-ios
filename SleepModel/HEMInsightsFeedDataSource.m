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

    CGFloat calculatedHeight = 0;
    id dataObj = [self data][[indexPath row]];
    
    if ([dataObj isKindOfClass:[SENQuestion class]]) {
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        CGRect rect = [body boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                         options:options
                                      attributes:[HEMQuestionCell questionTextAttributes]
                                         context:nil];
        calculatedHeight = ceilf(CGRectGetHeight(rect)) + HEMQuestionCellBaseHeight;
    } else if ([dataObj isKindOfClass:[SENInsight class]]) {
        calculatedHeight = [HEMInsightCollectionViewCell contentHeightWithMessage:body inWidth:width];
    }

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
    
    
    // if the cell does not respond to this selector, then that means the collection view
    // also will never call the delegate's willDisplayCell:atIndexPath, which means we
    // need to do it here.
    if (![cell respondsToSelector:@selector(preferredLayoutAttributesFittingAttributes:)]) {
        [self displayCell:cell atIndexPath:indexPath];
    }
    
    return cell;
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
        [iCell setTitle:[self insightTitleForCellAtIndexPath:indexPath]];
        [[iCell dateLabel] setText:[self dateForCellAtIndexPath:indexPath]];
    }
}

@end
