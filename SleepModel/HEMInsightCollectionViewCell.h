//
//  HEMInsightSummaryView.h
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMInsightCollectionViewCell : UICollectionViewCell

+ (CGRect)defaultFrame;
- (id)initWithTitle:(NSString*)title message:(NSString*)message;
- (void)setTitle:(NSString*)title message:(NSString*)message;

@end
