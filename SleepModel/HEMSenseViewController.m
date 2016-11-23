//
//  HEMSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSDate+HEMRelative.h"
#import "NSMutableAttributedString+HEMFormat.h"
#import "NSAttributedString+HEMUtils.h"
#import "NSDate+HEMRelative.h"
#import "NSTimeZone+HEMMapping.h"

#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMAlertViewController.h"
#import "HEMWiFiConfigurationDelegate.h"
#import "HEMWifiPickerViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActivityCoverView.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMTimeZoneViewController.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMActionSheetViewController.h"
#import "HEMSenseSettingsDataSource+HEMCollectionView.h"
#import "HEMDeviceWarning.h"
#import "HEMStyle.h"

@interface HEMSenseViewController() <UICollectionViewDelegate, HEMWiFiConfigurationDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic, getter=isVisible) BOOL visible;
@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (strong, nonatomic) HEMSimpleModalTransitionDelegate* modalTransitionDelegate;
@property (strong, nonatomic) HEMSenseSettingsDataSource* dataSource;


@end

@implementation HEMSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [self checkForWarnings];
    [SENAnalytics track:kHEMAnalyticsEventSense];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setVisible:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setVisible:NO];
}

- (void)configureCollectionView {
    __weak typeof(self) weakSelf = self;
    HEMSenseSettingsDataSource* dataSource = [HEMSenseSettingsDataSource new];
    [dataSource setDisconnectHandler:^(NSError * _Nullable error) {
        [weakSelf showBLEDisconnectErrorIfNeeded];
    }];
    
    [self setDataSource:dataSource];
    [[self collectionView] setDataSource:dataSource];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (void)showBLEDisconnectErrorIfNeeded {
    if ([self isVisible]) {
        if ([self activityView] != nil) {
            [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                NSString* title = NSLocalizedString(@"settings.sense.operation-failed.title", nil);
                NSString* message = NSLocalizedString(@"settings.sense.operation-failed.unexpected-disconnect", nil);
                [self showMessageDialog:message title:title];
            }];
        }
    }
}

- (void)checkForWarnings {
    __weak typeof(self) weakSelf = self;
    [[self dataSource] checkForWarnings:^(NSOrderedSet<HEMDeviceWarning *> * _Nonnull warnings) {
        [[weakSelf collectionView] reloadData];
    }];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = [[collectionView superview] bounds].size;
    if (section == 0) {
        size.height = HEMStyleDeviceSectionTopMargin;
    } else {
        size.height = HEMStyleSectionTopMargin;
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self dataSource] sizeForItemAtPath:indexPath inCollectionView:collectionView];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sec = [indexPath section];
    if (sec < [[[self dataSource] deviceWarnings] count]) {
        HEMDeviceWarning* warning = [[self dataSource] deviceWarnings][sec];
        [HEMSupportUtil openHelpToPage:[warning supportPage] fromController:self];
        
    } else if (sec > 0) { // 0 is the connected state
        switch ([indexPath row]) {
            default:
            case HEMSenseActionPairingMode:
                [self pairingMode];
                break;
            case HEMSenseActionEditWiFi:
                [self changeWiFi];
                break;
            case HEMSenseActionChangeTimeZone:
                [self changeTimeZone];
                break;
            case HEMSenseActionAdvanced:
                [self showAdvancedOptions];
                break;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

#pragma mark - Actions

- (NSDictionary*)dialogMessageAttributes:(BOOL)bold {
    UIFont* font = bold ? [UIFont bodyBold] : [UIFont body];
    return @{NSFontAttributeName : font,
             NSForegroundColorAttributeName : [UIColor blackColor]};
}

- (void)showConfirmation:(NSString*)title message:(NSAttributedString*)message action:(void(^)(void))action {
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setAttributedMessage:message];
    [dialogVC setViewToShowThrough:[self backgroundViewForAlerts]];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.no", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.yes", nil) style:HEMAlertViewButtonStyleBlueText action:^{
        if (action) {
            action();
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    [dialogVC onLinkTapOf:NSLocalizedString(@"help.url.support.hyperlink-text", nil) takeAction:^(NSURL *link) {
        [HEMSupportUtil openHelpFrom:weakSelf];
    }];
    
    [dialogVC showFrom:self];
}

- (void)showActivityText:(NSString*)text completion:(void(^)(void))completion {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    id<UIApplicationDelegate> delegate = (id)[UIApplication sharedApplication].delegate;
    UIViewController* root = (id)delegate.window.rootViewController;
    
    [[self activityView] showInView:[root view] withText:text activity:YES completion:completion];
}

- (void)dismissActivityWithSuccess:(void(^)(void))completion {
    NSString* done = NSLocalizedString(@"status.success", nil);
    [[self activityView] dismissWithResultText:done showSuccessMark:YES remove:YES completion:^{
        if ([[self delegate] respondsToSelector:@selector(didDismissActivityFrom:)]) {
            [[self delegate] didDismissActivityFrom:self];
        }
        if (completion) {
            completion ();
        }
    }];
}

- (void)dismissActivity:(void(^)(void))completion {
    [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:completion];
}

#pragma mark Advanced Options

- (void)showAdvancedOptions {
    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setTitle:NSLocalizedString(@"settings.sense.advanced.option.title", nil)];
    
    __weak typeof (self) weakSelf = self;
    
    [sheet addOptionWithTitle:NSLocalizedString(@"settings.sense.advanced.option.replace-sense", nil)
                   titleColor:nil
                  description:NSLocalizedString(@"settings.sense.advanced.option.replace-sense.desc", nil)
                    imageName:nil
                       action:^{
                           [weakSelf replaceSense];
                       }];
    
    if ([[self dataSource] isConnectedToSense]) {
        [sheet addOptionWithTitle:NSLocalizedString(@"settings.sense.advanced.option.factory-reset", nil)
                       titleColor:[UIColor redColor]
                      description:NSLocalizedString(@"settings.sense.advanced.option.factory-reset.desc", nil)
                        imageName:nil
                           action:^{
                               [weakSelf factoryReset];
                           }];
    }
    
    UIViewController* root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [root presentViewController:sheet animated:NO completion:nil];
}

#pragma mark Unpair Sense

- (void)showUnpairError {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.pair-failed-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.unpair.failed-message", nil);
    [self showMessageDialog:message title:title];
}

- (void)unlinkSense {
    if ([[self delegate] respondsToSelector:@selector(willUnpairSenseFrom:)]) {
        [[self delegate] willUnpairSenseFrom:self];
    }
    
    NSString* message = NSLocalizedString(@"settings.sense.unpairing-message", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[self dataSource] unlinkSense:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showUnpairError];
                }];
            } else {
                if ([[strongSelf delegate] respondsToSelector:@selector(didUnpairSenseFrom:)]) {
                    [[strongSelf delegate] didUnpairSenseFrom:strongSelf];
                }
                [strongSelf dismissActivityWithSuccess:nil];
            }
        }];
    }];
}

