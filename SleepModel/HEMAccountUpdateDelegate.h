//
//  HEMAccountUpdateHandler.h
//  Sense
//
//  Created by Jimmy Lu on 12/21/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENAccount;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMAccountUpdateBlock)(SENAccount* tempAccount);
typedef void(^HEMAccountCancelBlock)(void);

@interface HEMAccountUpdateDelegate : NSObject

- (void)setUpdateBlock:(HEMAccountUpdateBlock)update cancel:(HEMAccountCancelBlock)cancel;
- (void)update:(SENAccount*)account;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END