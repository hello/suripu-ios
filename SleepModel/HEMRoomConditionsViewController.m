//
//  HEMRoomConditionsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMRoomConditionsViewController.h"
#import "HEMRoomConditionsPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"

@interface HEMRoomConditionsViewController () <HEMPresenterPairDelegate, HEMSensePairingDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) HEMSensorService* sensorService;
@property (strong, nonatomic) HEMIntroService* introService;

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
    [presenter bindWithShadowView:[self shadowView]];
    [presenter setPairDelegate:self];

    [self setSensorService:sensorService];
    [self setIntroService:introService];
    [self addPresenter:presenter];
}

#pragma mark - HEMPresenterPairDelegate

- (void)pairSenseFrom:(HEMPresenter *)presenter {
    HEMSensePairViewController *pairVC = (id)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMSensePairingDelegate

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    BOOL paired = senseManager != nil;
    [self dismissModalAfterDelay:paired];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    BOOL paired = senseManager != nil;
    [self dismissModalAfterDelay:paired];
}

@end
