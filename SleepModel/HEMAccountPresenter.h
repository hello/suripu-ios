//
//  HEMAccountPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMAccountPresenter;
@class HEMHealthKitService;
@class HEMAccountService;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMAccountSignOutHandler)(void);

@protocol HEMAccountDelegate <NSObject>

- (void)showErrorTitle:(NSString*)title message:(NSString*)message
                  from:(HEMAccountPresenter*)presenter;
- (void)showSignOutConfirmation:(NSString*)title
                       messasge:(NSString*)message
                         action:(HEMAccountSignOutHandler)action
                           from:(HEMAccountPresenter*)presenter;
- (void)presentViewController:(UIViewController*)controller
                         from:(HEMAccountPresenter*)presenter;
- (void)dismissViewControllerFrom:(HEMAccountPresenter*)presenter;

@end

@interface HEMAccountPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMAccountDelegate> delegate;

- (instancetype)initWithAccountService:(HEMAccountService*)accountService
                      healthKitService:(HEMHealthKitService*)healthKitService NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (void)bindWithTableView:(UITableView*)tableView;

@end

NS_ASSUME_NONNULL_END