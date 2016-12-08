//
//  HEMVoiceFeedViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceFeedViewController.h"
#import "HEMVoiceExamplesViewController.h"
#import "HEMVoiceService.h"
#import "HEMVoiceCommandGroup.h"
#import "HEMVoiceFeedPresenter.h"
#import "HEMMainStoryboard.h"

@interface HEMVoiceFeedViewController () <HEMVoiceFeedDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMVoiceCommandGroup* selectedGroup;

@end

@implementation HEMVoiceFeedViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _tabIcon = [UIImage imageNamed:@"feedTabBarIcon"];
        _tabIconHighlighted = [UIImage imageNamed:@"feedTabBarIconHighlighted"];
        _tabTitle = NSLocalizedString(@"voice.title", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self voiceService]) {
        [self setVoiceService:[HEMVoiceService new]];
    }
    
    HEMVoiceFeedPresenter* feedPresenter =
        [[HEMVoiceFeedPresenter alloc] initWithVoiceService:[self voiceService]];
    [feedPresenter bindWithCollectionView:[self collectionView]];
    [feedPresenter bindWithSubNavigationBar:[self subNavBar]];
    [feedPresenter setFeedDelegate:self];
    [self addPresenter:feedPresenter];
}

#pragma mark - Feed Delegate

- (void)didTapOnCommandGroup:(HEMVoiceCommandGroup *)group
               fromPresenter:(HEMVoiceFeedPresenter *)presenter {
    [self setSelectedGroup:group];
    [self performSegueWithIdentifier:[HEMMainStoryboard detailSegueIdentifier]
                              sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMVoiceExamplesViewController class]]) {
        HEMVoiceExamplesViewController* examplesVC = destVC;
        [examplesVC setCommandGroup:[self selectedGroup]];
    }
}

@end
