#import "HEMAlarmListViewController.h"

#import <SenseKit/SenseKit.h>
#import <AttributedMarkdown/markdown_peg.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMAlarmViewController.h"
#import "HEMAlarmListCell.h"
#import "HEMAlarmAddButton.h"
#import "HEMAlarmUtils.h"
#import "HEMMainStoryboard.h"
#import "HEMMarkdown.h"
#import "HEMSensePairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMSenseRequiredCollectionViewCell.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMAlertViewController.h"
#import "HEMActionButton.h"
#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMScreenUtils.h"
#import "HEMNoAlarmCell.h"
#import "HEMActivityIndicatorView.h"

NS_ENUM(NSUInteger) {
    LoadingStateRowCount = 0,
    EmptyStateRowCount = 1,
};

@interface HEMAlarmListViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout, HEMAlarmControllerDelegate,
                                          HEMSensePairingDelegate>

@property (strong, nonatomic) NSArray *alarms;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet HEMAlarmAddButton *addButton;
@property (strong, nonatomic) NSDateFormatter *hour24Formatter;
@property (strong, nonatomic) NSDateFormatter *hour12Formatter;
@property (strong, nonatomic) NSDateFormatter *meridiemFormatter;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, getter=hasLoadingFailed) BOOL loadingFailed;
@property (nonatomic, strong) HEMSimpleModalTransitionDelegate *alarmSaveTransitionDelegate;
@property (nonatomic, getter=hasNoSense) BOOL noSense;
@property (nonatomic, strong) NSAttributedString* attributedNoAlarmText;
@end

@implementation HEMAlarmListViewController

static CGFloat const HEMAlarmListButtonMinimumScale = 0.95f;
static CGFloat const HEMAlarmListButtonMaximumScale = 1.2f;
static CGFloat const HEMAlarmListCellHeight = 96.f;
static CGFloat const HEMAlarmListPairCellHeight = 352.f;
static CGFloat const HEMAlarmListNoAlarmCellBaseHeight = 292.0f;
static CGFloat const HEMAlarmListItemSpacing = 8.f;
static CGFloat const HEMAlarmNoAlarmHorzMargin = 40.0f;
static NSString *const HEMAlarmListTimeKey = @"alarms.alarm.meridiem.%@";
static NSUInteger const HEMAlarmListLimit = 8;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"alarms.title", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"alarmBarIcon"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"alarmBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.alarmSaveTransitionDelegate = [HEMSimpleModalTransitionDelegate new];
    self.alarmSaveTransitionDelegate.wantsStatusBar = YES;
    [self configureCollectionView];
    [self configureAddButton];
    [self configureDateFormatters];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:SENAPIReachableNotification
                                               object:nil];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:kHEMAnalyticsEventAlarms];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self touchUpOutsideAddAlarmButton:nil];
}

- (void)didReceiveMemoryWarning {
    if (![self isViewLoaded] || !self.view.window) {
        self.alarms = nil;
    }
    [super didReceiveMemoryWarning];
}

- (void)configureAddButton {
    [self.addButton addTarget:self action:@selector(touchDownAddAlarmButton:) forControlEvents:UIControlEventTouchDown];
    [self.addButton addTarget:self
                       action:@selector(touchUpOutsideAddAlarmButton:)
             forControlEvents:UIControlEventTouchUpOutside];
    self.addButton.enabled = self.alarms.count < HEMAlarmListLimit;
}

- (void)configureDateFormatters {
    self.hour12Formatter = [NSDateFormatter new];
    self.hour12Formatter.dateFormat = @"hh:mm";
    self.hour24Formatter = [NSDateFormatter new];
    self.hour24Formatter.dateFormat = @"HH:mm";
    self.meridiemFormatter = [NSDateFormatter new];
    self.meridiemFormatter.dateFormat = @"a";
}

- (void)refreshData {
    if ([self isLoading])
        return;
    self.addButton.enabled = NO;
    self.noSense = NO;
    SENServiceDevice *service = [SENServiceDevice sharedService];
    if ([service isInfoLoaded]) {
        [self checkDeviceInfoForSenseAndRefresh];
    } else {
        self.loading = YES;
        [service loadDeviceInfo:^(NSError *error) {
          if (error) {
              self.noSense = NO;
              self.loadingFailed = YES;
              self.loading = NO;
              [self.collectionView reloadData];
          } else {
              [self checkDeviceInfoForSenseAndRefresh];
          }
        }];
    }
}

