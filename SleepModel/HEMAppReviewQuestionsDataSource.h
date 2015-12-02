//
//  HEMAppReviewQuestionsDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 7/30/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSleepQuestionsDataSource.h"

@class HEMAppReviewQuestion;
@class HEMQuestionsService;

@interface HEMAppReviewQuestionsDataSource : NSObject <HEMQuestionsDataSource>

- (nonnull instancetype)initWithAppReviewQuestion:(nonnull HEMAppReviewQuestion*)appReviewQuestion
                                          service:(nonnull HEMQuestionsService*)questionsService;

@end
