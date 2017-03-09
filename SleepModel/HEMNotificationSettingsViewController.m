//
//  HEMNotificationSettingsViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENPreference.h>

#import "Sense-Swift.h"

#import "HEMNotificationSettingsViewController.h"
#import "HEMActivityIndicatorView.h"

typedef NS_ENUM(NSUInteger, HEMNotificationRow) {
    HEMNotificationRowConditionIndex = 0,
    HEMNotificationRowScoreIndex = 1,
    HEMNotificationRowCount = 2
};

@interface HEMNotificationSettingsViewController () <HEMPresenterErrorDelegate, HEMPresenterActivityDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) PushNotificationService* pushService;

@end

@implementation HEMNotificationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    PushNotificationService* pushService = [PushNotificationService new];
    NotificationSettingsPresenter* presenter
        = [[NotificationSettingsPresenter alloc] initWithService:pushService];
    [presenter bindWithTableView:[self tableView]];
    [presenter bindWithActivityIndicator:[self activityIndicator]];
    [presenter bindWithNavigationItem:[self navigationItem]];
    [presenter setErrorDelegate:self];
    [presenter setActivityDelegate:self];
    [self addPresenter:presenter];
    [self setPushService:pushService];
}

#pragma mark - Error Delegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message
                      title:title
                      image:nil
               withHelpPage:helpPage];
}

#pragma mark - Activity Delegate

- (UIView*)activityContainerFromPresenter:(HEMPresenter *)presenter {
    return [[self navigationController] view];
}

@end
