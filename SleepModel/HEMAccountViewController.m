//
//  HEMAccountViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMBaseController+Protected.h"
#import "HEMAccountViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMSettingsAccountDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMUpdatePasswordViewController.h"
#import "HEMUpdateEmailViewController.h"
#import "HEMBirthdatePickerViewController.h"
#import "HEMHeightPickerViewController.h"
#import "HEMWeightPickerViewController.h"
#import "HEMGenderPickerViewController.h"

static CGFloat const HEMAccountTableSectionHeaderHeight = 20.0f;
static CGFloat const HEMAccountTableFooterMargins = 22.0f;

@interface HEMAccountViewController() <
    UITableViewDelegate,
    HEMUpdatePasswordDelegate,
    HEMUpdateEmailDelegate,
    HEMBirthdatePickerDelegate,
    HEMGenderPickerDelegate,
    HEMWeightPickerDelegate,
    HEMHeightPickerDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) HEMSettingsAccountDataSource* dataSource;

@end

@implementation HEMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTable];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self dataSource] reload:nil];
}

- (void)configureTable {
    [self setDataSource:[[HEMSettingsAccountDataSource alloc] initWithTableView:[self infoTableView]]];
    
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = CGRectGetWidth([[self infoTableView] bounds]);
    
    [[self infoTableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    [[self infoTableView] setTableFooterView:[self tableFooter]];
    [[self infoTableView] setDataSource:[self dataSource]];
    [[self infoTableView] setDelegate:self];
}

- (UIView*)tableFooter {
    UIView* footerView = [[UIView alloc] init];
    [footerView setBackgroundColor:[[self infoTableView] backgroundColor]];
    [footerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    
    UILabel* label = [[UILabel alloc] init];
    [label setFont:[UIFont settingsHelpFont]];
    [label setTextColor:[HelloStyleKit backViewTextColor]];
    [label setText:NSLocalizedString(@"settings.enhanced-audio.desc", nil)];
    [label setNumberOfLines:0];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat screenWidth = CGRectGetWidth([mainScreen bounds]);
    CGFloat labelWidth = screenWidth-(HEMAccountTableFooterMargins*2);
    CGSize constraint = CGSizeMake(labelWidth, MAXFLOAT);
    CGRect labelFrame = {
        HEMAccountTableFooterMargins,
        HEMAccountTableFooterMargins,
        labelWidth,
        [label sizeThatFits:constraint].height
    };
    [label setFrame:labelFrame];
    
    CGRect footerFrame = [footerView frame];
    footerFrame.size.width = screenWidth;
    footerFrame.size.height = CGRectGetMaxY(labelFrame) + HEMAccountTableFooterMargins;
    [footerView setFrame:footerFrame];

    [footerView addSubview:label];
    
    return footerView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.0f : HEMAccountTableSectionHeaderHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsTableViewCell* settingsCell = (HEMSettingsTableViewCell*)cell;
    
    NSString* title = [[self dataSource] titleForCellAtIndexPath:indexPath];
    NSString* value = [[self dataSource] valueForCellAtIndexPath:indexPath];
    
    if ([[settingsCell accessory] isKindOfClass:[UISwitch class]]) {
        UISwitch* settingsSwitch = (UISwitch*)[settingsCell accessory];
        BOOL enabled = [[self dataSource] isEnabledAtIndexPath:indexPath];
        [settingsSwitch setOn:enabled];
        [settingsSwitch setTag:[[self dataSource] infoTypeAtIndexPath:indexPath]];
        [settingsSwitch addTarget:self
                           action:@selector(togglePreferenceSwitch:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    
    [[settingsCell titleLabel] setText:title];
    [[settingsCell valueLabel] setText:value];
    
    BOOL firstRow = [indexPath row] == 0;
    BOOL lastRow = [[self dataSource] isLastRow:indexPath];
    
    if (firstRow && lastRow) {
        [settingsCell showTopAndBottomCorners];
    } else if (firstRow) {
        [settingsCell showTopCorners];
    } else if (lastRow) {
        [settingsCell showBottomCorners];
    } else {
        [settingsCell showNoCorners];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsAccountInfoType type = [[self dataSource] infoTypeAtIndexPath:indexPath];
    NSString* segueId = nil;
    UIViewController* editController = nil;
    
    switch (type) {
        case HEMSettingsAccountInfoTypeEmail:
            segueId = [HEMMainStoryboard updateEmailSegueIdentifier];
            break;
        case HEMSettingsAccountInfoTypePassword:
            segueId = [HEMMainStoryboard updatePasswordSegueIdentifier];
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
        default:
            break;
    }

    // a controller is needed b/c editing demographic data reuses controllers
    // that are within the Onboarding storyboard, which we can't use segues for.
    if (segueId != nil) {
        [self performSegueWithIdentifier:segueId sender:nil];
    } else if (editController != nil) {
        UINavigationController* nav =
            [[HEMStyledNavigationViewController alloc] initWithRootViewController:editController];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)togglePreferenceSwitch:(UISwitch*)preferenceSwitch {
    HEMSettingsAccountInfoType type = [preferenceSwitch tag];

    __weak typeof(self) weakSelf = self;
    [[self dataSource] enablePreference:[preferenceSwitch isOn] forType:type completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [preferenceSwitch setOn:[[strongSelf dataSource] isTypeEnabled:type] animated:YES];
        [strongSelf showErrorIfAny:error];
    }];
}

#pragma mark - Segues / Next Controller Prep

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)[segue destinationViewController];
        [[nav navigationBar] setTitleTextAttributes:@{
             NSForegroundColorAttributeName : [HelloStyleKit backViewNavTitleColor],
             NSFontAttributeName : [UIFont settingsTitleFont]
        }];
        
        if ([[nav topViewController] isKindOfClass:[HEMUpdatePasswordViewController class]]) {
            HEMUpdatePasswordViewController* passVC
                = (HEMUpdatePasswordViewController*)[nav topViewController];
            [passVC setDelegate:self];
        } else if ([[nav topViewController] isKindOfClass:[HEMUpdateEmailViewController class]]) {
            HEMUpdateEmailViewController* emailVC
                = (HEMUpdateEmailViewController*)[nav topViewController];
            [emailVC setDelegate:self];
        }
    }
}

- (HEMBirthdatePickerViewController*)birthdateController {
    HEMBirthdatePickerViewController* dobViewController =
    (HEMBirthdatePickerViewController*) [HEMOnboardingStoryboard instantiateDobViewController];
    [dobViewController setDelegate:self];
    
    NSDateComponents* components = [[self dataSource] birthdateComponents];
    if (components != nil) {
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSInteger year = [[calendar components:NSCalendarUnitYear fromDate:[NSDate date]] year];
        [dobViewController setInitialMonth:[components month]];
        [dobViewController setInitialDay:[components day]];
        [dobViewController setInitialYear:year - [components year]];
    }
    
    return dobViewController;
}

- (HEMHeightPickerViewController*)heightController {
    HEMHeightPickerViewController* heightPicker =
    (HEMHeightPickerViewController*) [HEMOnboardingStoryboard instantiateHeightPickerViewController];
    NSInteger totalInches = [[self dataSource] heightInInches];
    NSInteger feet = totalInches / 12;
    [heightPicker setFeet:feet];
    [heightPicker setInches:totalInches % 12];
    [heightPicker setDelegate:self];
    return heightPicker;
}

- (HEMWeightPickerViewController*)weightController {
    HEMWeightPickerViewController* weightPicker =
    (HEMWeightPickerViewController*) [HEMOnboardingStoryboard instantiateWeightPickerViewController];
    [weightPicker setDefaultWeightLbs:[[self dataSource] weightInPounds]];
    [weightPicker setDelegate:self];
    return weightPicker;
}

- (HEMGenderPickerViewController*)genderController {
    HEMGenderPickerViewController* genderPicker =
    (HEMGenderPickerViewController*) [HEMOnboardingStoryboard instantiateGenderPickerViewController];
    [genderPicker setDefaultGender:[[self dataSource] genderEnumValue]];
    [genderPicker setDelegate:self];
    return genderPicker;
}

#pragma mark - Delegates

- (void)showErrorIfAny:(NSError*)error {
    if (error == nil) return;
    
    NSString* message = nil;
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

#pragma mark Password Update Delegate

- (void)didUpdatePassword:(BOOL)updated from:(HEMUpdatePasswordViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Email Update Delegate

- (void)didUpdateEmail:(BOOL)updated from:(HEMUpdateEmailViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BirthDate Delegate

- (void)didSelectMonth:(NSInteger)month
                   day:(NSInteger)day
                  year:(NSInteger)year
                  from:(HEMBirthdatePickerViewController *)controller {

    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateBirthMonth:month day:day year:year completion:^(NSError* error) {
        [weakSelf showErrorIfAny:error];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelBirthdatePicker:(HEMBirthdatePickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Height Delegate

- (void)didSelectHeightInCentimeters:(int)centimeters
                                from:(HEMHeightPickerViewController *)controller {
    
    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateHeight:centimeters completion:^(NSError* error) {
        [weakSelf showErrorIfAny:error];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didCancelHeightFrom:(HEMHeightPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Weight Delegate

- (void)didSelectWeightInKgs:(CGFloat)weightKgs
                        from:(HEMWeightPickerViewController *)controller {
    
    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateWeight:weightKgs completion:^(NSError* error) {
        [weakSelf showErrorIfAny:error];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelWeightFrom:(HEMWeightPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Gender Delegate

- (void)didSelectGender:(SENAccountGender)gender
                   from:(HEMGenderPickerViewController *)controller {
    
    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateGender:gender completion:^(NSError* error) {
        [weakSelf showErrorIfAny:error];
        if (error == nil) {
            [HEMAnalytics updateGender:gender];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didCancelGenderFrom:(HEMGenderPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
