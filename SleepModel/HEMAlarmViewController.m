#import <SenseKit/SENSound.h>

#import "HEMAlarmViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAlarmCache.h"
#import "HEMMainStoryboard.h"
#import "HEMClockPickerView.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMListItemSelectionViewController.h"
#import "HEMSettingsNavigationController.h"

#import "HEMAlarmPresenter.h"
#import "HEMAlarmSoundsPresenter.h"
#import "HEMAlarmRepeatDaysPresenter.h"
#import "HEMAlarmService.h"
#import "HEMAudioService.h"

@interface HEMAlarmViewController () <HEMAlarmPresenterDelegate, HEMListDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) HEMAlarmPresenter* presenter;
@property (strong, nonatomic) HEMAudioService* audioService;

@end

@implementation HEMAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self alarmService]) {
        [self setAlarmService:[HEMAlarmService new]];
    }
    HEMAlarmPresenter* presenter =
        [[HEMAlarmPresenter alloc] initWithAlarm:[self alarm]
                                    alarmService:[self alarmService]
                                   deviceService:[self deviceService]];
    [presenter setDelegate:self];
    [presenter setSuccessDuration:[self successDuration]];
    [presenter setSuccessText:[self successText]];
    [presenter bindWithTutorialPresentingController:[self navigationController]];
    [presenter bindWithTableView:[self tableView]];
    [presenter bindWithNavigationItem:[self navigationItem]];
    
    [self setPresenter:presenter];
    [self addPresenter:presenter];
}

#pragma mark - HEMListDelegate

- (void)didSelectItem:(id)item atIndex:(NSInteger)index from:(HEMListPresenter *)presenter {
    if ([presenter isKindOfClass:[HEMAlarmSoundsPresenter class]]) {
        SENSound* sound = item;
        [[[self presenter] cache] setSoundID:[sound identifier]];
        [[[self presenter] cache] setSoundName:[sound displayName]];
    } // do nothing since it's all done inside the presenter ...
}

- (void)goBackFrom:(HEMListPresenter *)presenter {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - HEMAlarmPresenterDelegate

- (void)didSelectRowType:(HEMAlarmRowType)rowType {
    NSString* segueId = nil;
    switch (rowType) {
        case HEMAlarmRowTypeTone:
            segueId = [HEMMainStoryboard alarmSoundsSegueIdentifier];
            break;
        case HEMAlarmRowTypeRepeat:
            segueId = [HEMMainStoryboard alarmRepeatSegueIdentifier];
        default:
            break;
    }
    if (segueId) {
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

- (UIView*)activityContainerFor:(HEMAlarmPresenter *)presenter {
    return [[self navigationController] view];
}

- (void)showConfirmationDialogWithTitle:(NSString*)title
                                message:(NSString*)message
                                 action:(HEMAlarmAction)action
                                   from:(HEMAlarmPresenter*)presenter {
    HEMAlertViewController* alert =
        [[HEMAlertViewController alloc] initBooleanDialogWithTitle:title
                                                            message:message
                                                      defaultsToYes:YES
                                                             action:action];
    [alert setViewToShowThrough:[[self navigationController] view]];
    [alert showFrom:self];
}

- (void)showErrorWithTitle:(NSString*)title
                   message:(NSString*)message
                      from:(HEMAlarmPresenter*)presenter {
    [self showMessageDialog:message title:title];
}

- (void)didSave:(BOOL)save from:(HEMAlarmPresenter*)presenter {
    if ([self delegate]) {
        if (save) {
            [self.delegate didSaveAlarm:self.alarm from:self];
        } else {
            [self.delegate didCancelAlarmFrom:self];
        }
    } else {
        [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - Segues

- (void)prepareForRepeatDaysSegue:(UIStoryboardSegue*)segue {
    NSString* title = NSLocalizedString(@"alarm.repeat.title", nil);
    NSString* subtitle = NSLocalizedString(@"alarm.repeat.subtitle", nil);
    
    HEMAlarmRepeatDaysPresenter* daysPresenter =
    [[HEMAlarmRepeatDaysPresenter alloc] initWithNavTitle:title
                                                 subtitle:subtitle
                                               alarmCache:[[self presenter] cache]
                                                  basedOn:[[self presenter] alarm]
                                              withService:[self alarmService]];
    
    [daysPresenter setHideExtraNavigationBar:NO];
    [daysPresenter setDelegate:self];
    
    HEMListItemSelectionViewController* listVC = segue.destinationViewController;
    [listVC setListPresenter:daysPresenter];
}

- (void)prepareForSoundSegue:(UIStoryboardSegue*)segue {
    if (![self audioService]) {
        [self setAudioService:[HEMAudioService new]];
    }
    
    NSString* title = NSLocalizedString(@"alarm.sound.title", nil);
    NSString* subtitle = NSLocalizedString(@"alarm.sound.subtitle", nil);
    NSString* selectedName = [[[self presenter] cache] soundName];
    HEMAlarmSoundsPresenter* soundsPresenter =
    [[HEMAlarmSoundsPresenter alloc] initWithNavTitle:title
                                             subtitle:subtitle
                                                items:nil
                                     selectedItemName:selectedName
                                         audioService:[self audioService]
                                         alarmService:[self alarmService]];
    [soundsPresenter setHideExtraNavigationBar:NO];
    [soundsPresenter setDelegate:self];
    
    HEMListItemSelectionViewController* listVC = segue.destinationViewController;
    [listVC setListPresenter:soundsPresenter];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:[HEMMainStoryboard alarmRepeatSegueIdentifier]]) {
        [self prepareForRepeatDaysSegue:segue];
    } else if ([segue.identifier isEqualToString:[HEMMainStoryboard alarmSoundsSegueIdentifier]]) {
        [self prepareForSoundSegue:segue];
    }
}

@end
