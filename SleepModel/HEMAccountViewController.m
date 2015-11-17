//
//  HEMAccountViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENAPIAccount.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMAccountViewController.h"
#import "HEMAlertViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMBirthdatePickerViewController.h"
#import "HEMGenderPickerViewController.h"
#import "HEMHeightPickerViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSettingsAccountDataSource.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMWeightPickerViewController.h"
#import "HEMFormViewController.h"
#import "HEMSettingsHeaderFooterView.h"

static CGFloat const HEMAccountTableBaseRowHeight = 56.0f;
static CGFloat const HEMAccountTableAudioExplanationRowHeight = 70.0f;

@interface HEMAccountViewController () <UITableViewDelegate, HEMBirthdatePickerDelegate, HEMGenderPickerDelegate,
                                        HEMWeightPickerDelegate, HEMHeightPickerDelegate, HEMFormViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@property (assign, nonatomic) HEMSettingsAccountInfoType selectedInfoType;
@property (strong, nonatomic) HEMSettingsAccountDataSource *dataSource;

@end

@implementation HEMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTable];

    [SENAnalytics track:kHEMAnalyticsEventAccount];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self dataSource] reload:nil];
}

- (void)configureTable {
    [self setDataSource:[[HEMSettingsAccountDataSource alloc] initWithTableView:[self infoTableView]]];

    UIView* headerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    UIView* footerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    [[self infoTableView] setTableHeaderView:headerView];
    [[self infoTableView] setTableFooterView:footerView];
    [[self infoTableView] setBackgroundColor:[UIColor clearColor]];
    [[self infoTableView] setBackgroundView:nil];
    [[self infoTableView] setDataSource:[self dataSource]];
    [[self infoTableView] setDelegate:self];
    [[self infoTableView] setSeparatorColor:[UIColor separatorColor]];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsAccountInfoType type = [[self dataSource] infoTypeAtIndexPath:indexPath];
    return type == HEMSettingsAccountInfoTypeAudioExplanation ? HEMAccountTableAudioExplanationRowHeight
                                                              : HEMAccountTableBaseRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height;
    if (section == HEMSettingsAcctSectionAccount) {
        height = 0.0f;
    } else if (section == HEMSettingsacctSectionAudioExplanation) {
        height = HEMSettingsHeaderFooterBorderHeight; // only show border
    } else {
        height = HEMSettingsHeaderFooterHeight;
    }
    return height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL top = section != HEMSettingsAcctSectionSignOut;
    BOOL bottom = section != HEMSettingsacctSectionAudioExplanation;
    return [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:top bottomBorder:bottom];
}

