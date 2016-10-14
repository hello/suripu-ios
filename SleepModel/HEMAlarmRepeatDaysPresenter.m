//
//  HEMAlarmRepeatDaysPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 4/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAlarm.h>

#import "HEMAlarmRepeatDaysPresenter.h"
#import "HEMListItemCell.h"
#import "HEMAlarmService.h"

@interface HEMAlarmRepeatDaysPresenter()

@property (nonatomic, strong) HEMAlarmCache* cache;
@property (nonatomic, strong) SENAlarm* currentAlarm;
@property (nonatomic, copy) NSString* navTitle;
@property (nonatomic, weak) HEMAlarmService* alarmService;

@end

@implementation HEMAlarmRepeatDaysPresenter

- (instancetype)initWithNavTitle:(NSString*)title
                        subtitle:(NSString*)subtitle
                      alarmCache:(HEMAlarmCache*)cache
                         basedOn:(SENAlarm*)alarm
                     withService:(HEMAlarmService*)service {
    
    self = [super initWithTitle:subtitle items:nil selectedItemNames:nil];
    if (self) {
        _navTitle = [title copy];
        _cache = cache;
        _currentAlarm = alarm;
        _alarmService = service;
        
        [self setItems:@[NSLocalizedString(@"alarm.repeat.days.sunday", nil),
                         NSLocalizedString(@"alarm.repeat.days.monday", nil),
                         NSLocalizedString(@"alarm.repeat.days.tuesday", nil),
                         NSLocalizedString(@"alarm.repeat.days.wednesday", nil),
                         NSLocalizedString(@"alarm.repeat.days.thursday", nil),
                         NSLocalizedString(@"alarm.repeat.days.friday", nil),
                         NSLocalizedString(@"alarm.repeat.days.saturday", nil)]];
        
        [self configureSelectedItems];
    }
    return self;
}

- (void)bindWithNavigationItem:(UINavigationItem *)navItem {
    [super bindWithNavigationItem:navItem];
    [navItem setTitle:[self navTitle]];
}

- (void)bindWithTableView:(UITableView*)tableView {
    [super bindWithTableView:tableView];
    [tableView setAllowsMultipleSelection:YES];
}

- (void)configureSelectedItems {
    NSMutableArray* selectedNames = [NSMutableArray arrayWithCapacity:[[self items] count]];
    for (NSString* day in [self items]) {
        if ([self isItemSelected:day]) {
            [selectedNames addObject:day];
        }
    }
    [self setSelectedItemNames:selectedNames];
}

- (SENAlarmRepeatDays)repeatDayItem:(id)item {
    NSInteger index = [[self items] indexOfObject:item];
    return 1UL << (index + 1);
}

- (BOOL)isItemSelected:(id)item {
    SENAlarmRepeatDays day = [self repeatDayItem:item];
    SENAlarmRepeatDays selectedDays = [[self cache] repeatFlags];
    BOOL selected = (selectedDays & day) == day;
    return selected;
}

#pragma mark - Overrides

- (BOOL)hideExtraNavigationBar {
    return YES;
}

#pragma mark -

- (NSInteger)indexOfItemWithName:(NSString*)name {
    NSInteger index = -1;
    NSInteger dayIndex = 0;
    for (NSString* dayName in [self items]) {
        if ([dayName isEqualToString:name]) {
            index = dayIndex;
            break;
        }
        dayIndex++;
    }
    return index;
}

- (void)updateCell:(UITableViewCell *)cell withItem:(id)item selected:(BOOL)selected {
    SENAlarmRepeatDays selectedDay = [self repeatDayItem:item];
    SENAlarmRepeatDays currentSelection = [[self cache] repeatFlags];
    
    if (selected) {
        BOOL canAdd = [[self alarmService] canAddRepeatDay:selectedDay
                                                        to:[self cache]
                                                 excluding:[self currentAlarm]];
        if (canAdd) {
            [[self cache] setRepeatFlags:currentSelection | selectedDay];
        } else {
            NSString* title = NSLocalizedString(@"alarm.repeat.day-reuse-error.title", nil);
            NSString* message = NSLocalizedString(@"alarm.repeat.day-reuse-error.message", nil);
            [[self presenterDelegate] presentErrorWithTitle:title message:message from:self];
            return; // don't let it update
        }
        
    } else { // remove
        [[self cache] setRepeatFlags:currentSelection & ~selectedDay];
    }
    
    [super updateCell:cell withItem:item selected:selected];
}

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    [[cell itemLabel] setText:item];
    [cell setSelected:[self isItemSelected:item]];
}

@end
