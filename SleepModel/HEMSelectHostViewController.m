//
//  HEMSelectHostViewController.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSelectHostViewController.h"
#import "HEMSelectHostPresenter.h"
#import "HEMNonsenseScanService.h"
#import <SenseKit/SENAPIClient.h>

@interface HEMSelectHostViewController ()

@property (nonatomic) HEMNonsenseScanService *scanService;
@property (nonatomic) UITableView *tableView;

@end

@implementation HEMSelectHostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.view = self.tableView;
    
    self.scanService = [HEMNonsenseScanService new];
    HEMSelectHostPresenter *presenter = [[HEMSelectHostPresenter alloc] initWithService:self.scanService];
    __weak __typeof(self) weakSelf = self;
    [presenter bindTableView:self.tableView whenDonePerform:^(NSString* _Nonnull host) {
        [weakSelf setHostAndDismiss:host];
    }];
    [self addPresenter:presenter];
    
    self.navigationItem.title = NSLocalizedString(@"debug.option.change-api-address", nil);
    self.navigationItem.prompt = [SENAPIClient baseURL].absoluteString;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"actions.cancel", nil)
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"debug.host.action.custom-url", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showURLUpdateAlertView)];
}

#pragma mark - Custom Hosts

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showURLUpdateAlertView {
    UIAlertView* URLAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.set-url.title", nil)
                                                           message:NSLocalizedString(@"authorization.set-url.message", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"actions.save", nil), NSLocalizedString(@"authorization.set-url.action.reset", nil), nil];
    URLAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* URLField = [URLAlertView textFieldAtIndex:0];
    URLField.text = [SENAPIClient baseURL].absoluteString;
    URLField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [URLAlertView show];
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 2: {
            [SENAPIClient resetToDefaultBaseURL];
            [self dismiss];
            break;
        }
        case 1: {
            UITextField* URLField = [alertView textFieldAtIndex:0];
            [self setHostAndDismiss:URLField.text];
            break;
        }
    }
}

- (void)setHostAndDismiss:(nonnull NSString*)host {
    if (![SENAPIClient setBaseURLFromPath:host]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.failed-url.title", nil)
                                    message:NSLocalizedString(@"authorization.failed-url.message", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                          otherButtonTitles:nil] show];
    } else {
        [self dismiss];
    }
}

@end
