//
//  HEMAlarmExpansionSetupPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIBarButtonItem+HEMNav.h"

#import <UICountingLabel/UICountingLabel.h>
#import <SenseKit/SENPreference.h>

#import "HEMActionSheetViewController.h"
#import "HEMAlarmExpansionSetupPresenter.h"
#import "HEMAlarmValueRangePickerView.h"
#import "HEMExpansionService.h"
#import "HEMMainStoryboard.h"
#import "HEMBasicTableViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMSensorValueFormatter.h"
#import "HEMActionSheetTitleView.h"
#import "HEMThermostatRangePicker.h"
#import "HEMActivityIndicatorView.h"
#import "HEMStyle.h"

static CGFloat const kHEMAlarmExpRowHeight = 66.0f;
static NSInteger const kHEMAlarmExpPickerTag = 1;
static CGFloat const kHEMAlarmExpPickerSeparatorHeight = 0.5f;

typedef NS_ENUM(NSUInteger, HEMAlarmExpSetupRowType) {
    HEMAlarmExpSetupRowTypeEnable = 0,
    HEMAlarmExpSetupRowTypeConfigSelection
};

@interface HEMAlarmExpansionSetupPresenter() <
    HEMAlarmValueRangePickerDelegate,
    UITableViewDelegate,
    UITableViewDataSource
>

@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, strong) NSArray<NSNumber*>* rows;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSArray<SENExpansionConfig*>* configs;
@property (nonatomic, strong) NSError* configError;
@property (nonatomic, weak) UINavigationItem* navItem;
@property (nonatomic, weak) UIView* targetValueContainer;
@property (nonatomic, weak) UIView* targetValueSeparator;
@property (nonatomic, weak) HEMActivityIndicatorView* targetValueActivityIndicator;

@property (nonatomic, strong) SENExpansionConfig* selectedConfig;
@property (nonatomic, strong) SENAlarmExpansion* alarmExpansion;
@property (nonatomic, strong) HEMActivityCoverView* activityCoverView;

@property (nonatomic, assign) SENExpansionValueRange expansionValueRange;
@property (nonatomic, assign) NSInteger defaultTargetMinValue;
@property (nonatomic, assign) NSInteger defaultTargetMaxValue;

@end

@implementation HEMAlarmExpansionSetupPresenter

- (instancetype)initWithExpansion:(SENExpansion*)expansion
                   alarmExpansion:(SENAlarmExpansion*)alarmExpansion
                 expansionService:(HEMExpansionService*)expansionService {
    if (self = [super init]) {
        _expansion = expansion;
        _expansionService = expansionService;
        _rows = @[@(HEMAlarmExpSetupRowTypeEnable), @(HEMAlarmExpSetupRowTypeConfigSelection)];
        _alarmExpansion = [[SENAlarmExpansion alloc] initWithExpansionId:[expansion identifier] enable:NO];
        [_alarmExpansion setEnable:[alarmExpansion isEnable]];
        [_alarmExpansion setTargetRange:[alarmExpansion targetRange]];
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setScrollEnabled:NO];
    [tableView setTableFooterView:[UIView new]];
    [tableView setSeparatorColor:[UIColor separatorColor]];
    [self setTableView:tableView];
}

