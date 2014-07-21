#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSensor.h>
#import <markdown_peg.h>

#import "HEMCurrentConditionsTableViewController.h"
#import "HEMAlarmViewController.h"
#import "HEMInsetGlyphTableViewCell.h"
#import "HEMSensorViewController.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

static NSString* const HEMCurrentConditionsCellIdentifier = @"currentConditionsCell";
@interface HEMCurrentConditionsTableViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* sensors;
@end

@implementation HEMCurrentConditionsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sensors = @[
        [[SENSensor alloc] initWithDictionary:@{ @"name" : @"temperature",
                                                 @"unit" : @"CENTIGRADE",
                                                 @"condition" : @"ALERT",
                                                 @"message" : @"You sleep best when the temperature is between *16° and 18°*.",
                                                 @"value" : @19 }],
        [[SENSensor alloc] initWithDictionary:@{ @"name" : @"humidity",
                                                 @"unit" : @"PERCENT",
                                                 @"condition" : @"IDEAL",
                                                 @"message" : @"You sleep best when the humidity is between *60% and 71%*.",
                                                 @"value" : @76 }],
        [[SENSensor alloc] initWithDictionary:@{ @"name" : @"particulates",
                                                 @"unit" : @"PPM",
                                                 @"condition" : @"IDEAL",
                                                 @"message" : @"Particulate counts above *600ppm* can be a problem for sleep.",
                                                 @"value" : @220 }]
    ];
    [self configureCollectionView];
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)configureCollectionView
{
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - 40, CGRectGetHeight(self.collectionView.bounds) - 20);
    CGFloat sideInset = floorf((windowSize.width - layout.itemSize.width) / 2);
    layout.sectionInset = UIEdgeInsetsMake(0, sideInset, 0, sideInset);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"insightCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
    case 0:
        return self.sensors.count;

    case 1:
        return 2;

    default:
        return 0;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        SENSensor* sensor = self.sensors[indexPath.row];
        if (sensor.condition == SENSensorConditionWarning || sensor.condition == SENSensorConditionAlert) {
            return 114.f;
        }
    }
    return 64.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEMInsetGlyphTableViewCell* cell = (HEMInsetGlyphTableViewCell*)[tableView dequeueReusableCellWithIdentifier:HEMCurrentConditionsCellIdentifier forIndexPath:indexPath];

    switch (indexPath.section) {
    case 0: {
        SENSensor* sensor = self.sensors[indexPath.row];
        cell.titleLabel.text = sensor.localizedName;
        cell.detailLabel.text = sensor.localizedValue;
        if (sensor.condition == SENSensorConditionWarning || sensor.condition == SENSensorConditionAlert) {
            UIFont* emFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0];
            NSDictionary* attributes = @{
                @(EMPH) : @{
                    NSFontAttributeName : emFont,
                },
                @(PARA) : @{
                    NSForegroundColorAttributeName : [UIColor darkGrayColor],
                }
            };
            cell.descriptionLabel.attributedText = markdown_to_attr_string(sensor.message, 0, attributes);
        } else {
            cell.descriptionLabel.text = nil;
        }
    } break;

    case 1: {
        cell.descriptionLabel.text = nil;
        switch (indexPath.row) {
        case 0: {
            cell.titleLabel.text = NSLocalizedString(@"alarm.title", nil);
            if ([[SENAlarm savedAlarm] isOn]) {
                cell.detailLabel.text = [[SENAlarm savedAlarm] localizedValue];
            } else {
                cell.detailLabel.text = NSLocalizedString(@"alarm.state.disabled", nil);
            }
        } break;

        case 1: {
            cell.titleLabel.text = NSLocalizedString(@"sounds.title", nil);
            cell.detailLabel.text = @"";
        }
        }
    }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
    case 0: {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        HEMSensorViewController* controller = (HEMSensorViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sensorViewController"];
        controller.sensor = self.sensors[indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
    } break;

    case 1: {
        switch (indexPath.row) {
        case 0: {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
            UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"alarmViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        } break;

        case 1:
            break;
        }
    }
    }
}

@end
