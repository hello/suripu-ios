//
//  HEMSleepPillFinderViewController.m
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSleepPill.h>

#import "HEMSleepPillFinderViewController.h"
#import "HEMPillDFUStoryboard.h"
#import "HEMSleepPillDfuViewController.h"
#import "HEMPillFinderPresenter.h"
#import "HEMDeviceService.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMActivityIndicatorView.h"
#import "HEMEmbeddedVideoView.h"

@interface HEMSleepPillFinderViewController () <HEMPillFinderDelegate, HEMPresenterErrorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet HEMEmbeddedVideoView *videoView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@end

@implementation HEMSleepPillFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self deviceService]) {
        [self setDeviceService:[HEMDeviceService new]];
    }
    
    HEMPillFinderPresenter* finderPresenter =
        [[HEMPillFinderPresenter alloc] initWithDeviceService:[self deviceService]];
    [finderPresenter bindWithTitleLabel:[self titleLabel]
                       descriptionLabel:[self descriptionLabel]];
    [finderPresenter bindWithVideoView:[self videoView]];
    [finderPresenter bindWithStatusLabel:[self statusLabel]
                            andIndicator:[self activityView]];
    [finderPresenter bindWithCancelButton:[self cancelButton] helpButton:[self helpButton]];
    [finderPresenter bindWithRetryButton:[self retryButton]];
    [finderPresenter setFinderDelegate:self];
    [finderPresenter setErrorDelegate:self];
    
    [self addPresenter:finderPresenter];
}

#pragma mark - HEMPillFinderDelegate

- (void)didFindSleepPill:(SENSleepPill*)pill from:(HEMPillFinderPresenter *)presenter {
    if (pill) {
        DDLogVerbose(@"found a sleep pill!");
    }
    HEMSleepPillDfuViewController* dfuController = [HEMPillDFUStoryboard instantiateDfuViewController];
    [dfuController setSleepPillToDfu:pill];
    [dfuController setDeviceService:[self deviceService]];
    [dfuController setDelegate:[self delegate]];
    [[self navigationController] setViewControllers:@[dfuController] animated:YES];
}

- (void)showHelpTopic:(NSString*)helpPage from:(HEMPillFinderPresenter*)presenter {
    [HEMSupportUtil openHelpToPage:helpPage fromController:self];
}

- (void)cancelFrom:(HEMPillFinderPresenter*)presenter {
    [[self delegate] controller:self didCompleteDFU:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message
                      title:title
                      image:nil
               withHelpPage:helpPage];
}

@end