- (void)checkDeviceInfoForSenseAndRefresh {
    SENServiceDevice *service = [SENServiceDevice sharedService];
    BOOL hasSense = [[service devices] hasPairedSense];
    if (hasSense) {
        self.loading = YES;
        self.noSense = NO;
        [self refreshAlarmList];
    } else {
        self.noSense = YES;
        self.loading = NO;
        self.loadingFailed = NO;
        self.alarms = nil;
        self.addButton.hidden = YES;
        self.addButton.enabled = NO;
        [self.collectionView reloadData];
    }
}

- (void)refreshAlarmList {
    self.loading = !self.alarms; // only show indicator if there's no alarms at all
    [HEMAlarmUtils refreshAlarmsFromPresentingController:self
                                              completion:^(NSError *error) {
                                                  self.loading = NO;
                                                  if (error) {
                                                      self.loadingFailed = YES;
                                                      if (self.alarms.count == 0) {
                                                          [self.collectionView reloadData];
                                                          return;
                                                      }
                                                  } else {
                                                      self.loadingFailed = NO;
                                                      [self reloadData];
                                                  }
                                                  self.addButton.enabled = YES;
                                              }];
}

- (void)reloadData {
    NSArray *cachedAlarms = [self sortedCachedAlarms];
    if ([self.alarms isEqualToArray:cachedAlarms]) {
        if ([self isLoading]) {
            self.loading = NO;
            [self.collectionView reloadData];
        }
        return;
    }

    self.loading = NO;
    self.alarms = cachedAlarms;
    self.addButton.hidden = self.alarms.count == 0 || [self hasNoSense];
    self.addButton.enabled = self.alarms.count < HEMAlarmListLimit;
    [self.collectionView reloadData];
}

- (NSArray *)sortedCachedAlarms {
    return [[SENAlarm savedAlarms] sortedArrayUsingComparator:^NSComparisonResult(SENAlarm *obj1, SENAlarm *obj2) {
      NSNumber *alarmValue1 = @(obj1.hour * 60 + obj1.minute);
      NSNumber *alarmValue2 = @(obj2.hour * 60 + obj2.minute);
      NSComparisonResult result = [alarmValue1 compare:alarmValue2];
      if (result == NSOrderedSame)
          result = [@(obj1.repeatFlags) compare:@(obj2.repeatFlags)];
      return result;
    }];
}

#pragma mark - Properties

- (void)setLoading:(BOOL)loading {
    if (_loading == loading) {
        return;
    }
    
    _loading = loading;
    
    if (loading) {
        [self.loadingIndicator start];
        self.loadingIndicator.hidden = NO;
        self.collectionView.hidden = YES;
    } else {
        [self.loadingIndicator stop];
        self.loadingIndicator.hidden = YES;
        self.collectionView.hidden = NO;
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Actions

- (void)touchDownAddAlarmButton:(id)sender {
    [UIView animateWithDuration:0.05f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       self.addButton.layer.transform = CATransform3DMakeScale(HEMAlarmListButtonMinimumScale,
                                                                               HEMAlarmListButtonMinimumScale, 1.f);
                     }
                     completion:NULL];
}

- (void)touchUpOutsideAddAlarmButton:(id)sender {
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ self.addButton.layer.transform = CATransform3DIdentity; }
                     completion:NULL];
}

- (IBAction)addNewAlarm:(id)sender {
    [SENAnalytics track:HEMAnalyticsEventCreateNewAlarm];
    void (^animations)() = ^{
      [UIView addKeyframeWithRelativeStartTime:0
                              relativeDuration:0.5
                                    animations:^{
                                      self.addButton.layer.transform = CATransform3DMakeScale(
                                          HEMAlarmListButtonMaximumScale, HEMAlarmListButtonMaximumScale, 1.f);
                                    }];
      [UIView addKeyframeWithRelativeStartTime:0.5
                              relativeDuration:0.5
                                    animations:^{ self.addButton.layer.transform = CATransform3DIdentity; }];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
      SENAlarm *alarm = [SENAlarm createDefaultAlarm];
      [self presentViewControllerForAlarm:alarm];
    };

    NSUInteger options = (UIViewKeyframeAnimationOptionCalculationModeCubicPaced | UIViewAnimationOptionCurveEaseIn
                          | UIViewKeyframeAnimationOptionBeginFromCurrentState);
    [UIView animateKeyframesWithDuration:0.35f delay:0.15f options:options animations:animations completion:completion];
}

