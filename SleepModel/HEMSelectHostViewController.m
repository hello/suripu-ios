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
    NSString* title = NSLocalizedString(@"authorization.set-url.title", nil);
    NSString* message = NSLocalizedString(@"authorization.set-url.message", nil);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    __block UITextField* updateTextField = nil;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setText:[[SENAPIClient baseURL] absoluteString]];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        updateTextField = textField;
    }];
    
    __weak typeof(self) weakSelf = self;
    void(^cancel)(UIAlertAction* action) = ^(UIAlertAction* action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SENAPIClient resetToDefaultBaseURL];
        [strongSelf dismiss];
    };
    
    void(^change)(UIAlertAction* action) = ^(UIAlertAction* action){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setHostAndDismiss:[updateTextField text]];
    };
    
    NSString* ok = NSLocalizedString(@"actions.ok", nil);
    UIAlertAction* changeAction =  [UIAlertAction actionWithTitle:ok
                                                            style:UIAlertActionStyleDefault
                                                          handler:change];
    [alert addAction:changeAction];
    [alert setPreferredAction:changeAction];
    
    NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
    UIAlertAction* cancelAction =  [UIAlertAction actionWithTitle:cancelText
                                                            style:UIAlertActionStyleDefault
                                                          handler:cancel];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)setHostAndDismiss:(nonnull NSString*)host {
    if (![SENAPIClient setBaseURLFromPath:host]) {
        [self showMessageDialog:NSLocalizedString(@"authorization.failed-url.message", nil)
                          title:NSLocalizedString(@"authorization.failed-url.title", nil)];
    } else {
        [self dismiss];
    }
}

@end
