//
//  HEMSettingsAccountDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 1/21/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMSettingsAccountDataSource : NSObject <UITableViewDataSource>

@property (assign, nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (instancetype)initWithTableView:(UITableView*)tableView;
- (void)reload;
- (NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)valueForCellAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isLastRow:(NSIndexPath*)indexPath;

@end