- (void)updateCell:(UITableViewCell*)cell forType:(HEMSettingsAccountInfoType)type atIndexPath:(NSIndexPath*)indexPath {
    UIImage* iconImage = [[self dataSource] iconImageForCellAtIndexPath:indexPath];
    [[cell imageView] setImage:iconImage];
    
    NSString *title = [[self dataSource] titleForCellAtIndexPath:indexPath];
    NSString *value = [[self dataSource] valueForCellAtIndexPath:indexPath];
    
    switch (type) {
        case HEMSettingsAccountInfoTypeName:
        case HEMSettingsAccountInfoTypePassword:
        case HEMSettingsAccountInfoTypeEmail:
            [[cell textLabel] setText:value];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case HEMSettingsAccountInfoTypeSignOut:
            [[cell textLabel] setText:title];
            [[cell textLabel] setTextColor:[UIColor redColor]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            break;
        case HEMSettingsAccountInfoTypeHealthKit:
        case HEMSettingsAccountInfoTypeEnhancedAudio: {
            [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
            [[cell textLabel] setText:title];
            
            UISwitch *preferenceSwitch = [UISwitch new];
            BOOL enabled = [[self dataSource] isEnabledAtIndexPath:indexPath];
            [preferenceSwitch setOn:enabled];
            [preferenceSwitch setTag:type];
            [preferenceSwitch setOnTintColor:[UIColor tintColor]];
            [preferenceSwitch addTarget:self
                                 action:@selector(togglePreferenceSwitch:)
                       forControlEvents:UIControlEventTouchUpInside];
            [cell setAccessoryView:preferenceSwitch];
            break;
        }
        case HEMSettingsAccountInfoTypeAudioExplanation:
            [[cell textLabel] setText:title];
            [[cell textLabel] setFont:[UIFont settingsHelpFont]];
            break;
        default:
            [[cell textLabel] setText:title];
            [[cell detailTextLabel] setText:value];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
    }
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
    [[cell textLabel] setTextColor:[UIColor settingsCellTitleTextColor]];
    
    [[cell detailTextLabel] setTextColor:[UIColor settingsValueTextColor]];
    [[cell detailTextLabel] setFont:[UIFont settingsTableCellDetailFont]];
    [[cell detailTextLabel] setText:nil];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setAccessoryView:nil];

    HEMSettingsAccountInfoType type = [[self dataSource] infoTypeAtIndexPath:indexPath];
    [self updateCell:cell forType:type atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsAccountInfoType type = [[self dataSource] infoTypeAtIndexPath:indexPath];
    NSString *segueId = nil;
    UIViewController *editController = nil;

    switch (type) {
        case HEMSettingsAccountInfoTypeName: {
            [self setSelectedInfoType:HEMSettingsAccountInfoTypeName];
            segueId = [HEMMainStoryboard updateAccountInfoSegueIdentifier];
            break;
        }
        case HEMSettingsAccountInfoTypeEmail: {
            [self setSelectedInfoType:HEMSettingsAccountInfoTypeEmail];
            segueId = [HEMMainStoryboard updateAccountInfoSegueIdentifier];
            break;
        }
        case HEMSettingsAccountInfoTypePassword:
            [self setSelectedInfoType:HEMSettingsAccountInfoTypePassword];
            segueId = [HEMMainStoryboard updateAccountInfoSegueIdentifier];
            break;
        case HEMSettingsAccountInfoTypeBirthday:
            editController = [self birthdateController];
            break;
        case HEMSettingsAccountInfoTypeGender:
            editController = [self genderController];
            break;
        case HEMSettingsAccountInfoTypeHeight:
            editController = [self heightController];
            break;
        case HEMSettingsAccountInfoTypeWeight:
            editController = [self weightController];
            break;
        case HEMSettingsAccountInfoTypeSignOut:
            [self showSignOutConfirmation];
            break;
        default:
            break;
    }

    // a controller is needed b/c editing demographic data reuses controllers
    // that are within the Onboarding storyboard, which we can't use segues for.
    if (segueId != nil) {
        [self performSegueWithIdentifier:segueId sender:nil];
    } else if (editController != nil) {
        UINavigationController *nav =
            [[HEMStyledNavigationViewController alloc] initWithRootViewController:editController];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)showSignOutConfirmation {
    HEMAlertViewController *dialogVC = [[HEMAlertViewController alloc] initBooleanDialogWithTitle:NSLocalizedString(@"actions.sign-out", nil)
                                                        message:NSLocalizedString(@"settings.sign-out.confirmation", nil)
                                                  defaultsToYes:YES
                                                         action:^{
                                                             [SENAuthorizationService deauthorize];
                                                             [SENAnalytics track:kHEMAnalyticsEventSignOut];
                                                         }];
    id<UIApplicationDelegate> delegate = (id)[UIApplication sharedApplication].delegate;
    UIViewController *controller = (id)delegate.window.rootViewController;
    dialogVC.viewToShowThrough = controller.view;
    [dialogVC showFrom:self];
}

- (void)togglePreferenceSwitch:(UISwitch *)preferenceSwitch {
    HEMSettingsAccountInfoType type = [preferenceSwitch tag];

    __weak typeof(self) weakSelf = self;
    [[self dataSource] enablePreference:[preferenceSwitch isOn]
                                forType:type
                             completion:^(NSError *error) {
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               [preferenceSwitch setOn:[[strongSelf dataSource] isTypeEnabled:type] animated:YES];
                               [strongSelf showErrorIfAny:error];
                             }];
}

#pragma mark - Segues / Next Controller Prep

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        [[nav navigationBar] setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor backViewNavTitleColor],
            NSFontAttributeName : [UIFont settingsTitleFont]
        }];
    } else if ([[segue destinationViewController] isKindOfClass:[HEMFormViewController class]]) {
        HEMFormViewController* formVC = [segue destinationViewController];
        [formVC setDelegate:self];
    }
}

- (HEMBirthdatePickerViewController *)birthdateController {
    HEMBirthdatePickerViewController *dobViewController
        = (HEMBirthdatePickerViewController *)[HEMOnboardingStoryboard instantiateDobViewController];
    [dobViewController setDelegate:self];

    NSDateComponents *components = [[self dataSource] birthdateComponents];
    if (components != nil) {
        NSCalendar *calendar
            = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSInteger year = [[calendar components:NSCalendarUnitYear fromDate:[NSDate date]] year];
        [dobViewController setInitialMonth:[components month]];
        [dobViewController setInitialDay:[components day]];
        [dobViewController setInitialYear:year - [components year]];
    }

    return dobViewController;
}

- (HEMHeightPickerViewController *)heightController {
    HEMHeightPickerViewController *heightPicker
        = (HEMHeightPickerViewController *)[HEMOnboardingStoryboard instantiateHeightPickerViewController];
    [heightPicker setHeightInCm:[[self dataSource] heightInCm]];
    [heightPicker setDelegate:self];
    return heightPicker;
}

