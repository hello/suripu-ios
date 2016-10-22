//
//  HEMAlarmExpansionSetupPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIBarButtonItem+HEMNav.h"

#import "HEMActionSheetViewController.h"
#import "HEMAlarmExpansionSetupPresenter.h"
#import "HEMAlarmValueRangePickerView.h"
#import "HEMExpansionService.h"
#import "HEMMainStoryboard.h"
#import "HEMBasicTableViewCell.h"
#import "HEMStyle.h"

static CGFloat const kHEMAlarmExpRowHeight = 66.0f;

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
@property (nonatomic, strong) NSArray<NSNumber*>* rows;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSArray<SENExpansionConfig*>* configs;
@property (nonatomic, strong) NSError* configError;

@property (nonatomic, strong) SENExpansionConfig* selectedConfig;
@property (nonatomic, strong) SENAlarmExpansion* alarmExpansion;

@end

@implementation HEMAlarmExpansionSetupPresenter

- (instancetype)initWithExpansion:(SENExpansion*)expansion
                   alarmExpansion:(SENAlarmExpansion*)alarmExpansion
                 expansionService:(HEMExpansionService*)expansionService {
    if (self = [super init]) {
        _expansion = expansion;
        _expansionService = expansionService;
        _alarmExpansion = alarmExpansion;
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
    
    SENExpansionType type = [[self expansion] type];
    HEMAlarmValueRangePickerView* picker = (id) [tableView tableHeaderView];
    [picker setSelectedMaxValue:[[self alarmExpansion] targetRange].max];
    [picker setSelectedMinValue:[[self alarmExpansion] targetRange].min];
    [picker setPickerDelegate:self];
    
    SENExpansionValueRange valueRange = [[self expansion] valueRange];
    if (type == SENExpansionTypeThermostat) {
        [picker setUnitSymbol:NSLocalizedString(@"measurement.temperature.unit", nil)];
        [picker configureRangeWithMin:valueRange.min max:valueRange.max];
    } else {
        [picker setUnitSymbol:NSLocalizedString(@"measurement.percentage.unit", nil)];
        [picker configureWithMin:valueRange.min max:valueRange.max];
    }
    
    [self setTableView:tableView];
    [self loadExpansinConfigurations];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    [navItem setRightBarButtonItem:[UIBarButtonItem infoButtonWithTarget:self
                                                                  action:@selector(showInfo)]];
}

#pragma mark - Load data

- (void)loadExpansinConfigurations {
    [self setLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getConfigurationsForExpansion:[self expansion] completion:^(id configs, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setConfigs:configs];
        [strongSelf setConfigError:error];
        [strongSelf setLoading:NO];
        [[strongSelf tableView] reloadData];
    }];
}

#pragma mark - Presenter events

- (void)wasRemovedFromParent {
    [super wasRemovedFromParent];
    [[self delegate] updatedAlarmExpansion:[self alarmExpansion]
                withExpansionConfiguration:[self selectedConfig]];
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
            detail = [self selectedConfigurationName];
            showLoading = [self isLoading];
            break;
    }
    
    [[bCell customTitleLabel] setText:title];
    [[bCell customTitleLabel] setFont:[UIFont body]];
    [[bCell customTitleLabel] setTextColor:[UIColor grey6]];
    
    [[bCell customDetailLabel] setText:detail];
    [[bCell customDetailLabel] setFont:[UIFont body]];
    [[bCell customDetailLabel] setTextColor:[UIColor grey4]];
    
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
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark - TableView convenience methods

- (void)showConfigurationOptions {
    if ([[self configs] count] == 0) {
        // TODO: show error?
        return;
    }
    
    HEMActionSheetViewController* sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    NSString* configurationName = [[self expansionService] configurationNameForExpansion:[self expansion]];
    NSString* titleFormat = NSLocalizedString(@"expansion.configuration.options.title.format", nil);
    [sheet setTitle:[[NSString stringWithFormat:titleFormat, configurationName] uppercaseString]];
    
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
    [self setSelectedConfig:config];
    [[self tableView] reloadData];
}

- (NSString*)selectedConfigurationName {
    NSString* selection = nil;
    if ([self selectedConfig]) {
        selection = [[self selectedConfig] localizedName];
    } else {
        for (SENExpansionConfig* config in [self configs]) {
            if ([config isSelected]) {
                selection = [config localizedName];
                [self setSelectedConfig:config];
                break;
            }
        }
    }
    return selection;
}

#pragma mark - HEMAlarmValueRangePickerDelegate

- (void)didUpdateSelectedValuesFrom:(HEMAlarmValueRangePickerView*)pickerView {
    SENExpansionValueRange valueRange;
    valueRange.min = [pickerView selectedMinValue];
    valueRange.max = [pickerView selectedMaxValue];
    [[self alarmExpansion] setTargetRange:valueRange];
}

#pragma mark - Actions

- (void)toggleEnable:(UISwitch*)enableSwitch {
    [[self alarmExpansion] setEnable:[enableSwitch isOn]];
}

- (void)showInfo {
    [[self actionDelegate] showExpansionInfoFrom:self];
}

@end
