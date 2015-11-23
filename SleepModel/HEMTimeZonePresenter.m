//
//  HEMTimeZonePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "UITableViewCell+HEMSettings.h"
#import "UIBarButtonItem+HEMNav.h"

#import "HEMTimeZonePresenter.h"
#import "HEMMainStoryboard.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"
#import "HEMSettingsHeaderFooterView.h"

typedef NS_ENUM(NSInteger, HEMTimeZoneSection) {
    HEMTimeZoneSectionCurrent = 0,
    HEMTimeZoneSectionOther = 1,
    HEMTimeZoneSections = 2
};

@interface HEMTimeZonePresenter() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) HEMTimeZoneService* service;
@property (weak, nonatomic) HEMBaseController* controller;
@property (weak, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSTimeZone* currentTimeZone;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* timeZoneCodeMapping;
@property (strong, nonatomic) NSArray<NSString*>* sortedTimeZoneNames;
@property (copy, nonatomic) HEMTimeZonePresenterDoneBlock doneAction;

@end

@implementation HEMTimeZonePresenter

- (nonnull instancetype)initWithService:(nonnull HEMTimeZoneService*)service
                             controller:(nonnull HEMBaseController*)controller {
    self = [super init];
    if (self) {
        _service = service;
        _controller = controller;
    }
    return self;
}

- (void)bindNavigationItem:(nonnull UINavigationItem*)navigationItem withAction:(nonnull SEL)action {
    NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* item = [UIBarButtonItem cancelItemWithTitle:cancelText
                                                           image:nil
                                                          target:[self controller]
                                                          action:action];
    [navigationItem setLeftBarButtonItem:item];
}

- (void)bindTableView:(nonnull UITableView*)tableView whenDonePerform:(nonnull HEMTimeZonePresenterDoneBlock)action {
    __block typeof(tableView) blockTable = tableView;
    
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    
    [tableView setTableHeaderView:header];
    [tableView setTableFooterView:footer];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [self setDoneAction:action];
    [self setTableView:tableView];
    
    HEMActivityCoverView* busyView = [[HEMActivityCoverView alloc] init];
    
    dispatch_group_t dataLoaders = dispatch_group_create();
    dispatch_group_enter(dataLoaders); // get current time zone
    dispatch_group_enter(dataLoaders); // get time zone mapping
    
    __weak typeof(self) weakSelf = self;
    
    [busyView showInView:[[self controller] view]  activity:YES completion:^{
        [[self service] getConfiguredTimeZone:^(NSTimeZone * _Nullable timeZone) {
            [weakSelf setCurrentTimeZone:timeZone];
            dispatch_group_leave(dataLoaders);
        }];
        
        [[self service] getTimeZones:^(NSDictionary * _Nonnull tzMapping, NSArray * _Nonnull sortedTzNames) {
            [weakSelf setTimeZoneCodeMapping:tzMapping];
            [weakSelf setSortedTimeZoneNames:sortedTzNames];
            dispatch_group_leave(dataLoaders);
        }];
    }];
    
    dispatch_group_notify(dataLoaders, dispatch_get_main_queue(), ^{
        [weakSelf removeCurrentTimeZoneFromDataSource];
        [blockTable reloadData];
        [busyView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:nil];
    });
}

- (void)removeCurrentTimeZoneFromDataSource {
    NSArray<NSString*>* cityNames = [[self timeZoneCodeMapping] allKeys];
    NSString* currentTimeZoneName = [[self currentTimeZone] name];
    NSString* matchingCityName = nil;
    for (NSString* city in cityNames) {
        NSString* timeZoneName = [self timeZoneCodeMapping][city];
        if ([timeZoneName isEqualToString:currentTimeZoneName]) {
            matchingCityName = city;
            break;
        }
    }
    
    if (matchingCityName) {
        NSMutableDictionary* updatedMapping = [[self timeZoneCodeMapping] mutableCopy];
        [updatedMapping removeObjectForKey:matchingCityName];
        [self setTimeZoneCodeMapping:updatedMapping];
        
        NSRange fullRange = NSMakeRange(0, [[self sortedTimeZoneNames] count]);
        NSMutableArray* mutableNames = [[self sortedTimeZoneNames] mutableCopy];
        NSInteger foundIndex = [mutableNames indexOfObject:matchingCityName
                                             inSortedRange:fullRange
                                                   options:NSBinarySearchingFirstEqual
                                           usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                               return [obj1 compare:obj2];
                                           }];
        if (foundIndex != NSNotFound) {
            [mutableNames removeObjectAtIndex:foundIndex];
            [self setSortedTimeZoneNames:mutableNames];
        }
    }
}