- (void)replaceSense {
    UIColor* baseColor = [UIColor blackColor];
    
    NSString* title = NSLocalizedString(@"settings.sense.unpair.title", nil);
    NSString* questionFormat = NSLocalizedString(@"settings.sense.unpair.confirmation.format", nil);
    NSString* guideLink = NSLocalizedString(@"help.url.support.hyperlink-text", nil);
    
    NSArray* args = @[[[NSAttributedString alloc] initWithString:guideLink
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* message =
        [[NSMutableAttributedString alloc] initWithFormat:questionFormat
                                                     args:args
                                                baseColor:baseColor
                                                 baseFont:[UIFont body]];
    
    [self showConfirmation:title message:message action:^{
        [self unlinkSense];
    }];
}

#pragma mark Time Zone

- (void)changeTimeZone {
    NSString* title = NSLocalizedString(@"alerts.timezone.title", nil);
    NSString* messageFormat = NSLocalizedString(@"timezone.alert.message.use-local.format", nil);
    NSArray* args = @[[[NSAttributedString alloc] initWithString:[NSTimeZone localTimeZoneMappedName]
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* message =
    [[NSMutableAttributedString alloc] initWithFormat:messageFormat
                                                 args:args
                                            baseColor:[UIColor blackColor]
                                             baseFont:[UIFont body]];
    
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setAttributedMessage:message];
    [dialogVC setViewToShowThrough:[self backgroundViewForAlerts]];
    
    __weak typeof(self) weakSelf = self;
    [dialogVC addButtonWithTitle:NSLocalizedString(@"timezone.action.use-local", nil) style:HEMAlertViewButtonStyleRoundRect action:^{
        [weakSelf updateToLocalTimeZone];
    }];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"timezone.action.select-manually", nil) style:HEMAlertViewButtonStyleBlueText action:^{
        [weakSelf performSegueWithIdentifier:[HEMMainStoryboard timezoneSegueIdentifier] sender:weakSelf];
    }];
    [dialogVC showFrom:self];
}

- (void)updateToLocalTimeZone {
    NSString* progressMessage = NSLocalizedString(@"timezone.activity.message", nil);
    [self showActivityText:progressMessage completion:^{
        __weak typeof(self) weakSelf = self;
        [[self dataSource] updateToLocalTimeZone:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = self;
            if (!error) {
                [strongSelf dismissActivityWithSuccess:nil];
            } else {
                [strongSelf dismissActivity:^{
                    [strongSelf showMessageDialog:NSLocalizedString(@"timezone.error.message", nil)
                                            title:NSLocalizedString(@"timezone.error.title", nil)];
                }];
            }
        }];
    }];
}

