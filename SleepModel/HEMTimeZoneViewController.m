//
//  HEMTimeZoneViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/17/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"
#import "NSTimeZone+HEMMapping.h"

#import <SenseKit/SENAPITimeZone.h>

#import "HEMTimeZoneViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMActivityCoverView.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSettingsTableViewCell.h"

static NSString* const HEMTimeZonesResourceName = @"TimeZones";

@interface HEMTimeZoneViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary* timeZonesByCities;
@property (strong, nonatomic) NSArray* sortedCities;
@property (copy,   nonatomic) NSString* selectedTimeZoneName;
@property (copy,   nonatomic) NSString* configuredTimeZoneName;

@end

@implementation HEMTimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureTableView];
    
    [SENAnalytics track:HEMAnalyticsEventTimeZone];
}

- (void)configureNavigationBar {
    NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithTitle:cancelText
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(cancel:)];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
}

- (void)configureTableView {
    __block BOOL loadedConfiguredTz = NO;
    __block BOOL loadedTableViewDs = NO;
    __weak typeof(self) weakSelf = self;
    
    HEMActivityCoverView* busyView = [[HEMActivityCoverView alloc] init];

    void(^show)(void) = ^{
        if (loadedConfiguredTz && loadedTableViewDs) {
            [[weakSelf tableView] reloadData];
            [busyView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:nil];
        }
    };
    
    [busyView showInView:[self view] activity:YES completion:^{
        [self loadConfiguredTimeZone:^{
            loadedConfiguredTz = YES;
            show();
        }];
        
        [self loadTimeZoneDataSources:^{
            loadedTableViewDs = YES;
            show();
        }];
    }];

}

- (void)loadConfiguredTimeZone:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPITimeZone getConfiguredTimeZone:^(NSTimeZone* tz, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [weakSelf setConfiguredTimeZoneName:[tz name]];
        }
        completion ();
    }];
}

- (void)loadTimeZoneDataSources:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setTimeZonesByCities:[NSTimeZone timeZoneMapping]];
        
        NSArray* sortedArray = [[strongSelf timeZonesByCities] allKeys];
        sortedArray = [sortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        [strongSelf setSortedCities:sortedArray];
        
        dispatch_async(dispatch_get_main_queue(), completion);
        
    });
}

- (void)updateTimeZoneTo:(NSTimeZone*)timeZone {
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    NSString* text = NSLocalizedString(@"timezone.activity.message", nil);
    
    NSString* previousConfiguredTzName = [[self configuredTimeZoneName] copy];
    [self setConfiguredTimeZoneName:[timeZone name]];
    
    [activityView showInView:[[self navigationController] view] withText:text activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        [SENAPITimeZone setTimeZone:timeZone completion:^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = self;
            BOOL hasError = error != nil;
            
            if (!hasError) {
                NSString* tz = [timeZone name] ?: @"unknown";
                [SENAnalytics track:HEMAnalyticsEventTimeZoneChanged
                         properties:@{HEMAnalyticsEventPropTZ : tz}];
                
                UIImage* successIcon = [HelloStyleKit check];
                NSString* successText = NSLocalizedString(@"status.success", nil);
                
                [[activityView indicator] setHidden:YES];
                [activityView updateText:successText successIcon:successIcon hideActivity:YES completion:^(BOOL finished) {
                    [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                        NSTimeInterval delayInSeconds = 0.5f;
                        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                            [strongSelf dismissViewControllerAnimated:YES completion:nil];
                        });
                    }];
                }];
            } else {
                [strongSelf setConfiguredTimeZoneName:previousConfiguredTzName];
                
                [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showMessageDialog:NSLocalizedString(@"timezone.error.message", nil)
                                            title:NSLocalizedString(@"timezone.error.title", nil)];
                    [SENAnalytics trackError:error];
                }];
            }
            
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self sortedCities] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard timezoneReuseIdentifier]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* city = [self sortedCities][[indexPath row]];
    NSString* timeZoneName = [self timeZonesByCities][city];
    BOOL isSelected = [timeZoneName isEqualToString:[self configuredTimeZoneName]];
    
    HEMSettingsTableViewCell* settingsCell = (id)cell;
    [settingsCell setTag:[indexPath row]];
    [[settingsCell titleLabel] setText:city];
    [[settingsCell accessory] setHidden:!isSelected];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray* visibleCells = [tableView visibleCells];
    for (HEMSettingsTableViewCell* cell in visibleCells) {
        [[cell accessory] setHidden:[cell tag] != [indexPath row]];
    }
    
    NSString* city = [self sortedCities][[indexPath row]];
    NSString* timeZoneName = [self timeZonesByCities][city];
    [self updateTimeZoneTo:[NSTimeZone timeZoneWithName:timeZoneName]];
}

#pragma mark - Actions

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Clean Up

- (void)dealloc {
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
}

@end
