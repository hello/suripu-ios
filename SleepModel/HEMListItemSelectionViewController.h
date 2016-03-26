//
//  HEMListItemSelectionViewController.h
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMListPresenter;

NS_ASSUME_NONNULL_BEGIN

@interface HEMListItemSelectionViewController : HEMBaseController

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) HEMListPresenter* listPresenter;

@end

NS_ASSUME_NONNULL_END