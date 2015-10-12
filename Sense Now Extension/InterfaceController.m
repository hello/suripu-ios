//
//  InterfaceController.m
//  Sense Now Extension
//
//  Created by Delisa Mason on 10/12/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "InterfaceController.h"
#import "ModelCache.h"

@interface InterfaceController ()

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (instancetype)init {
    if (self = [super init]) {
        [ModelCache refreshCache];
    }
    return self;
}

- (void)willActivate {
    [super willActivate];
    [ModelCache refreshCache];
}

@end
