
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSettings.h>

#import "UIFont+HEMStyle.h"

#import "HEMAlarmListViewController.h"
#import "HEMCardFlowLayout.h"
#import "HEMAlarmViewController.h"
#import "HEMAlarmListCell.h"
#import "HelloStyleKit.h"
#import "HEMAlarmAddButton.h"
#import "HEMAlarmUtils.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) CAGradientLayer* gradientLayer;
@property (strong, nonatomic) NSArray* alarms;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet HEMAlarmAddButton* addButton;
@property (strong, nonatomic) NSDateFormatter* hour24Formatter;
@property (strong, nonatomic) NSDateFormatter* hour12Formatter;
@property (strong, nonatomic) NSDateFormatter* meridiemFormatter;
@end

@implementation HEMAlarmListViewController

static CGFloat const HEMAlarmListButtonMinimumScale = 0.8f;
static CGFloat const HEMAlarmListButtonMaximumScale = 1.2f;
static CGFloat const HEMAlarmListCellHeight = 96.f;
static NSString* const HEMAlarmTimeFormat = @"%ld:%@";
static NSString* const HEMAlarmListTimeKey = @"alarms.alarm.meridiem.%@";
static NSUInteger const HEMAlarmListLimit = 8;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"alarms.title", nil);
        self.tabBarItem.image = [HelloStyleKit alarmBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    [self configureAddButton];
    [self configureDateFormatters];
    [self refreshAlarmList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self touchUpOutsideAddAlarmButton:nil];
}

- (void)configureAddButton
{
    [self.addButton addTarget:self action:@selector(touchDownAddAlarmButton:)
             forControlEvents:UIControlEventTouchDown];
    [self.addButton addTarget:self action:@selector(touchUpOutsideAddAlarmButton:)
             forControlEvents:UIControlEventTouchUpOutside];
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
    self.addButton.enabled = NO;
    [HEMAlarmUtils refreshAlarmsFromPresentingController:self completion:^{
        [self reloadData];
        [self.collectionView reloadData];
        self.addButton.enabled = YES;
    }];
}

- (void)reloadData
{
    self.alarms = [[SENAlarm savedAlarms] sortedArrayUsingComparator:^NSComparisonResult(SENAlarm* obj1, SENAlarm* obj2) {
        NSNumber* alarmValue1 = @(obj1.hour * 60 + obj1.minute);
        NSNumber* alarmValue2 = @(obj2.hour * 60 + obj2.minute);
        return [alarmValue1 compare:alarmValue2];
    }];
    self.addButton.enabled = self.alarms.count < HEMAlarmListLimit;
}

#pragma mark - Actions

- (void)touchDownAddAlarmButton:(id)sender
{
    [UIView animateWithDuration:0.15f animations:^{
        self.addButton.layer.transform = CATransform3DMakeScale(HEMAlarmListButtonMaximumScale,
                                                                HEMAlarmListButtonMaximumScale, 1.f);
    }];
}

- (void)touchUpOutsideAddAlarmButton:(id)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        self.addButton.layer.transform = CATransform3DIdentity;
    }];
}

- (IBAction)addNewAlarm:(id)sender
{
    void (^animations)() = ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
            self.addButton.layer.transform = CATransform3DIdentity;
        }];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        SENAlarm* alarm = [SENAlarm createDefaultAlarm];
        [self presentViewControllerForAlarm:alarm];
    };

    NSUInteger options = (UIViewKeyframeAnimationOptionCalculationModeCubicPaced|UIViewAnimationOptionCurveEaseInOut);
    [UIView animateKeyframesWithDuration:0.25
                                   delay:0
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
    [self.navigationController presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - Collection View

- (void)configureCollectionView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
    [layout setItemHeight:HEMAlarmListCellHeight];
    UIEdgeInsets sectionInsets = layout.sectionInset;
    sectionInsets.bottom = CGRectGetHeight(bounds) - CGRectGetMinY(self.addButton.frame);
    layout.sectionInset = sectionInsets;
}

#pragma mark UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.alarms.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard alarmListCellReuseIdentifier];
    HEMAlarmListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(HEMAlarmListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SENAlarm* alarm = self.alarms[indexPath.item];

    cell.enabledSwitch.on = [alarm isOn];
    cell.enabledSwitch.tag = indexPath.item;
    [self updateDetailTextInCell:cell fromAlarm:alarm];
    [self updateTimeTextInCell:cell fromAlarm:alarm];
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
    NSDictionary* attributes = @{
        NSFontAttributeName : cell.detailLabel.font,
        NSForegroundColorAttributeName : cell.detailLabel.textColor,
        NSKernAttributeName : @(1.3f)
    };

    cell.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
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
        }
        else if (time.hour == 0) {
            time.hour = 12;
        }
    }
    return [NSString stringWithFormat:HEMAlarmTimeFormat, time.hour, minuteText];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.item];
    [self presentViewControllerForAlarm:alarm];
}

@end
