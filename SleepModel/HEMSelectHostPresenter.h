//
//  HEMSelectHostDataSource.h
//  Sense
//
//  Created by Kevin MacWhinnie on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class HEMNonsenseScanService;

typedef void(^HEMSelectHostPresenterDone)(NSString* __nonnull host);

@interface HEMSelectHostPresenter : HEMPresenter

- (instancetype)initWithService:(HEMNonsenseScanService*)service NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)bindTableView:(UITableView*)tableView whenDonePerform:(HEMSelectHostPresenterDone)whenDone;

@end

NS_ASSUME_NONNULL_END
