//
//  HEMQuestionCell.h
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

extern CGFloat const HEMQuestionCellTextPadding;
extern CGFloat const HEMQuestionCellBaseHeight;

@interface HEMQuestionCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;

+ (NSDictionary*)questionTextAttributes;

@end
