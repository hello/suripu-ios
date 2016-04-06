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
#import "HEMListItemSelectionViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSoundsPresenter.h"
#import "HEMSleepSoundDurationsPresenter.h"
#import "HEMSleepSoundVolumePresenter.h"
#import "HEMAudioService.h"

@interface HEMSleepSoundViewController () <HEMSleepSoundPlayerDelegate, HEMListDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) IBOutlet UIButton* actionButton;
@property (nonatomic, strong) HEMSleepSoundService* sleepSoundService;
@property (nonatomic, strong) HEMAudioService* audioService;
@property (nonatomic, strong) HEMListPresenter* listPresenter;
@property (nonatomic, weak) HEMSleepSoundPlayerPresenter* playerPresenter;
@property (nonatomic, copy) NSString* listTitle;

@end

@implementation HEMSleepSoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
}

- (void)configurePresenters {
    [self setSleepSoundService:[HEMSleepSoundService new]];
    HEMSleepSoundPlayerPresenter* playerPresenter =
        [[HEMSleepSoundPlayerPresenter alloc] initWithSleepSoundService:[self sleepSoundService]
                                                          deviceService:[self deviceService]];
    [playerPresenter bindWithActionButton:[self actionButton]];
    [playerPresenter bindWithCollectionView:[self collectionView]];
    [playerPresenter setDelegate:self];
    [self addPresenter:playerPresenter];
    
    [self setPlayerPresenter:playerPresenter];
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

- (void)presentErrorWithTitle:(NSString*)title message:(NSString*)message {
    [HEMAlertViewController showInfoDialogWithTitle:title
                                            message:message
                                         controller:[self navigationController]];
}

- (void)showAvailableSounds:(NSArray *)sounds
          selectedSoundName:(NSString*)selectedName
                  withTitle:(NSString*)title
                   subTitle:(NSString*)subTitle
                       from:(HEMSleepSoundPlayerPresenter *)presenter {
    if (![self audioService]) {
        [self setAudioService:[HEMAudioService new]];
    }
    
    HEMSleepSoundsPresenter* soundsPresenter =
        [[HEMSleepSoundsPresenter alloc] initWithTitle:subTitle
                                                 items:sounds
                                      selectedItemName:selectedName
                                          audioService:[self audioService]];

    [self showListViewControllerWithPresenter:soundsPresenter title:title];
}

- (void)showAvailableDurations:(NSArray *)durations
          selectedDurationName:(NSString*)selectedName
                     withTitle:(NSString*)title
                      subTitle:(NSString*)subTitle
                          from:(HEMSleepSoundPlayerPresenter *)presenter {
    HEMSleepSoundDurationsPresenter* durationsPresenter
        = [[HEMSleepSoundDurationsPresenter alloc] initWithTitle:subTitle
                                                           items:durations
                                                selectedItemName:selectedName];
    [self showListViewControllerWithPresenter:durationsPresenter title:title];
}

- (void)showVolumeOptions:(NSArray *)volumeOptions
       selectedVolumeName:(NSString*)selectedName
                withTitle:(NSString*)title
                 subTitle:(NSString*)subTitle
                     from:(HEMSleepSoundPlayerPresenter *)presenter {
    HEMSleepSoundVolumePresenter* volumePresenter
        = [[HEMSleepSoundVolumePresenter alloc] initWithTitle:subTitle
                                                        items:volumeOptions
                                             selectedItemName:selectedName];
    [self showListViewControllerWithPresenter:volumePresenter title:title];
}

- (void)showListViewControllerWithPresenter:(HEMListPresenter*)presenter title:(NSString*)title {
    [self setListTitle:title];
    [self setListPresenter:presenter];
    [[self listPresenter] setDelegate:self];
    [self performSegueWithIdentifier:[HEMMainStoryboard listSegueIdentifier] sender:self];
}

#pragma mark - List Delegate

- (void)didSelectItem:(id)item atIndex:(NSInteger)index from:(HEMListPresenter *)presenter {
    BOOL dismiss = YES;
    
    if ([presenter isKindOfClass:[HEMSleepSoundsPresenter class]]) {
        [[self playerPresenter] setSelectedSound:item];
        dismiss = NO;
    } else if ([presenter isKindOfClass:[HEMSleepSoundDurationsPresenter class]]) {
        [[self playerPresenter] setSelectedDuration:item];
    } else if ([presenter isKindOfClass:[HEMSleepSoundVolumePresenter class]]) {
        [[self playerPresenter] setSelectedVolume:item];
    }
    
    if (dismiss) {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMListItemSelectionViewController class]]) {
        HEMListItemSelectionViewController* listVC = destVC;
        [listVC setListPresenter:[self listPresenter]];
        [listVC setTitle:[self listTitle]];
    }
}

@end