- (HEMWeightPickerViewController *)weightController {
    HEMWeightPickerViewController *weightPicker
        = (HEMWeightPickerViewController *)[HEMOnboardingStoryboard instantiateWeightPickerViewController];
    [weightPicker setDefaultWeightInGrams:[[self dataSource] weightInGrams]];
    [weightPicker setDelegate:self];
    return weightPicker;
}

- (HEMGenderPickerViewController *)genderController {
    HEMGenderPickerViewController *genderPicker
        = (HEMGenderPickerViewController *)[HEMOnboardingStoryboard instantiateGenderPickerViewController];
    [genderPicker setDefaultGender:[[self dataSource] genderEnumValue]];
    [genderPicker setDelegate:self];
    return genderPicker;
}

#pragma mark - Delegates

- (void)showErrorIfAny:(NSError *)error {
    if (error == nil)
        return;

    NSString *message = nil;
    switch ([error code]) {
    case HEMSettingsAccountErrorNotSupported:
        message = NSLocalizedString(@"account.update.error.not-supported", nil);
        break;
    default:
        message = NSLocalizedString(@"account.update.error.generic", nil);
        break;
    }
    [self showMessageDialog:message title:NSLocalizedString(@"account.update.failed.title", nil)];
}

#pragma mark BirthDate Delegate