- (void)bindWithTargetValueContainer:(UIView*)container
                   activityIndicator:(HEMActivityIndicatorView*)activityIndicator
                           separator:(UIView*)separator {
    SENExpansionType type = [[self expansion] type];
    SENExpansionValueRange expansionRange = [[self expansion] valueRange];
    SENExpansionValueRange selectedRange = [[self alarmExpansion] targetRange];
    
    if (type == SENExpansionTypeThermostat) {
        expansionRange = [[self expansionService] convertThermostatRangeBasedOnPreference:expansionRange];
        selectedRange = [[self expansionService] convertThermostatRangeBasedOnPreference:selectedRange];
    }
    
    // set defaults
    [self setDefaultTargetMaxValue:[[self alarmExpansion] targetRange].max > 0
                                    ? selectedRange.max
                                    : expansionRange.max];
    [self setDefaultTargetMinValue:[[self alarmExpansion] targetRange].min > 0
                                    ? selectedRange.min
                                    : expansionRange.min];
    [self setExpansionValueRange:expansionRange];
    
    NSLayoutConstraint *heightConstraint;
    for (NSLayoutConstraint *constraint in [separator constraints]) {
        if ([constraint firstAttribute] == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    [heightConstraint setConstant:kHEMAlarmExpPickerSeparatorHeight];
    
    [separator setBackgroundColor:[UIColor separatorColor]];
    [activityIndicator start];
    [activityIndicator setHidden:NO];
    [activityIndicator setUserInteractionEnabled:NO];
    [self setTargetValueContainer:container];
    [self setTargetValueSeparator:separator];
    [self setTargetValueActivityIndicator:activityIndicator];
    
    if (type == SENExpansionTypeLights) {
        [self showTargetValuePicker];
    } else {
        [self showPickerLoadingState];
    }
    
    [self loadExpansionConfigurations];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    switch ([[self expansion] type]) {
        case SENExpansionTypeLights:
        case SENExpansionTypeThermostat:
            [navItem setRightBarButtonItem:[UIBarButtonItem infoButtonWithTarget:self action:@selector(showInfo)]];
            break;
        default:
            break;
    }
    [self setNavItem:navItem];
}

- (void)bindWithActivityContainerView:(UIView*)activityContainerView {
    [self setActivityContainerView:activityContainerView];
}

#pragma mark - Picker Configuration

- (void)showTargetValuePicker {
    [[self targetValueActivityIndicator] stop];
    [[self targetValueActivityIndicator] setHidden:YES];
    
    UIView* picker = [[self targetValueContainer] viewWithTag:kHEMAlarmExpPickerTag];
    [picker setHidden:NO];
    
    SENExpansionType type = [[self expansion] type];
    
    BOOL isThermostat = type == SENExpansionTypeThermostat;
    BOOL hasHeat = [[self selectedConfig] hasCapability:SENExpansionCapabilityHeat];
    BOOL hasCool = [[self selectedConfig] hasCapability:SENExpansionCapabilityCool];
    BOOL useThermostatRangePicker = isThermostat && hasHeat && hasCool;
    
    if (useThermostatRangePicker) {
        if (![picker isKindOfClass:[HEMThermostatRangePicker class]]) {
            [picker removeFromSuperview];
            
            HEMThermostatRangePicker* rangePicker =
                [HEMThermostatRangePicker rangePickerWithMin:[self defaultTargetMinValue]
                                                         max:[self defaultTargetMaxValue]
                                                withMinLimit:[self expansionValueRange].min
                                                    maxLimit:[self expansionValueRange].max];
            [rangePicker setAlpha:0.0f];
            [rangePicker setFrame:[[self targetValueContainer] bounds]];
            [rangePicker setTag:kHEMAlarmExpPickerTag];
            [[self targetValueContainer] insertSubview:rangePicker atIndex:0];
            
            picker = rangePicker;
        }
    } else {
        BOOL needNewPicker = picker == nil || [picker isKindOfClass:[HEMThermostatRangePicker class]];
        if (needNewPicker) {
            [picker removeFromSuperview]; // in case there is one
            
            HEMAlarmValueRangePickerView* scrollablePicker = [HEMAlarmValueRangePickerView defaultRangePickerView];
            
            if (isThermostat) {
                [scrollablePicker setUnitSymbol:NSLocalizedString(@"measurement.temperature.unit", nil)];
            } else {
                [scrollablePicker setUnitSymbol:NSLocalizedString(@"measurement.percentage.unit", nil)];
            }
            
            [scrollablePicker setAlpha:0.0f];
            [scrollablePicker setTag:kHEMAlarmExpPickerTag];
            [scrollablePicker setSelectedMaxValue:[self defaultTargetMinValue]];
            [scrollablePicker setSelectedMinValue:[self defaultTargetMaxValue]];
            [scrollablePicker setPickerDelegate:self];
            [scrollablePicker configureWithMin:[self expansionValueRange].min
                                           max:[self expansionValueRange].max];
            [scrollablePicker setFrame:[[self targetValueContainer] bounds]];
            
            [[self targetValueContainer] insertSubview:scrollablePicker atIndex:0];
            
            picker = scrollablePicker;
        }
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        [picker setAlpha:1.0f];
    }];
}

- (void)showPickerLoadingState {
    UIView* picker = [[self targetValueContainer] viewWithTag:kHEMAlarmExpPickerTag];
    [picker setHidden:YES];
    [[self targetValueActivityIndicator] start];
    [[self targetValueActivityIndicator] setHidden:NO];
}

#pragma mark - Load data

- (void)loadExpansionConfigurations {
    [self setLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getConfigurationsForExpansion:[self expansion] completion:^(id configs, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setConfigs:configs];
        [strongSelf setConfigError:error];
        
        for (SENExpansionConfig* config in configs) {
            if ([config isSelected]) {
                [strongSelf setSelectedConfig:config];
                break;
            }
        }
        
        [strongSelf setLoading:NO];
        [strongSelf showTargetValuePicker];
        [[strongSelf tableView] reloadData];
    }];
}

