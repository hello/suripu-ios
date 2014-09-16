
#import "HEMAlarmListViewController.h"
#import "HelloStyleKit.h"
#import "HEMColorUtils.h"
#import "HEMAlarmAddButton.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CAGradientLayer* gradientLayer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HEMAlarmAddButton *addButton;
@end

@implementation HEMAlarmListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.title = NSLocalizedString(@"alarms.title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[HelloStyleKit chevronIconLeft] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSMutableDictionary* dict = self.navigationController.navigationBar.titleTextAttributes.mutableCopy;
    dict[NSForegroundColorAttributeName] = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    [self configureViewBackground];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    NSMutableDictionary* dict = self.navigationController.navigationBar.titleTextAttributes.mutableCopy;
    dict[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
}

- (void)configureViewBackground
{
    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer new];
        [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [HEMColorUtils configureLayer:self.gradientLayer forHourOfDay:7];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard alarmListCellIdentifier]];
    return cell;
}

@end
