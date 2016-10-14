//
//  HEMRoomConditionsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSensor.h>

#import "HEMRoomConditionsViewController.h"
#import "HEMRoomConditionsPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMSensorDetailViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMRoomConditionsViewController () <
    HEMPresenterPairDelegate,
    HEMSensePairingDelegate,
    HEMRoomConditionsDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) HEMSensorService* sensorService;
@property (strong, nonatomic) HEMIntroService* introService;
@property (strong, nonatomic) SENSensor* sensorSelected;
@property (weak, nonatomic) HEMRoomConditionsPresenter* presenter;

@end

@implementation HEMRoomConditionsViewController

/**
 * @discussion
 * In 2.0, this will become obsolete so putting it here for now knowing the code
 * will be changed / removed
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"current-conditions.title", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"sensorsBarIcon"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"sensorsBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    HEMSensorService* sensorService = [HEMSensorService new];
    HEMIntroService* introService = [HEMIntroService new];
    
    HEMRoomConditionsPresenter* presenter =
        [[HEMRoomConditionsPresenter alloc] initWithSensorService:sensorService
                                                     introService:introService];
    
    [presenter bindWithCollectionView:[self collectionView]];
    [presenter bindWithActivityIndicator:[self activityIndicator]];
    [presenter setPairDelegate:self];
    [presenter setDelegate:self];

    [self setPresenter:presenter];
    [self setSensorService:sensorService];
    [self setIntroService:introService];
    [self addPresenter:presenter];
}

#pragma mark - HEMRoomConditionsDelegate

- (void)showSensor:(SENSensor *)sensor fromPresenter:(HEMRoomConditionsPresenter *)presenter {
    [self setSensorSelected:sensor];
    [self performSegueWithIdentifier:[HEMMainStoryboard detailSegueIdentifier] sender:self];
}

#pragma mark - HEMPresenterPairDelegate

- (void)pairSenseFrom:(HEMPresenter *)presenter {
    HEMSensePairViewController *pairVC = (id)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMSensePairingDelegate

- (void)notifyPresenterAndDismiss:(BOOL)paired {
    if (paired) {
        [[self presenter] startPolling];
    }
    [self dismissModalAfterDelay:paired];
}

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self notifyPresenterAndDismiss:senseManager != nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self notifyPresenterAndDismiss:senseManager != nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMSensorDetailViewController class]]) {
        HEMSensorDetailViewController* detailVC = destVC;
        [detailVC setSensor:[self sensorSelected]];
        [detailVC setTitle:[[self sensorSelected] localizedName]];
    }
}

@end
