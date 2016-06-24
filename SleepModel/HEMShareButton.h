//
//  HEMShareButton.h
//  Sense
//
//  Created by Jimmy Lu on 6/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenseKit/SENShareable.h>

@interface HEMShareButton : UIButton

@property (nonatomic, strong) id<SENShareable> shareable;

@end
