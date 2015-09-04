//
//  ConfigSpec.m
//  Sense
//
//  Created by Delisa Mason on 9/4/15.
//  Copyright 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>

CONFIG_START

beforeAllSpecs(^{
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", @".*\\.hello\\.is.*".regex);
});

afterAllSpecs(^{
    [[LSNocilla sharedInstance] stop];
});

CONFIG_END