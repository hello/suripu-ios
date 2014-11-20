//
//  HEMPersonalInfoViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMPersonalInfoViewController.h"
#import "HEMPersonalInfoDataSource.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBirthdatePickerViewController.h"
#import "HEMHeightPickerViewController.h"
#import "HEMWeightPickerViewController.h"
#import "HEMGenderPickerViewController.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"

@interface HEMPersonalInfoViewController() <
    UITableViewDelegate,
    HEMBirthdatePickerDelegate,
    HEMHeightPickerDelegate,
    HEMWeightPickerDelegate,
    HEMGenderPickerDelegate
>

@property (weak,   nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) HEMPersonalInfoDataSource* data;
@property (assign, nonatomic, getter=isUpdating) BOOL updating;

@end

@implementation HEMPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setData:[[HEMPersonalInfoDataSource alloc] init]];
    [[self infoTableView] setDataSource:[self data]];
    [[self infoTableView] setTableFooterView:[[UIView alloc] init]];
    
    __weak typeof(self) weakSelf = self;
    [[self data] refresh:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf infoTableView] reloadData];
        }
    }];
}

- (HEMBirthdatePickerViewController*)birthdateController {
    HEMBirthdatePickerViewController* dobViewController =
        (HEMBirthdatePickerViewController*) [HEMOnboardingStoryboard instantiateDobViewController];
    [dobViewController setDelegate:self];
    
    NSDateComponents* components = [[self data] birthdateComponents];
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
    NSInteger inches = [[self data] heightInInches];
    NSInteger feet = floorf(inches/12);
    [heightPicker setFeet:feet];
    [heightPicker setInches:ceilf(inches - (feet*12))];
    [heightPicker setDelegate:self];
    return heightPicker;
}

- (HEMWeightPickerViewController*)weightController {
    HEMWeightPickerViewController* weightPicker =
        (HEMWeightPickerViewController*) [HEMOnboardingStoryboard instantiateWeightPickerViewController];
    [weightPicker setDefaultWeightLbs:[[self data] weightInLbs]];
    [weightPicker setDelegate:self];
    return weightPicker;
}

- (HEMGenderPickerViewController*)genderController {
    HEMGenderPickerViewController* genderPicker =
        (HEMGenderPickerViewController*) [HEMOnboardingStoryboard instantiateGenderPickerViewController];
    [genderPicker setDefaultGender:[[self data] gender]];
    [genderPicker setDelegate:self];
    return genderPicker;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* title = [[self data] tableView:tableView titleForIndexPath:indexPath];
    NSString* subtitle = nil;
    UIActivityIndicatorView* activityView = nil;
    
    if ([[self data] isLoaded] && ![self isUpdating]) {
        subtitle = [[self data] tableView:tableView infoForIndexPath:indexPath];
    } else {
        activityView =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView hidesWhenStopped];
        [activityView startAnimating];
    }
    
    [[cell textLabel] setText:title];
    [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[cell textLabel] setFont:[UIFont settingsTitleFont]];
    
    [[cell detailTextLabel] setText:subtitle];
    [[cell detailTextLabel] sizeToFit];
    [[cell detailTextLabel] setTextColor:[HelloStyleKit backViewDetailTextColor]];
    [[cell detailTextLabel] setFont:[UIFont settingsTableCellDetailFont]];
    
    [cell setAccessoryView:activityView];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    CGSize constraint = CGSizeMake(100.0f, CGRectGetHeight([cell bounds]));
    CGSize textSize = [[cell detailTextLabel] sizeThatFits:constraint];
    CGRect detailFrame = CGRectZero;
    detailFrame.origin.x = CGRectGetWidth([cell bounds]) - textSize.width - 35.0f;
    detailFrame.origin.y = ceilf((CGRectGetHeight([cell bounds]) - textSize.height)/2);
    detailFrame.size.height = textSize.height;
    detailFrame.size.width = textSize.width;
    [[cell detailTextLabel] setFrame:detailFrame];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![[self data] isLoaded] || [self isUpdating]) return;
    
    UIViewController* settingVC = nil;
    switch ([indexPath row]) {
        case HEMPersonalInfoBirthdate: {
            settingVC = [self birthdateController];
            break;
        }
        case HEMPersonalInfoGender:
            settingVC = [self genderController];
            break;
        case HEMPersonalInfoHeight:
            settingVC = [self heightController];
            break;
        case HEMPersonalInfoWeight:
            settingVC = [self weightController];
            break;
        default:
            break;
    }
    
    if (settingVC != nil) {
        UINavigationController* nav =
            [[UINavigationController alloc] initWithRootViewController:settingVC];
        [self presentViewController:nav animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Updates -

- (void)showUpdateProgressFor:(HEMPersonalInfo)info {
    NSIndexPath* path = [NSIndexPath indexPathForRow:info inSection:0];
    [self setUpdating:YES];
    [[self infoTableView] reloadRowsAtIndexPaths:@[path]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)finishUpdate:(NSError*)error {
    [self setUpdating:NO];
    [[self infoTableView] reloadData]; // clear the activity indicators
    
    if (error != nil) {
        [self showMessageDialog:NSLocalizedString(@"account.update.error.generic", nil)
                          title:NSLocalizedString(@"account.update.failed.title", nil)];
        
    }
    
}

#pragma mark BirthDate Delegate

- (void)didSelectMonth:(NSInteger)month
                   day:(NSInteger)day
                  year:(NSInteger)year
                  from:(HEMBirthdatePickerViewController *)controller {
    [self showUpdateProgressFor:HEMPersonalInfoBirthdate];

    __weak typeof(self) weakSelf = self;
    [[self data] updateBirthMonth:month day:day year:year completion:^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf finishUpdate:error];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelBirthdatePicker:(HEMBirthdatePickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Height Delegate

- (void)didSelectHeightInCentimeters:(int)centimeters
                                from:(HEMHeightPickerViewController *)controller {
    
    [self showUpdateProgressFor:HEMPersonalInfoHeight];
    
    __weak typeof(self) weakSelf = self;
    [[self data] updateHeight:centimeters completion:^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf finishUpdate:error];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didCancelHeightFrom:(HEMHeightPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Weight Delegate

- (void)didSelectWeightInKgs:(CGFloat)weightKgs
                        from:(HEMWeightPickerViewController *)controller {
        
    [self showUpdateProgressFor:HEMPersonalInfoWeight];
    
    __weak typeof(self) weakSelf = self;
    [[self data] updateWeight:weightKgs completion:^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf finishUpdate:error];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelWeightFrom:(HEMWeightPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Gender Delegate

- (void)didSelectGender:(SENAccountGender)gender
                   from:(HEMGenderPickerViewController *)controller {
    
    [self showUpdateProgressFor:HEMPersonalInfoGender];
    
    __weak typeof(self) weakSelf = self;
    [[self data] updateGender:gender completion:^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf finishUpdate:error];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didCancelGenderFrom:(HEMGenderPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
