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

@interface HEMRoomConditionsViewController ()

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

    [self setSensorService:sensorService];
    [self setIntroService:introService];
    [self addPresenter:presenter];
}

@end
