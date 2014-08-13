#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENBackgroundNoise.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <markdown_peg.h>

#import "HEMCurrentConditionsTableViewController.h"
#import "HEMColoredRoundedLabel.h"
#import "HEMAlarmViewController.h"
#import "HEMInsetGlyphTableViewCell.h"
#import "HEMSensorViewController.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

NSString* const HEMCurrentConditionsCellIdentifier = @"currentConditionsCell";
@interface HEMCurrentConditionsTableViewController ()
@property (nonatomic, strong) NSArray* sensors;
@end

@implementation HEMCurrentConditionsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"current-conditions.title", nil);
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
}

- (IBAction)dismissCurrentConditionsController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshSensors];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSensors) name:SENSensorUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSensors) name:SENSensorsUpdatedNotification object:nil];
    [SENSensor refreshCachedSensors];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshSensors
{
    self.sensors = [[SENSensor sensors] sortedArrayUsingComparator:^NSComparisonResult(SENSensor* obj1, SENSensor* obj2) {
        return [obj1.name compare:obj2.name];
    }];
    [self.tableView reloadData];
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
        return self.sensors.count == 0 ? 1 : self.sensors.count;

    case 1:
        return 3;

    default:
        return 0;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (self.sensors.count > 0) {
            SENSensor* sensor = self.sensors[indexPath.row];
            if (sensor.condition == SENSensorConditionWarning || sensor.condition == SENSensorConditionAlert) {
                return 114.f;
            }
        }
    }
    return 64.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;

    switch (indexPath.section) {
    case 0:
        cell = [self tableView:tableView sensorCellForRowAtIndexPath:indexPath];
        break;

    case 1:
        cell = [self tableView:tableView menuCellForRowAtIndexPath:indexPath];
        break;
    }

    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView sensorCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEMInsetGlyphTableViewCell* cell = (HEMInsetGlyphTableViewCell*)[tableView dequeueReusableCellWithIdentifier:HEMCurrentConditionsCellIdentifier forIndexPath:indexPath];
    if (self.sensors.count <= indexPath.row) {
        [(HEMColoredRoundedLabel*)cell.detailLabel hideRoundedBackground];
        cell.titleLabel.text = NSLocalizedString(@"sensor.data-unavailable", nil);
        cell.detailLabel.text = nil;
        cell.glyphImageView.image = nil;
        cell.descriptionLabel.text = nil;
    } else {
        [(HEMColoredRoundedLabel*)cell.detailLabel showRoundedBackground];
        SENSensor* sensor = self.sensors[indexPath.row];
        cell.titleLabel.text = sensor.localizedName;
        cell.detailLabel.text = sensor.localizedValue;
        switch (sensor.unit) {
        case SENSensorUnitDegreeCentigrade:
            cell.glyphImageView.image = [HelloStyleKit temperatureIcon];
            break;
        case SENSensorUnitPartsPerMillion:
            cell.glyphImageView.image = [HelloStyleKit particleIcon];
            break;
        case SENSensorUnitPercent:
            cell.glyphImageView.image = [HelloStyleKit humidityIcon];
            break;
        case SENSensorUnitUnknown:
        default:
            cell.glyphImageView.image = nil;
            break;
        }
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
            if (sensor.condition == SENSensorConditionWarning) {
                [(HEMColoredRoundedLabel*)cell.detailLabel setTextColor:[HelloStyleKit warningSensorColor]];
            } else {
                [(HEMColoredRoundedLabel*)cell.detailLabel setTextColor:[HelloStyleKit alertSensorColor]];
            }
        } else {
            cell.descriptionLabel.text = nil;
            [(HEMColoredRoundedLabel*)cell.detailLabel setTextColor:[HelloStyleKit idealSensorColor]];
        }
    }

    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView menuCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEMInsetGlyphTableViewCell* cell = (HEMInsetGlyphTableViewCell*)[tableView dequeueReusableCellWithIdentifier:HEMCurrentConditionsCellIdentifier forIndexPath:indexPath];
    [(HEMColoredRoundedLabel*)cell.detailLabel hideRoundedBackground];
    [(HEMColoredRoundedLabel*)cell.detailLabel setTextColor:[UIColor darkGrayColor]];
    cell.descriptionLabel.text = nil;
    switch (indexPath.row) {
    case 0: {
        cell.titleLabel.text = NSLocalizedString(@"alarm.title", nil);
        if ([[SENAlarm savedAlarm] isOn]) {
            cell.detailLabel.text = [[SENAlarm savedAlarm] localizedValue];
        } else {
            cell.detailLabel.text = NSLocalizedString(@"alarm.state.disabled", nil);
        }
        cell.glyphImageView.image = nil;
    } break;

    case 1: {
        cell.titleLabel.text = NSLocalizedString(@"sounds.title", nil);
        SENBackgroundNoise* noise = [SENBackgroundNoise savedBackgroundNoise];
        cell.detailLabel.text = [noise isOn] ? [noise soundName] : NSLocalizedString(@"noise.state.disabled", nil);
        cell.glyphImageView.image = nil;
    } break;
    case 2: {
        cell.titleLabel.text = NSLocalizedString(@"settings.title", nil);
        cell.detailLabel.text = nil;
        cell.descriptionLabel.text = nil;
        cell.glyphImageView.image = [HelloStyleKit settingsIcon];
    }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    switch (indexPath.section) {
    case 0: {
        HEMSensorViewController* controller = (HEMSensorViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sensorViewController"];
        controller.sensor = self.sensors[indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
    } break;

    case 1: {
        switch (indexPath.row) {
        case 0: {
            UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"alarmViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        } break;

        case 1: {
            UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"sleepSoundViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 2: {
            UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"settingsController"];
            [self.navigationController pushViewController:controller animated:YES];
        }
        }
    } break;
    }
}

@end
