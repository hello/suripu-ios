//
//  HEMExpansionConnectDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENExpansion;

@protocol HEMExpansionConnectDelegate <NSObject>

- (void)didConnect:(BOOL)connected withExpansion:(SENExpansion*)expansion;

@end