- (void)didSelectMonth:(NSInteger)month
                   day:(NSInteger)day
                  year:(NSInteger)year
                  from:(HEMBirthdatePickerViewController *)controller {

    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateBirthMonth:month
                                    day:day
                                   year:year
                             completion:^(NSError *error) {
                               [weakSelf showErrorIfAny:error];
                             }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelBirthdatePicker:(HEMBirthdatePickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Height Delegate

- (void)didSelectHeightInCentimeters:(CGFloat)centimeters
                                from:(HEMHeightPickerViewController *)controller {

    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateHeight:centimeters
                         completion:^(NSError *error) {
                           [weakSelf showErrorIfAny:error];
                         }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelHeightFrom:(HEMHeightPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Weight Delegate

- (void)didSelectWeightInGrams:(CGFloat)grams
                          from:(HEMWeightPickerViewController *)controller {

    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateWeight:grams
                         completion:^(NSError *error) {
                           [weakSelf showErrorIfAny:error];
                         }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelWeightFrom:(HEMWeightPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Gender Delegate

- (void)didSelectGender:(SENAccountGender)gender from:(HEMGenderPickerViewController *)controller {

    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateGender:gender
                         completion:^(NSError *error) {
                           [weakSelf showErrorIfAny:error];
                           if (error == nil) {
                               [SENAnalytics updateGender:gender];
                           }
                         }];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelGenderFrom:(HEMGenderPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark HEMFormViewControllerDelegate

- (BOOL)shouldFieldBeSecureIn:(HEMFormViewController *)formViewController atIndex:(NSUInteger)index {
    return [self selectedInfoType] == HEMSettingsAccountInfoTypePassword;
}

- (UIKeyboardType)keyboardTypeForFieldIn:(HEMFormViewController *)formViewController
                                 atIndex:(NSUInteger)index {
    
    switch ([self selectedInfoType]) {
        case HEMSettingsAccountInfoTypeEmail:
            return UIKeyboardTypeEmailAddress;
        default:
            return UIKeyboardTypeDefault;
    }
}

- (NSString*)titleForForm:(HEMFormViewController*)formViewController {
    NSString* title = nil;
    if ([self selectedInfoType] == HEMSettingsAccountInfoTypeEmail) {
        title = NSLocalizedString(@"settings.account.email.update.title", nil);
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypeName) {
        title = NSLocalizedString(@"settings.account.name.update.title", nil);
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypePassword) {
        title = NSLocalizedString(@"settings.account.password.update.title", nil);
    }
    return title;
}

- (NSUInteger)numberOfFieldsIn:(HEMFormViewController *)formViewController {
    NSUInteger fields = 0;
    if ([self selectedInfoType] == HEMSettingsAccountInfoTypeEmail
        || [self selectedInfoType] == HEMSettingsAccountInfoTypeName) {
        fields = 1;
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypePassword) {
        fields = 3;
    }
    return fields;
}

- (NSString*)placeHolderTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index {
    NSString* placeHolderText = nil;
    if ([self selectedInfoType] == HEMSettingsAccountInfoTypeEmail) {
        placeHolderText = NSLocalizedString(@"settings.account.email.placeholder", nil);
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypeName) {
        placeHolderText = NSLocalizedString(@"settings.account.name.placeholder", nil);
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypePassword) {
        switch (index) {
            case 0:
                placeHolderText = NSLocalizedString(@"settings.account.password-current.placeholder", nil);
                break;
            case 1:
                placeHolderText = NSLocalizedString(@"settings.account.password-new.placeholder", nil);
                break;
            case 2:
                placeHolderText = NSLocalizedString(@"settings.account.password-new-confirm.placeholder", nil);
                break;
            default:
                break;
        }
    }
    return placeHolderText;
}

- (NSString*)defaultTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index {
    NSString* text = nil;
    if ([self selectedInfoType] == HEMSettingsAccountInfoTypeEmail) {
        text = [[self dataSource] valueForInfoType:HEMSettingsAccountInfoTypeEmail];
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypeName) {
        text = [[self dataSource] valueForInfoType:HEMSettingsAccountInfoTypeName];
    }
    return text;
}

- (NSString*)errorMessageFromAccountUpdateError:(NSError*)error {
    
    NSString* message = nil;
    if ([[error domain] isEqualToString:SENServiceAccountErrorDomain]) {
        switch ([error code]) {
            case SENServiceAccountErrorInvalidArg:
                message = NSLocalizedString(@"settings.account.update.failure", nil);
                break;
            case SENServiceAccountErrorPasswordTooShort:
                message = NSLocalizedString(@"settings.account.password-too-short", nil);
                break;
            case SENServiceAccountErrorPasswordInsecure:
                 message = NSLocalizedString(@"settings.account.password-insecure", nil);
                break;
            case SENServiceAccountErrorPasswordNotRecognized:
                message = NSLocalizedString(@"settings.account.password.current-password-wrong", nil);
                break;
            case SENServiceAccountErrorAccountNotUpToDate:
                message = NSLocalizedString(@"settings.account.update.account-not-up-to-date", nil);
                break;
            case SENServiceAccountErrorEmailAlreadyExists:
                message = NSLocalizedString(@"settings.account.update.email-already-exists", nil);
                break;
            case SENServiceAccountErrorEmailInvalid:
                message = NSLocalizedString(@"settings.account.update.email-invalid", nil);
                break;
            case SENServiceAccountErrorNameTooLong:
                message = NSLocalizedString(@"settings.account.update.name-too-long", nil);
                break;
            case SENServiceAccountErrorNameTooShort:
                message = NSLocalizedString(@"settings.account.update.name-too-short", nil);
            case SENServiceAccountErrorServerFailure:
            case SENServiceAccountErrorUnknown:
            default:
                break;
        }
    } else if ([[error domain] isEqualToString:NSURLErrorDomain]){
        message = [error localizedDescription];
    }
    
    return message ?: NSLocalizedString(@"settings.account.update.unknown-failure", nil);
}

- (void)saveFormContent:(NSDictionary*)content
                   from:(HEMFormViewController*)formViewController
             completion:(void(^)(NSString* errorMessage))completion {
    
    __weak typeof(self) weakSelf = self;
    void(^done)(NSError* error) = ^(NSError* error) {
        NSString* errorMessage = nil;
        if (error) {
            [SENAnalytics trackError:error];
            errorMessage = [weakSelf errorMessageFromAccountUpdateError:error];
        }
        if (completion) {
            completion (errorMessage);
        }
    };
    
    if ([self selectedInfoType] == HEMSettingsAccountInfoTypeEmail) {
        NSString* emailPlaceHolder = NSLocalizedString(@"settings.account.email.placeholder", nil);
        NSString* email = [content objectForKey:emailPlaceHolder];
        [[self dataSource] updateEmail:email completion:^(NSError *error) {
            if (!error) {
                [SENAnalytics updateEmail:email];
            }
            done (error);
        }];
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypeName) {
        NSString* namePlaceHolder = NSLocalizedString(@"settings.account.name.placeholder", nil);
        [[self dataSource] updateName:[content objectForKey:namePlaceHolder] completion:done];
    } else if ([self selectedInfoType] == HEMSettingsAccountInfoTypePassword) {
        NSString* currentPassPlaceHolder = NSLocalizedString(@"settings.account.password-current.placeholder", nil);
        NSString* passwordPlaceHolder = NSLocalizedString(@"settings.account.password-new.placeholder", nil);
        NSString* confirmationPlaceHolder = NSLocalizedString(@"settings.account.password-new-confirm.placeholder", nil);
        
        NSString* currentPass = [content objectForKey:currentPassPlaceHolder];
        NSString* password = [content objectForKey:passwordPlaceHolder];
        NSString* confirmationPass = [content objectForKey:confirmationPlaceHolder];
        
        if (![password isEqualToString:confirmationPass]) {
            if (completion) {
                completion (NSLocalizedString(@"settings.account.password.does-not-match", nil));
            }
            return;
        }
        
        [[self dataSource] updatePassword:password currentPassword:currentPass completion:done];
    }
}

#pragma mark - Clean Up

- (void)dealloc {
    [_infoTableView setDelegate:nil];
    [_infoTableView setDataSource:nil];
}

@end
