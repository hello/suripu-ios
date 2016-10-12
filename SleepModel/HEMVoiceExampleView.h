//
//  HEMVoiceExampleView.h
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMVoiceExampleView : UIView

@property (weak, nonatomic) IBOutlet UIImageView* iconView;
@property (weak, nonatomic) IBOutlet UIImageView* accessoryView;
@property (weak, nonatomic) IBOutlet UILabel* categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel* exampleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

+ (instancetype)exampleViewWithCategoryName:(NSString*)name
                                    example:(NSString*)example
                                  iconImage:(UIImage*)iconImage;

@end
