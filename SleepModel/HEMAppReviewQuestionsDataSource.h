//
//  HEMAppReviewQuestionsDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 7/30/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSleepQuestionsDataSource.h"

@class HEMAppReviewQuestion;

@interface HEMAppReviewQuestionsDataSource : NSObject <HEMQuestionsDataSource, UITableViewDataSource>

- (instancetype)initWithAppReviewQuestion:(HEMAppReviewQuestion*)appReviewQuestion;

@end