#pragma mark - Presenter events

- (void)wasRemovedFromParent {
    [super wasRemovedFromParent];
    
    SENExpansionConfig* updatedConfig = nil;
    if (![[self selectedConfig] isSelected]) {
        updatedConfig = [self selectedConfig];
    }
    
    id pickerView = [[self targetValueContainer] viewWithTag:kHEMAlarmExpPickerTag];
    if ([pickerView isKindOfClass:[HEMThermostatRangePicker class]]) {
        HEMThermostatRangePicker* thermoPicker = pickerView;
        [self updateThermostatTargetRangeWithMin:[[thermoPicker minLabel] currentValue]
                                             max:[[thermoPicker maxLabel] currentValue]];
    }
    
    [[self delegate] updatedAlarmExpansion:[self alarmExpansion]
                withExpansionConfiguration:updatedConfig];
}

- (void)didRelayout {
    [super didRelayout];
    
    NSInteger rowCount = [[self rows] count];
    CGFloat rowTotalHeight = rowCount * kHEMAlarmExpRowHeight;
    CGFloat viewPortHeight = CGRectGetHeight([[self tableView] bounds]);
    
    UIView* tableHeaderView = [[self tableView] tableHeaderView];
    CGRect headerFrame = [tableHeaderView frame];
    headerFrame.size.height = viewPortHeight - rowTotalHeight;
    [tableHeaderView setFrame:headerFrame];
    
    // required to cause it to adjust content size
    [[self tableView] setTableHeaderView:tableHeaderView];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self rows] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* rowType = [self rows][[indexPath row]];
    NSString* reuseId = nil;
    switch ([rowType unsignedIntegerValue]) {
        case HEMAlarmExpSetupRowTypeEnable:
            reuseId = [HEMMainStoryboard toggleReuseIdentifier];
            break;
        case HEMAlarmExpSetupRowTypeConfigSelection:
            reuseId = [HEMMainStoryboard configurationReuseIdentifier];
        default:
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMBasicTableViewCell* bCell = (id) cell;
    NSString* title = nil;
    NSString* detail = nil;
    BOOL showLoading = NO;
    UIColor* detailColor = [UIColor grey4];
    
    NSNumber* rowType = [self rows][[indexPath row]];
    switch ([rowType unsignedIntegerValue]) {
        defaut:
        case HEMAlarmExpSetupRowTypeEnable: {
            title = NSLocalizedString(@"expansion.action.enable", nil);
            UISwitch* enableSwitch = (UISwitch*) [bCell customAccessoryView];
            [enableSwitch setOn:[[self alarmExpansion] isEnable]];
            [enableSwitch addTarget:self
                             action:@selector(toggleEnable:)
                   forControlEvents:UIControlEventValueChanged];
            break;
        }
        case HEMAlarmExpSetupRowTypeConfigSelection:
            title = [[self expansionService] configurationNameForExpansion:[self expansion]];
            detail = [[self selectedConfig] localizedName];
            if (!detail && [self configError]) {
                detail = [NSLocalizedString(@"actions.retry", nil) lowercaseString];
                detailColor = [UIColor tintColor];
            } else if (!detail) {
                detail = NSLocalizedString(@"expansion.config.select", nil);
                detailColor= [UIColor tintColor];
            }
            showLoading = [self isLoading];
            break;
    }
    
    [[bCell customTitleLabel] setText:title];
    [[bCell customTitleLabel] setFont:[UIFont body]];
    [[bCell customTitleLabel] setTextColor:[UIColor grey6]];
    
    [[bCell customDetailLabel] setText:detail];
    [[bCell customDetailLabel] setFont:[UIFont body]];
    [[bCell customDetailLabel] setTextColor:detailColor];
    
    [bCell showActivity:showLoading];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* rowType = [self rows][[indexPath row]];
    switch ([rowType unsignedIntegerValue]) {
        case HEMAlarmExpSetupRowTypeEnable:
            return NO;
        default:
            return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber* rowType = [self rows][[indexPath row]];
    switch ([rowType unsignedIntegerValue]) {
        case HEMAlarmExpSetupRowTypeConfigSelection:
            if (![self isLoading]) {
                if ([[self configs] count] > 0) {
                    [self showConfigurationOptions];
                } else if ([self configError]) {
                    [self loadExpansionConfigurations];
                    [tableView reloadData];
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark - TableView convenience methods

- (UIView *)configurationTitleView {
    NSString* configurationName = [[self expansionService] configurationNameForExpansion:[self expansion]];
    NSString* titleFormat = NSLocalizedString(@"alarm.expansion.configuration.selection.title.format", nil);
    NSString* title = [NSString stringWithFormat:titleFormat, [configurationName lowercaseString]];
    
    NSString* message = nil;
    switch ([[self expansion] type]) {
        default:
        case SENExpansionTypeThermostat:
            message = NSLocalizedString(@"alarm.expansion.thermostat.selection.subtitle", nil);
            break;
        case SENExpansionTypeLights:
            message = NSLocalizedString(@"alarm.expansion.lights.selection.subtitle", nil);
    }
    
    NSAttributedString* attrDesc = [HEMActionSheetTitleView attributedDescriptionFromText:message];
    return [[HEMActionSheetTitleView alloc] initWithTitle:title andDescription:attrDesc];
}

- (void)showConfigurationOptions {
    if ([[self configs] count] == 0) {
        // TODO: show error?
        return;
    }
    
    HEMActionSheetViewController* sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setCustomTitleView:[self configurationTitleView]];
    
    __weak typeof (self) weakSelf = self;
    
    for (SENExpansionConfig* config in [self configs]) {
        BOOL selected = NO;
        // check against the selectedConfig in case the cached list of configs
        // has not reloaded in time after selection.
        if ([config isEqual:[self selectedConfig]]) {
            selected = YES;
        }
        
        [sheet addOptionWithTitle:[config localizedName]
                       titleColor:[UIColor grey7]
                      description:nil
                        imageName:nil
                         selected:selected
                           action:^{
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               [strongSelf useConfig:config];
                           }];
    }
    
    [[self actionDelegate] showController:sheet fromPresenter:self];
}

- (void)useConfig:(SENExpansionConfig*)config {
    if (config == [self selectedConfig]) {
        return; // ignore
    }
    
    NSString* updateText = NSLocalizedString(@"status.updating", nil);
    
    __weak typeof(self) weakSelf = self;
    [self showActivity:updateText completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf expansionService] setConfiguration:config
                                           forExpansion:[strongSelf expansion]
                                             completion:^(SENExpansion * expansion, NSError * error) {
                                                 if (error) {
                                                     [strongSelf showConfigurationUpdateError];
                                                 } else {
                                                     [strongSelf setSelectedConfig:config];
                                                     if ([[strongSelf expansion] type] == SENExpansionTypeThermostat) {
                                                         [strongSelf showTargetValuePicker];
                                                     }
                                                     [[strongSelf tableView] reloadData];
                                                     [strongSelf dismissActivitySucessfully:YES completion:nil];
                                                 }
                                             }];
    }];
}

#pragma mark - Errors

- (void)showConfigurationUpdateError {
    NSString* title = NSLocalizedString(@"alarm.expansion.error.cannot-set-config.title", nil);
    NSString* message = NSLocalizedString(@"alarm.expansion.error.cannot-set-config.message", nil);
    [[self errorDelegate] showErrorWithTitle:title
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

#pragma mark - Activity

- (void)showActivity:(NSString*)text completion:(void(^)(void))completion {
    if ([[self activityCoverView] isShowing]) {
        [[self activityCoverView] updateText:text completion:^(BOOL finished) {
            if (completion) {
                completion ();
            }
        }];
    } else {
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        [activityView showInView:[self activityContainerView]
                        withText:text
                        activity:YES
                      completion:completion];
        [self setActivityCoverView:activityView];
    }
}

- (void)dismissActivitySucessfully:(BOOL)success completion:(void(^)(void))completion {
    if ([[self activityCoverView] isShowing]) {
        NSString* text = nil;
        if (success) {
            text = NSLocalizedString(@"actions.done", nil);
        }
        
        [[self activityCoverView] dismissWithResultText:text
                                        showSuccessMark:success
                                                 remove:YES
                                             completion:completion];
    }
}

#pragma mark - Picker values

- (void)updateThermostatTargetRangeWithMin:(CGFloat)min max:(CGFloat)max {
    SENExpansionValueRange valueRange;
    valueRange.min = min;
    valueRange.max = max;
    valueRange.setpoint = max;
    
    if ([SENPreference temperatureFormat] == SENTemperatureFormatFahrenheit) {
        // this means values from picker will be in fahrenheit
        valueRange = [[self expansionService] convertThermostatRangeToCelsis:valueRange];
    }
    
    [[self alarmExpansion] setTargetRange:valueRange];
}

#pragma mark - HEMAlarmValueRangePickerDelegate

- (void)didUpdateSelectedValuesFrom:(HEMAlarmValueRangePickerView*)pickerView {
    if ([[self expansion] type] == SENExpansionTypeThermostat) {
        [self updateThermostatTargetRangeWithMin:[pickerView selectedMinValue]
                                             max:[pickerView selectedMaxValue]];
    } else {
        SENExpansionValueRange valueRange;
        valueRange.min = [pickerView selectedMinValue];
        valueRange.max = [pickerView selectedMaxValue];
        valueRange.setpoint = [pickerView selectedMaxValue];
        [[self alarmExpansion] setTargetRange:valueRange];
    }
}

#pragma mark - Actions

- (void)toggleEnable:(UISwitch*)enableSwitch {
    [[self alarmExpansion] setEnable:[enableSwitch isOn]];
}

- (void)showInfo {
    switch ([[self expansion] type]) {
        case SENExpansionTypeLights:
            return [[self actionDelegate] showLightsExpansionInfoFrom:self];
        case SENExpansionTypeThermostat:
            return [[self actionDelegate] showThermostatExpansionInfoFrom:self];
        default:
            return;
    }
}

@end
