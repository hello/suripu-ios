//
//  HEMVoiceFeedViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceFeedViewController.h"
#import "HEMVoiceService.h"
#import "HEMVoiceFeedPresenter.h"

@interface HEMVoiceFeedViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HEMVoiceFeedViewController

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
    [self addPresenter:feedPresenter];
}

@end
