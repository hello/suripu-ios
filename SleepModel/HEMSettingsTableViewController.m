#import <MessageUI/MessageUI.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSettings.h>

#import "UIFont+HEMStyle.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMSettingsTableViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"
#import "HEMLogUtils.h"
#import "HelloStyleKit.h"
#import "HEMSupportUtil.h"
#import "HEMHelpFooterView.h"

typedef NS_ENUM(NSUInteger, HEMSettingsTableViewRow) {
    HEMSettingsAccountRowIndex = 0,
    HEMSettingsDevicesRowIndex = 1,
    HEMSettingsNotificationRowIndex = 2,
    HEMSettingsUnitsTimeRowIndex = 3,
    HEMSettingsTableViewRows = 4,
};

@interface HEMSettingsTableViewController () <
    UITableViewDataSource,
    UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView* settingsTableView;
@property (weak, nonatomic) UILabel* versionLabel;

@end

@implementation HEMSettingsTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"settings.title", nil);
        self.tabBarItem.image = [HelloStyleKit settingsBarIcon];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"settingsBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureTableView];
}

- (void)configureTableView {
    CGFloat width = CGRectGetWidth([[self settingsTableView] bounds]);
    
    // header
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = width;
    [[self settingsTableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    
    // footer
    HEMHelpFooterView* footer = [[HEMHelpFooterView alloc] initWithWidth:width
                                                 andContainingController:self];
    [self addVersionLabelToFooter:footer];
    [[self settingsTableView] setTableFooterView:footer];
    
    DDLogVerbose(@"content height %f, footer height %f, table height %f",
                 [[self settingsTableView] contentSize].height,
                 CGRectGetHeight([footer bounds]),
                 CGRectGetHeight([[self settingsTableView] bounds]));
}

- (void)addVersionLabelToFooter:(UIView*)footer {
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString* vers = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* versionText = [NSString stringWithFormat:@"%@ %@", name, vers];
    
    UILabel* versionLabel = [[UILabel alloc] init];
    [versionLabel setText:versionText];
    [versionLabel setFont:[UIFont settingsHelpFont]];
    [versionLabel setTextColor:[HelloStyleKit backViewTextColor]];
    [versionLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin
                                      |UIViewAutoresizingFlexibleRightMargin];
    [versionLabel sizeToFit];
    
    CGRect versionFrame = [versionLabel frame];
    versionFrame.origin.x = (CGRectGetWidth([footer bounds])-CGRectGetWidth(versionFrame))/2;
    versionFrame.origin.y = CGRectGetHeight([footer bounds]) + HEMSettingsCellTableMargin;
    [versionLabel setFrame:versionFrame];
    
    [footer addSubview:versionLabel];
    
    // adjust the footer
    CGRect footerFrame = [footer frame];
    footerFrame.size.height = CGRectGetMaxY([versionLabel frame]);
    [footer setFrame:footerFrame];
    
    [self setVersionLabel:versionLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat tableHeight = CGRectGetHeight([[self settingsTableView] bounds]);
    CGFloat contentHeight = [[self settingsTableView] contentSize].height;
    CGFloat versionHeight = CGRectGetHeight([[self versionLabel] bounds]);
    CGFloat bottomAnchorY = tableHeight - versionHeight - HEMSettingsCellTableMargin;
    
    if (contentHeight < bottomAnchorY) {
        // move the version label to the bottom of the table view
        UIView* tableFooter = [[self settingsTableView] tableFooterView];
        CGRect footerFrame = [tableFooter frame];
        CGRect relativeFrame = [tableFooter convertRect:[tableFooter bounds] toView:[self view]];
        CGFloat footerHeight = CGRectGetHeight(footerFrame);
        CGFloat adjustedFooterHeight = tableHeight - CGRectGetMaxY(relativeFrame) + footerHeight;
        
        CGRect versionFrame = [[self versionLabel] frame];
        versionFrame.origin.y =
            adjustedFooterHeight
            - HEMSettingsCellTableMargin
            - versionHeight;
        [[self versionLabel] setFrame:versionFrame];

        footerFrame.size.height = adjustedFooterHeight;
        [tableFooter setFrame:footerFrame];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:kHEMAnalyticsEventSettings];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return HEMSettingsTableViewRows;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* reuseId = [HEMMainStoryboard settingsCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEMSettingsTableViewCell* settingsCell = (HEMSettingsTableViewCell*)cell;
    [[settingsCell titleLabel] setText:[self titleForRowAtIndex:indexPath.row]];
    
    if ([indexPath row] == 0) {
        [settingsCell showTopCorners];
    } else if ([indexPath row] == HEMSettingsTableViewRows - 1){
        [settingsCell showBottomCorners];
    } else {
        [settingsCell showNoCorners];
    }
    
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* nextSegueId = [self segueIdentifierForRow:indexPath.row];

    if (nextSegueId != nil) {
        [self performSegueWithIdentifier:nextSegueId sender:self];
    }
}

- (NSString*)segueIdentifierForRow:(NSUInteger)row
{
    switch (row) {
        case HEMSettingsAccountRowIndex:
            return [HEMMainStoryboard accountSettingsSegueIdentifier];
        case HEMSettingsDevicesRowIndex:
            return [HEMMainStoryboard devicesSettingsSegueIdentifier];
        case HEMSettingsUnitsTimeRowIndex:
            return [HEMMainStoryboard unitsSettingsSegueIdentifier];
        case HEMSettingsNotificationRowIndex:
            return [HEMMainStoryboard notificationSettingsSegueIdentifier];

        default:
            return nil;
    }
}

- (NSString*)titleForRowAtIndex:(NSInteger)index {
    switch (index) {
        case HEMSettingsAccountRowIndex:
            return NSLocalizedString(@"settings.account", nil);
        case HEMSettingsDevicesRowIndex:
            return NSLocalizedString(@"settings.devices", nil);
        case HEMSettingsNotificationRowIndex:
            return NSLocalizedString(@"settings.notifications", nil);
        case HEMSettingsUnitsTimeRowIndex:
            return NSLocalizedString(@"settings.units", nil);
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)dealloc {
    [_settingsTableView setDelegate:nil];
    [_settingsTableView setDataSource:nil];
}

@end
