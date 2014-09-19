//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/BLE.h>

#import "HEMSensePairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMUserDataCache.h"

static NSString* const kHEMBluetoothSenseServiceUUID = @"0000FEE1-1212-EFDE-1523-785FEABCD123";

@interface HEMSensePairViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothLogo;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyButtonWidthConstraint;

@property (strong, nonatomic) SENSenseManager* manager;
@property (copy,   nonatomic) NSString* disconnectObserverId;

@end

@implementation HEMSensePairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self logoVSpaceConstraint] withDiff:diff];
    [self updateConstraint:[self readyVSpaceConstraint] withDiff:diff];
}

- (void)stopActivity {
    [[self readyButton] stopActivity];
    [[self noSenseButton] setEnabled:YES];
}

- (void)cacheManager {
    [[HEMUserDataCache sharedUserDataCache] setSenseManager:[self manager]];
}

- (void)disconnectSense {
    if ([self manager] != nil) {
        if ([self disconnectObserverId] != nil) {
            [[self manager] removeUnexpectedDisconnectObserver:[self disconnectObserverId]];
            [self setDisconnectObserverId:nil];
        }
        [[self manager] disconnectFromSense];
    }
}

- (void)observeUnexpectedDisconnects {
    __weak typeof(self) weakSelf = self;
    self.disconnectObserverId =
        [[self manager] observeUnexpectedDisconnect:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && [[strongSelf readyButton] isShowingActivity]) {
                [strongSelf stopActivity];
                [strongSelf showErrorMessage:NSLocalizedString(@"pairing.error.unexpected-disconnect", nil)];
            }
        }];
}

#pragma mark - Actions

- (IBAction)enablePairing:(id)sender {
    [self scanForSense];
}

#pragma mark - Scanning

- (void)scanForSense {
    [[self noSenseButton] setEnabled:NO];
    [[self readyButton] showActivityWithWidthConstraint:[self readyButtonWidthConstraint]];
    [self startScan];
}

- (void)startScan {
    // always rescan in case the user has moved or changed Sense globes or
    // whatever the reason is, that would cause a cache of the Sense object
    // or manager to cause issues.
    __weak typeof(self) weakSelf = self;
    if (![SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([senses count] > 0) {
                // TODO (jimmy): what to do when more than 1 sense is detected?
                [strongSelf pairWith:[senses firstObject]];
                DLog(@"sense found, %@", [[strongSelf manager] sense]);
            } else {
                [strongSelf stopActivity];
                [strongSelf showErrorMessage:NSLocalizedString(@"pairing.error.sense-not-found", nil)];
            }
        }
    }]) {
        [self performSelector:@selector(startScan)
                   withObject:nil
                   afterDelay:0.1f];
    }
}

#pragma mark - Pairing

- (void)pairWith:(SENSense*)sense {
    [self disconnectSense]; // in case one has been set
    [self setManager:[[SENSenseManager alloc] initWithSense:sense]];
    [self observeUnexpectedDisconnects];

    __weak typeof(self) weakSelf = self;
    [[self manager] pair:^(id response) {
        DLog(@"paired!");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf cacheManager];
            [strongSelf stopActivity];
            NSString* segueId = [HEMOnboardingStoryboard wifiSegueIdentifier];
            [strongSelf performSegueWithIdentifier:segueId sender:strongSelf];
        }
    } failure:^(NSError *error) {
        DLog(@"failed to pair %@", error);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && [[strongSelf readyButton] isShowingActivity]) {
            [strongSelf stopActivity];
            [strongSelf showErrorMessage:NSLocalizedString(@"pairing.error.could-not-pair", nil)];
        }
    }];
}

#pragma mark - Errors

- (void)showErrorMessage:(NSString*)message {
    [self showMessageDialog:message title:NSLocalizedString(@"pairing.failed.title", nil)];
}

@end
