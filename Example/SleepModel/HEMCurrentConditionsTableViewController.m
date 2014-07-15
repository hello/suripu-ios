#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSensor.h>

#import "HEMCurrentConditionsTableViewController.h"
#import "HEMAlarmViewController.h"
#import "HEMSensorViewController.h"
#import "HEMColorUtils.h"

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
                                                 @"message" : @"You sleep best when the temperature is between *61° and 68°*.",
                                                 @"value" : @19 }],
        [[SENSensor alloc] initWithDictionary:@{ @"name" : @"humidity",
                                                 @"unit" : @"PERCENT",
                                                 @"message" : @"You sleep best when the humidity is between *60% and 71%*.",
                                                 @"value" : @76 }],
        [[SENSensor alloc] initWithDictionary:@{ @"name" : @"particulates",
                                                 @"unit" : @"PPM",
                                                 @"message" : @"Particulate counts above *600ppm* can be a problem for sleep.",
                                                 @"value" : @220 }]
    ];
    [self configureCollectionView];
    [self configureViewBackground];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)configureViewBackground
{
    [self.view.layer insertSublayer:[HEMColorUtils layerWithBlueBackgroundGradientInFrame:self.view.bounds]
                            atIndex:0];
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

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:HEMCurrentConditionsCellIdentifier forIndexPath:indexPath];

    switch (indexPath.section) {
    case 0: {
        SENSensor* sensor = self.sensors[indexPath.row];
        cell.textLabel.text = sensor.localizedName;
        cell.detailTextLabel.text = sensor.localizedValue;
    } break;

    case 1: {
        switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = NSLocalizedString(@"alarm.title", nil);
            if ([[SENAlarm savedAlarm] isOn]) {
                cell.detailTextLabel.text = [[SENAlarm savedAlarm] localizedValue];
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"alarm.state.disabled", nil);
            }
        } break;

        case 1: {
            cell.textLabel.text = NSLocalizedString(@"sounds.title", nil);
            cell.detailTextLabel.text = @"";
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
