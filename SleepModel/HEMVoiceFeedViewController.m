//
//  HEMVoiceFeedViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENVoiceCommandGroup.h>
#import "Sense-Swift.h"
#import "HEMVoiceFeedViewController.h"
#import "HEMVoiceExamplesViewController.h"
#import "HEMVoiceService.h"
#import "HEMVoiceFeedPresenter.h"
#import "HEMMainStoryboard.h"
#import "HEMActivityIndicatorView.h"

@interface HEMVoiceFeedViewController () <HEMVoiceFeedDelegate, Scrollable>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) SENVoiceCommandGroup* selectedGroup;

@end

@implementation HEMVoiceFeedViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        static NSString* iconKey = @"sense.feed.icon";
        static NSString* iconHighlightedKey = @"sense.feed.highlighted.icon";
        _tabIcon = [SenseStyle imageWithAClass:[UITabBar class] propertyName:iconKey];
        _tabIconHighlighted = [SenseStyle imageWithAClass:[UITabBar class] propertyName:iconHighlightedKey];
        _tabTitle = NSLocalizedString(@"voice.title", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:HEMAnalyticsEventVoiceTab];
}

- (void)configurePresenter {
    if (![self voiceService]) {
        [self setVoiceService:[HEMVoiceService new]];
    }
    
    HEMVoiceFeedPresenter* feedPresenter =
        [[HEMVoiceFeedPresenter alloc] initWithVoiceService:[self voiceService]];
    [feedPresenter bindWithCollectionView:[self collectionView]];
    [feedPresenter bindWithSubNavigationBar:[self subNavBar]];
    [feedPresenter bindWithActivityIndicator:[self activityIndicator]];
    [feedPresenter setFeedDelegate:self];
    [self addPresenter:feedPresenter];
}

#pragma mark - Scrollable

- (void)scrollToTop {
    [[self collectionView] setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Feed Delegate

- (void)didTapOnCommandGroup:(SENVoiceCommandGroup *)group
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
