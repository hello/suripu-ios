//
//  HEMVoiceExampleView.h
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMURLImageView;

@interface HEMVoiceExampleView : UIView

@property (weak, nonatomic) IBOutlet HEMURLImageView* iconView;
@property (weak, nonatomic) IBOutlet UIImageView* accessoryView;
@property (weak, nonatomic) IBOutlet UILabel* categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel* exampleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) UITapGestureRecognizer* tapGesture;

+ (CGFloat)heightWithExampleText:(NSString*)example withMaxWidth:(CGFloat)maxWidth;
+ (instancetype)exampleViewWithCategoryName:(NSString*)name
                                    example:(NSString*)example
                                    iconURL:(NSString*)iconURL;
- (void)applyStyle;

@end
