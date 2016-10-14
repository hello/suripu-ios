//
//  HEMVoiceExamplesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceExamplesViewController.h"
#import "HEMVoiceExamplesPresenter.h"
#import "HEMVoiceCommandGroup.h"

@interface HEMVoiceExamplesViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) HEMVoiceExamplesPresenter* presenter;

@end

@implementation HEMVoiceExamplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    HEMVoiceExamplesPresenter* presenter =
        [[HEMVoiceExamplesPresenter alloc] initWithCommandGroup:[self commandGroup]];
    [presenter bindWithCollectionView:[self collectionView]];
    [presenter bindWithShadowView:[self shadowView]];
    [self addPresenter:presenter];
    [self setPresenter:presenter];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([[self navigationController] navigationBar]
        && ![[self presenter] hasNavBar]) {
        [[self presenter] bindWithNavigationBar:[[self navigationController] navigationBar]];
    }
}

@end
