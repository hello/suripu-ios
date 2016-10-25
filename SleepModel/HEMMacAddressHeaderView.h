//
//  HEMMacAddressHeaderView.h
//  Sense
//
//  Created by Jimmy Lu on 10/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMMacAddressHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* macAddressLabel;
@property (nonatomic, weak) IBOutlet UIButton* actionButton;
@property (nonatomic, weak) IBOutlet UIView* separator;

@end
