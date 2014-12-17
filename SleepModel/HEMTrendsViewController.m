//
//  HEMTrendsViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTrendsViewController.h"
#import "HelloStyleKit.h"

@interface HEMTrendsViewController ()

@end

@implementation HEMTrendsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.image = [HelloStyleKit trendsBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

@end
