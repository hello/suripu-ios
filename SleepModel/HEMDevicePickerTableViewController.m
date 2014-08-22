
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SenseKit/BLE.h>

#import "HEMDevicePickerTableViewController.h"
#import "HEMDeviceTableViewCell.h"

static NSString* const pillServiceUUIDString = @"0000E110-1212-EFDE-1523-785FEABCD123";
static NSString* const pillCellIdentifier = @"pillCell";

@interface HEMDevicePickerTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray* discoveredDevices;
@property (nonatomic, strong) NSMutableArray* discoveredDevicesRSSI;
@property (nonatomic, strong) SENPeripheralManager* deviceManager;
@property (nonatomic, strong) UIActivityIndicatorView* searchIndicatorView;
@property (nonatomic, strong) NSIndexPath* selectedDeviceIndexPath;
@property (nonatomic, getter=isScanningForServices) BOOL scanningForServices;
@end

@implementation HEMDevicePickerTableViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _discoveredDevices = @[];
        _discoveredDevicesRSSI = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"picker.title", nil);
    [self configureTableView];
    [self configureNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopScanningForServices];
    [self unregisterObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scanForServices];
}

- (void)dismissFromView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)configureTableView
{
    [[self tableView] registerNib:[UINib nibWithNibName:NSStringFromClass([HEMDeviceTableViewCell class]) bundle:nil]
           forCellReuseIdentifier:pillCellIdentifier];
    [[self tableView] setRowHeight:HEPDeviceTableViewCellHeight];
}

- (void)configureNavigationBar
{
    UIBarButtonItem* refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(scanForServices)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

#pragma mark - Notification configuration

- (void)registerObservers
{
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(discoveredDevices))
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:NULL];
    [[LGCentralManager sharedInstance] addObserver:self
                                        forKeyPath:NSStringFromSelector(@selector(peripherals))
                                           options:NSKeyValueObservingOptionNew
                                           context:NULL];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(discoveredDevices))];
    [[LGCentralManager sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(peripherals))];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(discoveredDevices))]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self tableView] reloadData];
        });
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(peripherals))]) {
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.discoveredDevices.count;
}

- (LGPeripheral*)deviceAtIndexPath:(NSIndexPath*)indexPath
{
    return self.discoveredDevices[indexPath.row];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEMDeviceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:pillCellIdentifier forIndexPath:indexPath];
    LGPeripheral* device = [self deviceAtIndexPath:indexPath];
    cell.nameLabel.text = device.cbPeripheral.name;
    cell.identifierLabel.text = device.UUIDString;
    cell.signalStrengthLabel.text = nil;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedDeviceIndexPath = indexPath;
    [self showNicknamePickerAlertView];
}

- (void)showNicknamePickerAlertView
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"picker.nickname-device.title", nil)
                                                        message:NSLocalizedString(@"picker.nickname-device.message", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"actions.save", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;

    LGPeripheral* peripheral = [self deviceAtIndexPath:self.selectedDeviceIndexPath];
    NSString* nickname = [alertView textFieldAtIndex:0].text;
    if (nickname.length == 0) {
        nickname = peripheral.cbPeripheral.name;
    }

    SENDevice* device = [[SENDevice alloc] initWithName:peripheral.cbPeripheral.name nickname:nickname identifier:peripheral.UUIDString];
    [SENDeviceService addDevice:device];
    if (!self.deviceManager || ![self.deviceManager.peripheral isEqual:peripheral])
        self.deviceManager = [[SENPeripheralManager alloc] initWithPeripheral:peripheral];
    [self dismissFromView];
}

#pragma mark - Central manager

- (void)scanForServices
{
    if ([self isScanningForServices] || ![[LGCentralManager sharedInstance] isCentralReady])
        return;

    self.scanningForServices = YES;
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"device-list.search.loading-message", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:3 services:@[] options:nil completion:^(NSArray* peripherals) {
        typeof(self) strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name.length > 0"];
        strongSelf.discoveredDevices = [peripherals filteredArrayUsingPredicate:predicate];
        strongSelf.scanningForServices = NO;
    }];
}

- (void)stopScanningForServices
{
    if (![[LGCentralManager sharedInstance] isCentralReady])
        return;

    [[LGCentralManager sharedInstance] stopScanForPeripherals];
}

@end
