//
//  HEMVoiceCommandsCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@class HEMVoiceExampleView;

@interface HEMVoiceCommandsCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *commandsContainerView;

@property (assign, nonatomic) NSInteger estimatedNumberOfCommands;

+ (CGFloat)heightWithNumberOfCommands:(NSInteger)numberOfCommands;

- (HEMVoiceExampleView*)addCommandWithCategory:(NSString*)category
                                       example:(NSString*)example
                                          icon:(UIImage*)icon;

@end
