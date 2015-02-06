
#import <SenseKit/Model.h>
#import <SpinKit/RTSpinKitView.h>
#import <AttributedMarkdown/markdown_peg.h>

#import "UIFont+HEMStyle.h"

#import "HEMAlarmListViewController.h"
#import "HEMCardFlowLayout.h"
#import "HEMAlarmViewController.h"
#import "HEMAlarmListCell.h"
#import "HelloStyleKit.h"
#import "HEMAlarmAddButton.h"
#import "HEMAlarmUtils.h"
#import "HEMMainStoryboard.h"
#import "HEMMarkdown.h"

@interface HEMAlarmListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HEMAlarmControllerDelegate>

@property (strong, nonatomic) NSArray* alarms;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet HEMAlarmAddButton* addButton;
@property (weak, nonatomic) IBOutlet UILabel* noAlarmLabel;
@property (weak, nonatomic) IBOutlet RTSpinKitView* spinnerView;
@property (strong, nonatomic) NSDateFormatter* hour24Formatter;
@property (strong, nonatomic) NSDateFormatter* hour12Formatter;
@property (strong, nonatomic) NSDateFormatter* meridiemFormatter;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, getter=hasLoadingFailed) BOOL loadingFailed;
@end

@implementation HEMAlarmListViewController

static CGFloat const HEMAlarmListButtonMinimumScale = 0.95f;
static CGFloat const HEMAlarmListButtonMaximumScale = 1.2f;
static CGFloat const HEMAlarmListCellHeight = 96.f;
static CGFloat const HEMAlarmListEmptyCellHeight = 208.f;
static NSString* const HEMAlarmTimeFormat = @"%ld:%@";
static NSString* const HEMAlarmListTimeKey = @"alarms.alarm.meridiem.%@";
static NSUInteger const HEMAlarmListLimit = 8;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"alarms.title", nil);
        self.tabBarItem.image = [HelloStyleKit alarmBarIcon];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"alarmBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    [self configureAddButton];
    [self configureSpinnerView];
    [self configureNoAlarmInstructions];
    [self configureDateFormatters];
    [self refreshAlarmList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshAlarmList];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:kHEMAnalyticsEventAlarms];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self touchUpOutsideAddAlarmButton:nil];
}

- (void)didReceiveMemoryWarning
{
    if (![self isViewLoaded] || !self.view.window) {
        self.alarms = nil;
    }
    [super didReceiveMemoryWarning];
}

- (void)configureAddButton
{
    [self.addButton addTarget:self action:@selector(touchDownAddAlarmButton:)
             forControlEvents:UIControlEventTouchDown];
    [self.addButton addTarget:self action:@selector(touchUpOutsideAddAlarmButton:)
             forControlEvents:UIControlEventTouchUpOutside];
    self.addButton.enabled = self.alarms.count < HEMAlarmListLimit;
}

- (void)configureNoAlarmInstructions
{
    NSDictionary* attributes = @{ NSKernAttributeName: @(1.2), NSFontAttributeName: [UIFont backViewTitleFont] };
    NSString* instructions = NSLocalizedString(@"alarms.no-alarm.instructions", nil);
    self.noAlarmLabel.attributedText = [[NSAttributedString alloc] initWithString:[instructions uppercaseString]
                                                                       attributes:attributes];
    self.noAlarmLabel.hidden = self.alarms.count > 0;
}

- (void)configureSpinnerView
{
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.color = [UIColor whiteColor];
    self.spinnerView.spinnerSize = CGRectGetHeight(self.spinnerView.bounds);
    self.spinnerView.style = RTSpinKitViewStyleThreeBounce;
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.backgroundColor = [UIColor clearColor];
    [self.spinnerView stopAnimating];
}

- (void)configureDateFormatters
{
    self.hour12Formatter = [NSDateFormatter new];
    self.hour12Formatter.dateFormat = @"hh:mm";
    self.hour24Formatter = [NSDateFormatter new];
    self.hour24Formatter.dateFormat = @"H:mm";
    self.meridiemFormatter = [NSDateFormatter new];
    self.meridiemFormatter.dateFormat = @"a";
}

