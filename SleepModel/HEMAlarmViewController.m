
#import "HEMAlarmViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMAlarmRepeatTableViewController.h"
#import "HEMAlarmCache.h"
#import "HEMMainStoryboard.h"
#import "HEMClockPickerView.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMBaseController+Protected.h"

#import "HEMAlarmPresenter.h"
#import "HEMAlarmService.h"

@interface HEMAlarmViewController () <HEMAlarmPresenterDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet HEMClockPickerView *clockView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) HEMAlarmPresenter* presenter;
@property (strong, nonatomic) HEMAlarmService* alarmService;

@end

@implementation HEMAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    HEMAlarmService* service = [HEMAlarmService new];
    HEMAlarmPresenter* presenter = [[HEMAlarmPresenter alloc] initWithAlarm:[self alarm] alarmService:service];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:[HEMMainStoryboard pickSoundSegueIdentifier]]) {
        HEMAlarmSoundTableViewController *controller = segue.destinationViewController;
        [controller setAlarmCache:[[self presenter] cache]];
    } else if ([segue.identifier isEqualToString:[HEMMainStoryboard alarmRepeatSegueIdentifier]]) {
        HEMAlarmRepeatTableViewController *controller = segue.destinationViewController;
        [controller setAlarmCache:[[self presenter] cache]];
        [controller setAlarm:[self alarm]];
    }
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
