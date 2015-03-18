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

@interface HEMTimeZoneViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary* displayNamesToTimeZone;
@property (strong, nonatomic) NSArray* sortedDisplayNames;

@end

@implementation HEMTimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildTimeZoneSource];
}

- (void)buildTimeZoneSource {
    [self setDisplayNamesToTimeZone:[NSTimeZone supportedTimeZoneByDisplayNames]];
    
    NSArray* sortedArray = [[self displayNamesToTimeZone] allKeys];
    sortedArray = [sortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    [self setSortedDisplayNames:sortedArray];
}

- (void)updateTimeZoneTo:(NSTimeZone*)timeZone {
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    NSString* text = NSLocalizedString(@"timezone.activity.message", nil);
    
    UIViewController* root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [activityView showInView:[root view] withText:text activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        [SENAPITimeZone setTimeZone:timeZone completion:^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = self;
            NSString* finishedText = nil;
            BOOL success = NO;
            
            if (error == nil) {
                finishedText = NSLocalizedString(@"status.success", nil);
                success = YES;
                [[strongSelf navigationController] popViewControllerAnimated:YES];
            }
            
            [activityView dismissWithResultText:finishedText showSuccessMark:success remove:YES completion:^{
                if (error != nil) {
                    [strongSelf showMessageDialog:NSLocalizedString(@"timezone.error.message", nil)
                                            title:NSLocalizedString(@"timezone.error.title", nil)];
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                }
            }];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[cell textLabel] setFont:[UIFont timeZoneNameFont]];
    [[cell textLabel] setText:[self sortedDisplayNames][[indexPath row]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* displayName = [self sortedDisplayNames][[indexPath row]];
    NSTimeZone* timeZone = [self displayNamesToTimeZone][displayName];
    [self updateTimeZoneTo:timeZone];
}

@end
