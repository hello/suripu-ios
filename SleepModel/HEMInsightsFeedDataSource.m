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

#import "HEMInsightsFeedDataSource.h"
#import "HEMQuestionCell.h"

static NSString* const HEMInsightsFeedReuseIdQuestion = @"question";
static NSString* const HEMInsightsFeedReuseIdInsight = @"insight";
static CGFloat const HEMInsightsFeedBaseHeightQuestion = 163.0f;

NSInteger const HEMInsightsFeedSectQuestions = 0;
NSInteger const HEMInsightsFeedSectInsights = 1;
NSInteger const HEMInsightsFeedSections = 2;

@interface HEMInsightsFeedDataSource()

@property (nonatomic, strong) NSArray* insights;
@property (nonatomic, assign, getter=isLoadingInsights) BOOL loadingInsights;

@end

@implementation HEMInsightsFeedDataSource

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isLoading {
    return [self isLoadingInsights] || [[SENServiceQuestions sharedService] isUpdating];
}

- (void)refresh:(void(^)(void))completion {
    __block BOOL insightsRefreshed = NO;
    __block BOOL questionsRefreshed = NO;
    
    void(^refreshCompletion)(void) = ^{
        if (insightsRefreshed && questionsRefreshed) {
            if (completion) completion ();
        }
    };
    
    [self refreshInsights:^{
        insightsRefreshed = YES;
        refreshCompletion();
    }];
    [self refreshQuestions:^{
        questionsRefreshed = YES;
        refreshCompletion();
    }];
    
}

#pragma mark - Insights

- (void)refreshInsights:(void(^)(void))completion {
    [self setLoadingInsights:YES];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIInsight getInsights:^(NSArray* insights, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setLoadingInsights:NO];
            
            BOOL hasInsights = [insights count] > 0;
            if (error == nil && hasInsights) {
                [strongSelf setInsights:insights];
            }
            
            if (completion) completion ();
        }
    }];
}

#pragma mark - Questions

- (void)refreshQuestions:(void(^)(void))completion {
    if (![[SENServiceQuestions sharedService] isUpdating]) {
        if (completion) completion ();
        return;
    }
    
    __weak __block id observer =
        [[SENServiceQuestions sharedService] listenForNewQuestions:^(NSArray *questions) {
            [[SENServiceQuestions sharedService] stopListening:observer];
            if (completion) completion ();
        }];
}

#pragma mark - CollectionView

- (NSString*)bodyTextForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* body = nil;
    switch ([indexPath section]) {
        case HEMInsightsFeedSectQuestions: {
            SENQuestion* quest = [[SENServiceQuestions sharedService] todaysQuestions][0];
            body = [quest text];
            break;
        }
        default:
            break;
    }
    return body;
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width {
    NSString* body = [self bodyTextForCellAtIndexPath:indexPath];
    CGFloat baseHeight = 0.0f;
    UIFont* font = nil;
    NSDictionary* textAttributes = nil;
    
    switch ([indexPath section]) {
        case HEMInsightsFeedSectQuestions: {
            baseHeight = HEMInsightsFeedBaseHeightQuestion;
            font = [UIFont feedQuestionFont];
            textAttributes = [HEMQuestionCell questionaTextAttributes];
            break;
        }
        case HEMInsightsFeedSectInsights: {
            font = [UIFont feedInsightMessageFont];
            break;
        }
        default:
            break;
    }
    
    CGSize size = CGSizeMake(width, MAXFLOAT);
    CGRect rect = [body boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                             |NSStringDrawingUsesFontLeading
                                  attributes:textAttributes
                                     context:nil];
    return ceilf(CGRectGetHeight(rect)) + baseHeight;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case HEMInsightsFeedSectQuestions: {
            NSArray* questions = [[SENServiceQuestions sharedService] todaysQuestions];
            count = [questions count] == 0 ? 0 : 1; // show 1 question max
            break;
        }
        case HEMInsightsFeedSectInsights:
            count = [[self insights] count];
            break;
        default:
            break;
    }
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return HEMInsightsFeedSections;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* reuseId = nil;
    
    switch ([indexPath section]) {
        case HEMInsightsFeedSectQuestions:
            reuseId = HEMInsightsFeedReuseIdQuestion;
            break;
        case HEMInsightsFeedSectInsights:
            reuseId = HEMInsightsFeedReuseIdInsight;
        default:
            break;
    }
    
    // should never be nil.  if it is, just let it crash
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    return cell;
}

@end