- (IBAction)flippedEnabledSwitch:(UISwitch *)sender {
    __block SENAlarm *alarm = [self.alarms objectAtIndex:sender.tag];
    BOOL on = [sender isOn];
    if (on && [HEMAlarmUtils timeIsTooSoonByHour:alarm.hour minute:alarm.minute] &&
        [HEMAlarmUtils willRingTodayWithHour:alarm.hour minute:alarm.minute repeatDays:alarm.repeatFlags]) {
        [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"alarm.save-error.too-soon.title", nil)
                                                message:NSLocalizedString(@"alarm.save-error.too-soon.message", nil)
                                             controller:self];
        sender.on = NO;
        return;
    }
    alarm.on = on;
    [SENAnalytics trackAlarmToggle:alarm];
    [HEMAlarmUtils updateAlarmsFromPresentingController:self
                                             completion:^(NSError *error) {
                                               if (error) {
                                                   alarm.on = !on;
                                                   sender.on = !on;
                                               }
                                             }];
}

- (void)presentViewControllerForAlarm:(SENAlarm *)alarm {
    UINavigationController *controller = (UINavigationController *)[HEMMainStoryboard instantiateAlarmNavController];
    controller.transitioningDelegate = self.alarmSaveTransitionDelegate;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    HEMAlarmViewController *alarmController = (HEMAlarmViewController *)controller.topViewController;
    alarmController.alarm = alarm;
    alarmController.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)pairSense:(id)sender {
    HEMSensePairViewController *pairVC
        = (HEMSensePairViewController *)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMSensePairDelegate

- (void)didPairSenseUsing:(SENSenseManager *)senseManager from:(UIViewController *)controller {
    [self refreshData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager *)senseManager from:(UIViewController *)controller {
    [self refreshData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMAlarmControllerDelegate

- (void)didCancelAlarmFrom:(HEMAlarmViewController *)alarmVC {
    [self refreshData];
    [alarmVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSaveAlarm:(SENAlarm *)alarm from:(HEMAlarmViewController *)alarmVC {
    [self refreshData];
    [alarmVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Collection View

- (void)configureCollectionView {
    CGRect bounds = HEMKeyWindowBounds();
    UICollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = HEMAlarmListItemSpacing;
    layout.minimumLineSpacing = HEMAlarmListItemSpacing;
    UIEdgeInsets sectionInsets = layout.sectionInset;
    sectionInsets.bottom = CGRectGetHeight(bounds) - CGRectGetMinY(self.addButton.frame);
    layout.sectionInset = sectionInsets;
    self.collectionView.hidden = YES;
}

#pragma mark UICollectionViewDatasource

- (NSAttributedString*)attributedNoAlarmText {
    if (!_attributedNoAlarmText) {
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineSpacing = 8.f;
        NSMutableDictionary *detailAttributes = [[HEMMarkdown attributesForBackViewText][@(PARA)] mutableCopy];
        
        NSMutableParagraphStyle *paraStyle = [detailAttributes[NSParagraphStyleAttributeName] mutableCopy];
        paraStyle.alignment = NSTextAlignmentCenter;
        detailAttributes[NSParagraphStyleAttributeName] = paraStyle;
        
        [detailAttributes removeObjectForKey:NSForegroundColorAttributeName];
        
        NSString* text = NSLocalizedString(@"alarms.no-alarm.message", nil);
        _attributedNoAlarmText = [[NSAttributedString alloc] initWithString:text attributes:detailAttributes];
    }
    return _attributedNoAlarmText;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self isLoading]) {
        return LoadingStateRowCount;
    } else if (self.alarms.count > 0) {
        return self.alarms.count;
    } else {
        return EmptyStateRowCount;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.alarms.count > 0) {
        return [self collectionView:collectionView alarmCellAtIndexPath:indexPath];
    } else if ([self hasLoadingFailed]) {
        return [self collectionView:collectionView statusCellAtIndexPath:indexPath];
    } else if ([self hasNoSense]) {
        return [self collectionView:collectionView pairingCellForItemAtIndexPath:indexPath];
    } else {
        return [self collectionView:collectionView emptyCellAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    alarmCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListCellReuseIdentifier];
    HEMAlarmListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    SENAlarm *alarm = self.alarms[indexPath.item];

    cell.enabledSwitch.on = [alarm isOn];
    cell.enabledSwitch.tag = indexPath.item;
    [self updateDetailTextInCell:cell fromAlarm:alarm];
    [self updateTimeTextInCell:cell fromAlarm:alarm];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
           pairingCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifer = [HEMMainStoryboard pairReuseIdentifier];
    HEMSenseRequiredCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifer
                                                                                         forIndexPath:indexPath];
    [[cell descriptionLabel] setText:NSLocalizedString(@"alarms.no-sense.message", nil)];
    [[cell pairSenseButton] addTarget:self action:@selector(pairSense:) forControlEvents:UIControlEventTouchUpInside];
    [[cell pairSenseButton] setTitle:[NSLocalizedString(@"alarms.no-sense.button.title", nil) uppercaseString]
                            forState:UIControlStateNormal];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    emptyCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListEmptyCellReuseIdentifier];
    HEMNoAlarmCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.detailLabel.attributedText = [self attributedNoAlarmText];
    [cell.alarmButton addTarget:self action:@selector(addNewAlarm:) forControlEvents:UIControlEventTouchUpInside];
    [cell.alarmButton setTitle:[NSLocalizedString(@"alarms.first-alarm.button-title", nil) uppercaseString]
                      forState:UIControlStateNormal];
    
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                   statusCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListStatusCellReuseIdentifier];
    HEMAlarmListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.detailLabel.text = NSLocalizedString(@"alarms.no-data", nil);
    return cell;
}

- (void)updateTimeTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm {
    cell.timeLabel.text = [self localizedTimeForAlarm:alarm];
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
        NSString *meridiem = alarm.hour < 12 ? @"am" : @"pm";
        NSString *key = [NSString stringWithFormat:HEMAlarmListTimeKey, meridiem];
        cell.meridiemLabel.text = NSLocalizedString(key, nil);
    } else { cell.meridiemLabel.text = nil; }
}

- (void)updateDetailTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm {
    NSString *detailFormat;

    if ([alarm isSmartAlarm])
        detailFormat = NSLocalizedString(@"alarms.smart-alarm.format", nil);
    else
        detailFormat = NSLocalizedString(@"alarms.alarm.format", nil);

    NSString *repeatText = [HEMAlarmUtils repeatTextForUnitFlags:alarm.repeatFlags];
    NSString *detailText = [[NSString stringWithFormat:detailFormat, repeatText] uppercaseString];
    NSDictionary *attributes = [HEMMarkdown attributesForBackViewTitle][@(PARA)];

    cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
}

- (NSString *)localizedTimeForAlarm:(SENAlarm *)alarm {
    NSString *const HEMAlarm12HourFormat = @"%ld:%@";
    NSString *const HEMAlarm24HourFormat = @"%02ld:%@";
    struct SENAlarmTime time = (struct SENAlarmTime){.hour = alarm.hour, .minute = alarm.minute };
    NSString *minuteText = [NSString stringWithFormat:@"%02ld", (long)time.minute];
    NSString* format = HEMAlarm24HourFormat;
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
        format = HEMAlarm12HourFormat;
        if (time.hour > 12) {
            time.hour = (long)(time.hour - 12);
        } else if (time.hour == 0) { time.hour = 12; }
    }
    return [NSString stringWithFormat:format, time.hour, minuteText];
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.alarms.count > indexPath.item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SENAlarm *alarm = [self.alarms objectAtIndex:indexPath.item];
    [self presentViewControllerForAlarm:alarm];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat const HEMAlarmListEmptyCellBaseHeight = 98.f;
    static CGFloat const HEMAlarmListEmptyCellWidthInset = 32.f;
    UICollectionViewFlowLayout *layout = (id)collectionViewLayout;
    CGFloat width = layout.itemSize.width;
    
    if (self.alarms.count > 0 || [self hasLoadingFailed]) {
        return CGSizeMake(width, HEMAlarmListCellHeight);
    } else if ([self hasNoSense]) {
        return CGSizeMake(width, HEMAlarmListPairCellHeight);
    } else if (self.alarms.count == 0) {
        NSAttributedString* attributedText = [self attributedNoAlarmText];
        CGFloat maxWidth = width - (HEMAlarmNoAlarmHorzMargin * 2);
        CGFloat textHeight = [attributedText sizeWithWidth:maxWidth].height;
        return CGSizeMake(width, textHeight + HEMAlarmListNoAlarmCellBaseHeight);
    }
    
    CGFloat textWidth = width - HEMAlarmListEmptyCellWidthInset;
    NSString *text = NSLocalizedString(@"alarms.no-alarm.message", nil);
    CGFloat textHeight = [text heightBoundedByWidth:textWidth usingFont:[UIFont backViewTextFont]];
    return CGSizeMake(width, textHeight + HEMAlarmListEmptyCellBaseHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

#pragma mark - Clean Up

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end
