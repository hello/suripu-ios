//
//  HEMSelectHostViewController.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSelectHostViewController.h"
#import "HEMSelectHostDataSource.h"
#import <SenseKit/SENAPIClient.h>

static NSString* const NonsenseServiceType = @"_http._tcp.";
static NSString* const NonsenseServiceName = @"nonsense-server";

@interface HEMSelectHostViewController () <UITableViewDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic) HEMSelectHostDataSource *dataSource;

@property (nonatomic) NSMutableArray<NSNetService*>* discovering;
@property (nonatomic) NSNetServiceBrowser *netServiceBrowser;

@end

@implementation HEMSelectHostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.discovering = [NSMutableArray new];
    
    self.netServiceBrowser = [NSNetServiceBrowser new];
    self.netServiceBrowser.delegate = self;
    
    self.dataSource = [HEMSelectHostDataSource new];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    
    self.navigationItem.title = NSLocalizedString(@"debug.option.change-api-address", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"actions.cancel", nil)
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"debug.host.action.custom-url", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showURLUpdateAlertView)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.netServiceBrowser searchForServicesOfType:NonsenseServiceType inDomain:@"local"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.netServiceBrowser stop];
    
    for (NSNetService *service in self.discovering) {
        [service stop];
        service.delegate = nil;
    }
    [self.discovering removeAllObjects];
}

#pragma mark - Custom Hosts

- (void)cancel {
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
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1: {
            UITextField* URLField = [alertView textFieldAtIndex:0];
            if (![SENAPIClient setBaseURLFromPath:URLField.text]) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.failed-url.title", nil)
                                            message:NSLocalizedString(@"authorization.failed-url.message", nil)
                                           delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                                  otherButtonTitles:nil] show];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
    }
}

#pragma mark - Service Discovery Delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    DDLogError(@"Could not perform service discovery %@", errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    if ([service.name containsString:NonsenseServiceName]) {
        [self.discovering addObject:service];
        service.delegate = self;
        [service resolveWithTimeout:5.0];
    }
    [self.tableView reloadData];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)browser
         didRemoveService:(NSNetService*)service
               moreComing:(BOOL)moreComing {
    if ([service.name containsString:NonsenseServiceName]) {
        [self.dataSource removeDiscoveredHost:service];
        [self.tableView reloadData];
    }
}

#pragma mark -

- (void)netServiceDidResolveAddress:(NSNetService*)service {
    service.delegate = nil;
    [self.dataSource addDiscoveredHost:service];
    [self.tableView reloadData];
    
    [self.discovering removeObject:service];
}

- (void)netService:(NSNetService*)service
     didNotResolve:(NSDictionary<NSString*, NSNumber*>*)errorDict {
    DDLogError(@"Could not resolve service %@", errorDict);
    
    [self.dataSource removeDiscoveredHost:service];
    [self.tableView reloadData];
    
    [self.discovering removeObject:service];
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString* host = [self.dataSource hostAtIndexPath:indexPath];
    if ([SENAPIClient setBaseURLFromPath:host]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.dataSource displayCell:cell atIndexPath:indexPath];
}

@end
