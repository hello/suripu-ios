//
//  HEMTellAFriendItemProvider.h
//  Sense
//
//  Created by Kevin MacWhinnie on 12/1/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTellAFriendItemProvider : NSObject <UIActivityItemSource>

- (nonnull instancetype)initWithSubject:(nullable NSString *)subject
                                   body:(nonnull NSString *)body NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init NS_UNAVAILABLE;

@property (readonly, copy, nullable) NSString *subject;
@property (readonly, copy, nonnull) NSString *body;

@end