- (void)refreshAlarmList
{
    if ([self isLoading])
        return;
    self.loading = YES;
    self.addButton.enabled = NO;
    [self.spinnerView startAnimating];
    [HEMAlarmUtils refreshAlarmsFromPresentingController:self completion:^(NSError* error) {
        [self.spinnerView stopAnimating];
        if (error) {
            self.loadingFailed = YES;
            if (self.alarms.count == 0) {
                [self.collectionView reloadData];
                self.loading = NO;
                return;
            }
        } else {
            self.loadingFailed = NO;
            HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
            [layout clearCache];
            [self reloadData];
            [self.collectionView reloadData];
        }
        self.addButton.enabled = YES;
        self.loading = NO;
    }];
}

- (void)reloadData
{
    if (![self shouldReloadData])
        return;
    self.alarms = [[SENAlarm savedAlarms] sortedArrayUsingComparator:^NSComparisonResult(SENAlarm* obj1, SENAlarm* obj2) {
        NSNumber* alarmValue1 = @(obj1.hour * 60 + obj1.minute);
        NSNumber* alarmValue2 = @(obj2.hour * 60 + obj2.minute);
        NSComparisonResult result = [alarmValue1 compare:alarmValue2];
        if (result == NSOrderedSame)
            result = [@(obj1.repeatFlags) compare:@(obj2.repeatFlags)];
        return result;
    }];
    self.noAlarmLabel.hidden = self.alarms.count > 0;
    self.addButton.enabled = self.alarms.count < HEMAlarmListLimit;
}

- (BOOL)shouldReloadData
{
    NSArray* savedAlarms = [SENAlarm savedAlarms];
    if (self.alarms.count == savedAlarms.count) {
        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(SENAlarm* alarm, NSDictionary *bindings) {
            for (SENAlarm* loadedAlarm in self.alarms) {
                if ([alarm isEqual:loadedAlarm] && [loadedAlarm isSaved])
                    return YES;
            }
            return NO;
        }];
        NSArray* matchedAlarms = [savedAlarms filteredArrayUsingPredicate:predicate];
        if (matchedAlarms.count == savedAlarms.count)
            return NO;
    }
    return YES;
}

#pragma mark - Actions

- (void)touchDownAddAlarmButton:(id)sender
{
    [UIView animateWithDuration:0.05f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addButton.layer.transform = CATransform3DMakeScale(HEMAlarmListButtonMinimumScale,
                                                                HEMAlarmListButtonMinimumScale, 1.f);
    } completion:NULL];
}

- (void)touchUpOutsideAddAlarmButton:(id)sender
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.addButton.layer.transform = CATransform3DIdentity;
    } completion:NULL];
}

- (IBAction)addNewAlarm:(id)sender
{
    void (^animations)() = ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            self.addButton.layer.transform = CATransform3DMakeScale(HEMAlarmListButtonMaximumScale,
                                                                    HEMAlarmListButtonMaximumScale, 1.f);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            self.addButton.layer.transform = CATransform3DIdentity;
        }];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        SENAlarm* alarm = [SENAlarm createDefaultAlarm];
        [self presentViewControllerForAlarm:alarm];
    };

    NSUInteger options = (UIViewKeyframeAnimationOptionCalculationModeCubicPaced|UIViewAnimationOptionCurveEaseIn
                          |UIViewKeyframeAnimationOptionBeginFromCurrentState);
    [UIView animateKeyframesWithDuration:0.35f
                                   delay:0.15f
                                 options:options
                              animations:animations
                              completion:completion];
}

- (IBAction)flippedEnabledSwitch:(UISwitch*)sender
{
    __block SENAlarm* alarm = [self.alarms objectAtIndex:sender.tag];
    BOOL on = [sender isOn];
    alarm.on = on;
    [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
        if (!success) {
            alarm.on = !on;
            sender.on = !on;
        }
    }];
}

