//
//  HEMInfoViewController.h
//  Sense
//
//  Created by Jimmy Lu on 8/25/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HEMInfoDataSource <NSObject>

- (NSUInteger)numberOfInfoSections;
- (NSUInteger)numberOfInfoRowsInSection:(NSUInteger)section;
- (NSString*)infoTitleForIndexPath:(NSIndexPath*)indexPath;
- (NSString*)infoValueForIndexPath:(NSIndexPath*)indexPath;

@end

@interface HEMInfoViewController : UIViewController

@property (nonatomic, strong) id<HEMInfoDataSource> infoSource;

@end