#pragma mark Enable Pairing Mode

- (void)pairingMode {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-title", nil);
    NSString* msgFormat = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-message.format", nil);
    NSString* guideLink = NSLocalizedString(@"help.url.support.hyperlink-text", nil);
    
    NSArray* args = @[[[NSAttributedString alloc] initWithString:guideLink
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* message =
        [[NSMutableAttributedString alloc] initWithFormat:msgFormat
                                                     args:args
                                                baseColor:[UIColor blackColor]
                                                 baseFont:[UIFont body]];
    
    __weak typeof(self) weakSelf = self;
    [self showConfirmation:title message:message action:^{
        [weakSelf enablePairingMode];
    }];
}

- (void)showFailureToEnablePairingModeAlert {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.pair-failed-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.dialog.pair-failed-message", nil);
    [self showMessageDialog:message title:title];
}

- (void)enablePairingMode {
    NSString* message = NSLocalizedString(@"settings.sense.enabling-pairing-mode", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[self dataSource] enablePairingMode:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showFailureToEnablePairingModeAlert];
                }];
            } else {
                if ([[strongSelf delegate] respondsToSelector:@selector(didEnterPairingModeFrom:)]) {
                    [[strongSelf delegate] didEnterPairingModeFrom:strongSelf];
                }
                [strongSelf dismissActivityWithSuccess:nil];
            }
        }];
    }];
}

#pragma mark Factory Reset

- (void)factoryReset {
    NSString* title = NSLocalizedString(@"settings.device.dialog.factory-restore-title", nil);
    NSString* message = NSLocalizedString(@"settings.device.dialog.factory-restore-message", nil);
    NSAttributedString* attributedMessage =
        [[NSAttributedString alloc] initWithString:message attributes:[self dialogMessageAttributes:NO]];
    
    __weak typeof(self) weakSelf = self;
    [self showConfirmation:title message:attributedMessage action:^{
        [weakSelf restore];
    }];
}

- (void)showFactoryRestoreErrorMessage:(NSError*)error {
    NSString* title = NSLocalizedString(@"settings.factory-restore.error.title", nil);
    NSString* message = [error localizedDescription];
    [self showMessageDialog:message title:title];
}

- (void)restore {
    NSString* message = NSLocalizedString(@"settings.device.restoring-factory-settings", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[self dataSource] factoryReset:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                // if there's no error, notification of factory restore will fire,
                // which will trigger app to be put back at checkpoint
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showFactoryRestoreErrorMessage:error];
                }];
            } else {
                if ([[strongSelf delegate] respondsToSelector:@selector(didFactoryRestoreFrom:)]) {
                    [[strongSelf delegate] didFactoryRestoreFrom:strongSelf];
                }
                [strongSelf dismissActivityWithSuccess:nil];
            }
        }];
    }];

}


#pragma mark Change WiFi

- (void)changeWiFi {
    HEMWifiPickerViewController* picker =
        (HEMWifiPickerViewController*) [HEMOnboardingStoryboard instantiateWifiPickerViewController];
    [picker setDelegate:self];
    
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:picker];
    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark - HEMWifiConfigurationDelegate

- (void)didCancelWiFiConfigurationFrom:(id)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didConfigureWiFiTo:(NSString *)ssid from:(id)controller {
    if ([[self delegate] respondsToSelector:@selector(didUpdateWiFiFrom:)]) {
        [[self delegate] didUpdateWiFiFrom:self];
    }
    
    if ([[self dataSource] clearWiFiWarnings]) {
        [[self collectionView] reloadData];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = [segue destinationViewController];
        UIViewController* root = [nav topViewController];
        // only apply the transition to timezone
        if ([root isKindOfClass:[HEMTimeZoneViewController class]]) {
            HEMSimpleModalTransitionDelegate* transition = [HEMSimpleModalTransitionDelegate new];
            [transition setWantsStatusBar:YES];
            [self setModalTransitionDelegate:transition];
            [nav setTransitioningDelegate:[self modalTransitionDelegate]];
            [nav setModalPresentationStyle:UIModalPresentationCustom];
        }
    }
}

#pragma mark - Clean up

- (void)dealloc {
    [[self collectionView] setDelegate:nil];
    [[self collectionView] setDataSource:nil];
}

@end
