//
//  HEMShareContentProvider.h
//  Sense
//
//  Created by Jimmy Lu on 6/21/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMShareContentProvider : NSObject <UIActivityItemSource>

- (instancetype)initWithItemToShare:(id)itemToShare forType:(NSString*)type;

@end

NS_ASSUME_NONNULL_END