- (void)updateTimeZoneTo:(NSTimeZone*)timeZone {
    __block NSTimeZone* previousTZ = [self currentTimeZone];
    [self setCurrentTimeZone:timeZone];
    
    NSString* text = NSLocalizedString(@"timezone.activity.message", nil);
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    UINavigationController* nav = [[self controller] navigationController];
    [activityView showInView:[nav view] withText:text activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        [[self service] updateToTimeZone:timeZone completion:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error) {
                [strongSelf setCurrentTimeZone:previousTZ];
                [[strongSelf tableView] reloadData];
                [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [[strongSelf controller] showMessageDialog:NSLocalizedString(@"timezone.error.message", nil)
                                                         title:NSLocalizedString(@"timezone.error.title", nil)];
                }];
            } else {
                UIImage* successIcon = [HelloStyleKit check];
                NSString* successText = NSLocalizedString(@"status.success", nil);
                
                [[activityView indicator] setHidden:YES];
                [activityView updateText:successText successIcon:successIcon hideActivity:YES completion:^(BOOL finished) {
                    [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                        NSTimeInterval delayInSeconds = 0.5f;
                        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                            [strongSelf doneAction] ();
                        });
                    }];
                }];
            }
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return HEMTimeZoneSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEMSettingsHeaderFooterHeightWithTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == HEMTimeZoneSectionCurrent ? HEMSettingsHeaderFooterHeight : 0.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HEMSettingsHeaderFooterView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    switch (section) {
        default:
        case HEMTimeZoneSectionCurrent:
            [header setTitle:[NSLocalizedString(@"timezone.section.title.current", nil) uppercaseString]];
            break;
        case HEMTimeZoneSectionOther:
            [header setTitle:[NSLocalizedString(@"timezone.section.title.other", nil) uppercaseString]];
            break;
    }
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == HEMTimeZoneSectionCurrent ? 1 : [[self sortedTimeZoneNames] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard timezoneReuseIdentifier]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sec = [indexPath section];
    NSString* timeZoneName = nil;
    BOOL isSelected = NO;
    
    if (sec == HEMTimeZoneSectionCurrent) {
        timeZoneName = [[self currentTimeZone] name];
        isSelected = YES;
    } else {
        NSString* city = [self sortedTimeZoneNames][[indexPath row]];
        timeZoneName = [self timeZoneCodeMapping][city];
    }
    
    [[cell textLabel] setTextColor:[UIColor settingsCellTitleTextColor]];
    [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
    [[cell textLabel] setText:timeZoneName];
    [cell setTag:[indexPath row]];
    [cell setAccessorySelection:isSelected];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger sec = [indexPath section];
    
    if (sec == HEMTimeZoneSectionOther) {
        NSArray* visibleCells = [tableView visibleCells];
        for (UITableViewCell* cell in visibleCells) {
            [cell setAccessorySelection:[cell tag] == [indexPath row]];
        }
        
        // make sure to uncheck current
        NSIndexPath* currentPath = [NSIndexPath indexPathForRow:0 inSection:HEMTimeZoneSectionCurrent];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:currentPath];
        [cell setAccessorySelection:NO];
        
        NSString* city = [self sortedTimeZoneNames][[indexPath row]];
        NSString* timeZoneName = [self timeZoneCodeMapping][city];
        [self updateTimeZoneTo:[NSTimeZone timeZoneWithName:timeZoneName]];
    }

}

@end
