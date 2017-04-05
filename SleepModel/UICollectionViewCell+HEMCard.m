//
//  UICollectionViewCell+HEMCard.m
//  Sense
//
//  Created by Jimmy Lu on 1/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UICollectionViewCell+HEMCard.h"
#import "NSShadow+HEMStyle.h"

@implementation UICollectionViewCell (HEMCard)

- (void)displayAsACard:(BOOL)card {
    if (card) {
        NSShadow* shadow = [NSShadow shadowForBackViewCards];
        self.layer.cornerRadius = 3.f;
        self.layer.borderWidth = 1.f;
        self.layer.shadowOffset = [shadow shadowOffset];
        self.layer.shadowColor = [[shadow shadowColor] CGColor];
        self.layer.shadowRadius = [shadow shadowBlurRadius];
        self.layer.shadowOpacity = 1.f;
        self.layer.masksToBounds = YES;
    } else {
        self.layer.cornerRadius = 0.0f;
        self.layer.borderWidth = 0.0f;
        self.layer.shadowOpacity = 0.0f;
        self.layer.masksToBounds = NO;
    }
}

@end
