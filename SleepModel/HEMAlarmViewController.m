#import <SenseKit/SENSound.h>

#import "HEMAlarmViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAlarmCache.h"
#import "HEMMainStoryboard.h"
#import "HEMClockPickerView.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMBaseController+Protected.h"
#import "HEMListItemSelectionViewController.h"
#import "HEMSettingsNavigationController.h"

#import "HEMAlarmPresenter.h"
#import "HEMAlarmSoundsPresenter.h"
#import "HEMAlarmRepeatDaysPresenter.h"
#import "HEMAlarmService.h"
#import "HEMAudioService.h"

@interface HEMAlarmViewController () <HEMAlarmPresenterDelegate, HEMListDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet HEMClockPickerView *clockView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) HEMAlarmPresenter* presenter;
@property (strong, nonatomic) HEMAlarmService* alarmService;
@property (strong, nonatomic) HEMAudioService* audioService;

@end

@implementation HEMAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    HEMAlarmService* service = [HEMAlarmService new];
    HEMAlarmPresenter* presenter = [[HEMAlarmPresenter alloc] initWithAlarm:[self alarm]
                                                               alarmService:service];
    [presenter setDelegate:self];
    [presenter bindWithTutorialPresentingController:self];
    [presenter bindWithButtonContainer:[self buttonContainer]
                          cancelButton:[self cancelButton]
                            saveButton:[self saveButton]];
    [presenter bindWithTableView:[self tableView] heightConstraint:[self tableViewHeightConstraint]];
    [presenter bindWithClockPickerView:[self clockView]];
    
    [self setPresenter:presenter];
    [self addPresenter:presenter];
    [self setAlarmService:service];
}

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

- (void)dismissWithMessage:(nullable NSString*)message
                     saved:(BOOL)saved
                      from:(HEMAlarmPresenter*)presenter {
    
    id transition = self.navigationController.transitioningDelegate;
    if ([transition isKindOfClass:[HEMSimpleModalTransitionDelegate class]]) {
        HEMSimpleModalTransitionDelegate* modalTransition = transition;
        [modalTransition setDismissMessage:message];
    }
    
    if ([self delegate]) {
        if (saved) {
            [self.delegate didSaveAlarm:self.alarm from:self];
        } else {
            [self.delegate didCancelAlarmFrom:self];
        }
    } else {
        [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
