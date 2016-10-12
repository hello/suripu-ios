//
//  HEMVoiceCommandsCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@interface HEMVoiceCommandsCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *commandsContainerView;

@property (assign, nonatomic) NSInteger estimatedNumberOfCommands;

+ (CGFloat)heightWithNumberOfCommands:(NSInteger)numberOfCommands;

- (void)addCommandWithCategory:(NSString*)category
                       example:(NSString*)example
                          icon:(UIImage*)icon;

@end
