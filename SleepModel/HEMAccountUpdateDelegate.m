//
//  HEMAccountUpdateHandler.m
//  Sense
//
//  Created by Jimmy Lu on 12/21/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMAccountUpdateDelegate.h"

@interface HEMAccountUpdateDelegate()

@property (nonatomic, copy) HEMAccountUpdateBlock updateBlock;
@property (nonatomic, copy) HEMAccountCancelBlock cancelBlock;

@end

@implementation HEMAccountUpdateDelegate

- (void)setUpdateBlock:(HEMAccountUpdateBlock)update cancel:(HEMAccountCancelBlock)cancel {
    [self setUpdateBlock:update];
    [self setCancelBlock:cancel];
}

- (void)update:(SENAccount*)account {
    if ([self updateBlock]) {
        [self updateBlock] (account);
    }
}

- (void)cancel {
    if ([self cancelBlock]) {
        [self cancelBlock] ();
    }
}

@end
