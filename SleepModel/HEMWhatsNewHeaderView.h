//
//  HEMWhatsNewHeaderView.h
//  Sense
//
//  Created by Jimmy Lu on 6/2/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMWhatsNewHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

+ (CGFloat)heightWithTitle:(NSString*)title message:(NSString*)message andMaxWidth:(CGFloat)maxWidth;
- (void)setTitle:(NSString*)title andMessage:(NSString*)message;

@end
