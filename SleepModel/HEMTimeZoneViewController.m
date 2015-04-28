//
//  HEMTimeZoneViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/17/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "NSTimeZone+HEMUtils.h"

#import "UIFont+HEMStyle.h"

#import <SenseKit/SENAPITimeZone.h>

#import "HEMTimeZoneViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMActivityCoverView.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSettingsTableViewCell.h"

@interface HEMTimeZoneViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary* displayNamesToTimeZone;
@property (strong, nonatomic) NSArray* sortedDisplayNames;
@property (copy,   nonatomic) NSString* selectedTimeZoneName;
@property (copy,   nonatomic) NSString* configuredTimeZoneName;

@end

@implementation HEMTimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureTableView];
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
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
        }
        [weakSelf setConfiguredTimeZoneName:[tz displayNameForCurrentLocale]];
        completion ();
    }];
}

- (void)loadTimeZoneDataSources:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setDisplayNamesToTimeZone:[NSTimeZone supportedTimeZoneByDisplayNames]];
        
        NSArray* sortedArray = [[strongSelf displayNamesToTimeZone] allKeys];
        sortedArray = [sortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        [strongSelf setSortedDisplayNames:sortedArray];
        
        dispatch_async(dispatch_get_main_queue(), completion);
        
    });
}

- (void)updateTimeZoneTo:(NSTimeZone*)timeZone withName:(NSString*)displayName {
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    NSString* text = NSLocalizedString(@"timezone.activity.message", nil);
    
    NSString* previousConfiguredTzName = [[self configuredTimeZoneName] copy];
    [self setConfiguredTimeZoneName:displayName];
    
    [activityView showInView:[[self navigationController] view] withText:text activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        [SENAPITimeZone setTimeZone:timeZone completion:^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = self;
            BOOL hasError = error != nil;
            
            if (!hasError) {
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
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                }];
            }
            
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self sortedDisplayNames] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard timezoneReuseIdentifier]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* displayName = [self sortedDisplayNames][[indexPath row]];
    BOOL isSelected = [displayName isEqualToString:[self configuredTimeZoneName]];
    
    HEMSettingsTableViewCell* settingsCell = (id)cell;
    [settingsCell setTag:[indexPath row]];
    [[settingsCell titleLabel] setText:[self sortedDisplayNames][[indexPath row]]];
    [[settingsCell accessory] setHidden:!isSelected];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray* visibleCells = [tableView visibleCells];
    for (HEMSettingsTableViewCell* cell in visibleCells) {
        [[cell accessory] setHidden:[cell tag] != [indexPath row]];
    }
    
    NSString* displayName = [self sortedDisplayNames][[indexPath row]];
    NSTimeZone* timeZone = [self displayNamesToTimeZone][displayName];
    [self updateTimeZoneTo:timeZone withName:displayName];
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
