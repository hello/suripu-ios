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

@interface HEMTimeZoneViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary* displayNamesToTimeZone;
@property (strong, nonatomic) NSArray* sortedDisplayNames;

@end

@implementation HEMTimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self buildTimeZoneSource];
}

- (void)configureNavigationBar {
    NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithTitle:cancelText
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(cancel:)];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
}

- (void)buildTimeZoneSource {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setDisplayNamesToTimeZone:[NSTimeZone supportedTimeZoneByDisplayNames]];
        
        NSArray* sortedArray = [[strongSelf displayNamesToTimeZone] allKeys];
        sortedArray = [sortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        [strongSelf setSortedDisplayNames:sortedArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[strongSelf tableView] reloadData];
        });
        
    });
}

- (void)updateTimeZoneTo:(NSTimeZone*)timeZone {
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    NSString* text = NSLocalizedString(@"timezone.activity.message", nil);
    
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
                            [[strongSelf delegate] didUpdateTimeZoneTo:timeZone from:strongSelf];
                            [strongSelf dismissViewControllerAnimated:YES completion:nil];
                        });
                    }];
                }];
            } else {
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

#pragma mark - Actions

- (void)cancel:(id)sender {
    [[self delegate] willCancelTimeZoneUpdateFrom:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
