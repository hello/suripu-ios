//
//  HEMSleepSoundViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIBarButtonItem+HEMNav.h"

#import "HEMSleepSoundViewController.h"
#import "HEMSleepSoundPlayerPresenter.h"
#import "HEMSleepSoundService.h"
#import "HEMAlertViewController.h"

@interface HEMSleepSoundViewController () <HEMSleepSoundPlayerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) IBOutlet UIButton* actionButton;
@property (nonatomic, strong) HEMSleepSoundService* sleepSoundService;

@end

@implementation HEMSleepSoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
}

- (void)configurePresenters {
    [self setSleepSoundService:[HEMSleepSoundService new]];
    HEMSleepSoundPlayerPresenter* playerPresenter =
        [[HEMSleepSoundPlayerPresenter alloc] initWithSleepSoundService:[self sleepSoundService]];
    [playerPresenter bindWithActionButton:[self actionButton]];
    [playerPresenter bindWithCollectionView:[self collectionView]];
    [playerPresenter setDelegate:self];
    [self addPresenter:playerPresenter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isCancellable]) {
        NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
        UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:cancelText
                                                                     image:nil
                                                                    target:self
                                                                    action:@selector(dismiss)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
    }
}

#pragma mark - Actions

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Sleep Sound Player Delegate

- (void)presentError:(NSError *)error {
    [HEMAlertViewController showInfoDialogWithTitle:nil message:[error localizedDescription] controller:self];
}

@end