- (void)presentViewControllerForAlarm:(SENAlarm*)alarm
{
    UINavigationController* controller = (UINavigationController*)[HEMMainStoryboard instantiateAlarmNavController];
    HEMAlarmViewController* alarmController = (HEMAlarmViewController*)controller.topViewController;
    alarmController.alarm = alarm;
    alarmController.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - HEMAlarmControllerDelegate

- (void)didCancelAlarmFrom:(HEMAlarmViewController *)alarmVC
{
    [self refreshAlarmList];
    [alarmVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSaveAlarm:(SENAlarm *)alarm from:(HEMAlarmViewController *)alarmVC
{
    [self refreshAlarmList];
    [alarmVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Collection View

- (void)configureCollectionView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
    UIEdgeInsets sectionInsets = layout.sectionInset;
    sectionInsets.bottom = CGRectGetHeight(bounds) - CGRectGetMinY(self.addButton.frame);
    layout.sectionInset = sectionInsets;
}

#pragma mark UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.alarms.count > 0 ? self.alarms.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.alarms.count > 0) {
        return [self collectionView:collectionView alarmCellAtIndexPath:indexPath];
    } else if ([self isLoading] || [self hasLoadingFailed]) {
        return [self collectionView:collectionView statusCellAtIndexPath:indexPath];
    } else {
        return [self collectionView:collectionView emptyCellAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    alarmCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard alarmListCellReuseIdentifier];
    HEMAlarmListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    SENAlarm* alarm = self.alarms[indexPath.item];

    cell.enabledSwitch.on = [alarm isOn];
    cell.enabledSwitch.tag = indexPath.item;
    [self updateDetailTextInCell:cell fromAlarm:alarm];
    [self updateTimeTextInCell:cell fromAlarm:alarm];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    emptyCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard alarmListEmptyCellReuseIdentifier];
    HEMAlarmListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSMutableParagraphStyle* style = [NSMutableParagraphStyle new];
    style.lineSpacing = 8.f;
    NSMutableDictionary* detailAttributes = [[HEMMarkdown attributesForBackViewText][@(PARA)] mutableCopy];
    [detailAttributes removeObjectForKey:NSForegroundColorAttributeName];
    NSString* messageKey = [self isLoading] ? @"activity.loading" : @"alarms.no-alarm.message";
    cell.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(messageKey, nil)
                                                                      attributes:detailAttributes];
    NSString* title = [NSLocalizedString(@"alarms.no-alarm.title", nil) uppercaseString];
    cell.titleLabel.text = title;
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                   statusCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard alarmListStatusCellReuseIdentifier];
    HEMAlarmListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSString* messageKey = [self isLoading] ? @"activity.loading" : @"alarms.no-data";
    cell.detailLabel.text = NSLocalizedString(messageKey, nil);
    return cell;
}

- (void)updateTimeTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm
{
    cell.timeLabel.text = [self localizedTimeForAlarm:alarm];
    if ([SENSettings timeFormat] == SENTimeFormat12Hour) {
        NSString* meridiem = alarm.hour < 12 ? @"am" : @"pm";
        NSString* key = [NSString stringWithFormat:HEMAlarmListTimeKey, meridiem];
        cell.meridiemLabel.text = NSLocalizedString(key, nil);
    } else {
        cell.meridiemLabel.text = nil;
    }
}

- (void)updateDetailTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm
{
    NSString* detailFormat;

    if ([alarm isSmartAlarm])
        detailFormat = NSLocalizedString(@"alarms.smart-alarm.format", nil);
    else
        detailFormat = NSLocalizedString(@"alarms.alarm.format", nil);

    NSString* repeatText = [HEMAlarmUtils repeatTextForUnitFlags:alarm.repeatFlags];
    NSString* detailText = [[NSString stringWithFormat:detailFormat, repeatText] uppercaseString];
    NSDictionary* attributes = [HEMMarkdown attributesForBackViewTitle][@(PARA)];

    cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
}

- (NSString *)localizedTimeForAlarm:(SENAlarm *)alarm
{
    struct SENAlarmTime time = (struct SENAlarmTime){ .hour = alarm.hour, .minute = alarm.minute };
    NSString* minuteText = time.minute < 10
        ? [NSString stringWithFormat:@"0%ld", (long)time.minute]
        : [NSString stringWithFormat:@"%ld", (long)time.minute];
    if ([SENSettings timeFormat] == SENTimeFormat12Hour) {
        if (time.hour > 12) {
            time.hour = (long)(time.hour - 12);
        } else if (time.hour == 0) {
            time.hour = 12;
        }
    }
    return [NSString stringWithFormat:HEMAlarmTimeFormat, time.hour, minuteText];
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.alarms.count > indexPath.item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.item];
    [self presentViewControllerForAlarm:alarm];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout* layout = (id)collectionViewLayout;
    BOOL statusMessageShouldShow = [self isLoading] || [self hasLoadingFailed];
    CGFloat height = (self.alarms.count > 0 || statusMessageShouldShow)
        ? HEMAlarmListCellHeight : HEMAlarmListEmptyCellHeight;
    return CGSizeMake(layout.itemSize.width, height);
}

@end
