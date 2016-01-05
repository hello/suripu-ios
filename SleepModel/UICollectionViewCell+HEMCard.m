//
//  UICollectionViewCell+HEMCard.m
//  Sense
//
//  Created by Jimmy Lu on 1/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UICollectionViewCell+HEMCard.h"
#import "HEMStyle.h"

@implementation UICollectionViewCell (HEMCard)

- (void)displayAsACard:(BOOL)card {
    if (card) {
        NSShadow* shadow = [NSShadow shadowForBackViewCards];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.contentView.layer.cornerRadius = 3.f;
        self.contentView.layer.borderColor = [[UIColor cardBorderColor] CGColor];
        self.contentView.layer.borderWidth = 1.f;
        self.contentView.layer.shadowOffset = [shadow shadowOffset];
        self.contentView.layer.shadowColor = [[shadow shadowColor] CGColor];
        self.contentView.layer.shadowRadius = [shadow shadowBlurRadius];
        self.contentView.layer.shadowOpacity = 1.f;
        self.contentView.layer.masksToBounds = YES;
    } else {
        self.contentView.layer.cornerRadius = 0.0f;
        self.contentView.layer.borderWidth = 0.0f;
        self.contentView.layer.shadowOpacity = 0.0f;
        self.contentView.layer.masksToBounds = NO;
    }
}

@end
