//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/BLE.h>

#import "HEMPairingViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"

static NSString* const kHEMBluetoothSenseServiceUUID = @"0000FEE1-1212-EFDE-1523-785FEABCD123";

@interface HEMPairingViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothLogo;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyVSpaceConstraint;

@property (strong, nonatomic) SENSense* sense;
@property (strong, nonatomic) SENSenseManager* manager;

@end

@implementation HEMPairingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self logoVSpaceConstraint] withDiff:diff];
    [self updateConstraint:[self readyVSpaceConstraint] withDiff:diff];
}

#pragma mark - Actions

- (IBAction)enablePairing:(id)sender {
    [self scanForSense];
//    [self performSegueWithIdentifier:@"wifi" sender:self];
}

#pragma mark - Scanning

- (void)scanForSense {
    [[self noSenseButton] setEnabled:NO];
    [[self readyButton] showActivity];
    [self startScan];
}

- (void)startScan {
    // always rescan in case the user has moved or changed Sense globes or
    // whatever the reason is, that would cause a cache of the Sense object
    // or manager to cause issues.
    __weak typeof(self) weakSelf = self;
    if (![SENSenseManager scanForSense:^(NSArray *senses) {
        // TODO (jimmy): what to do when more than 1 sense is detected?
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf readyButton] stopActivity];
            [[strongSelf noSenseButton] setEnabled:YES];
            
            if ([senses count] > 0) {
                [strongSelf enablePairingMode:[senses firstObject]];
                DLog(@"sense found, %@", [strongSelf sense]);
            } else {
                [strongSelf showNoSenseFoundAlert];
            }
        }
    }]) {
        [self performSelector:@selector(startScan)
                   withObject:nil
                   afterDelay:0.1f];
    }
}

- (void)enablePairingMode:(SENSense*)sense {
    if (sense) {
        // TODO (jimmy): show next steps, but that requires some design
        // decisions.  will speak with Kevin when he comes in
        [self setSense:sense];
        [self setManager:[[SENSenseManager alloc] initWithSense:sense]];
        [[self manager] enablePairingMode:YES
                                  success:^(id response) {
                                      DLog(@"pairing mode on");
                                  } failure:^(NSError *error) {
                                      DLog(@"failed to enable code");
                                  }];
    }
}

- (void)showNoSenseFoundAlert {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"pariing.failed.title", nil)
                                message:NSLocalizedString(@"pairing.error.sense-not-found", nil)
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
}

@end
