#import <MessageUI/MessageUI.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSettings.h>

#import "UIFont+HEMStyle.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMSettingsTableViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"
#import "HEMAlertController.h"
#import "HEMLogUtils.h"
#import "HelloStyleKit.h"
#import "HEMSupportUtil.h"

static NSUInteger const HEMSettingsTableViewRows = 4;

@interface HEMSettingsTableViewController () <
    UITableViewDataSource,
    UITableViewDelegate,
    MFMailComposeViewControllerDelegate,
    UITextViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView* settingsTableView;
@end

@implementation HEMSettingsTableViewController

static NSInteger const HEMSettingsAccountIndex = 0;
static NSInteger const HEMSettingsDevicesIndex = 1;
static NSInteger const HEMSettingsUnitsTimeIndex = 2;
static NSInteger const HEMSettingsSignOutIndex = 3;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.image = [HelloStyleKit settingsBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = CGRectGetWidth([[self settingsTableView] bounds]);
    [[self settingsTableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    [[self settingsTableView] setTableFooterView:[self settingsFooterView]];
}

- (UIView*)settingsFooterView {
    CGRect textFrame = {
        HEMSettingsCellTableMargin,
        HEMSettingsCellTableMargin,
        CGRectGetWidth([[self settingsTableView] bounds])-(HEMSettingsCellTableMargin*2),
        0.0f
    };
    CGSize constraint = textFrame.size;
    constraint.height = MAXFLOAT;
    
    UITextView* textView = [[UITextView alloc] init];
    [textView setAttributedText:[self attributedHelpText]];
    [textView setEditable:NO];
    [textView setDelegate:self];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setDataDetectorTypes:UIDataDetectorTypeLink|UIDataDetectorTypeAddress];
    [textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    CGSize textSize = [textView sizeThatFits:constraint];
    textFrame.size.height = textSize.height;
    [textView setFrame:textFrame];
    
    CGRect footerFrame = CGRectZero;
    footerFrame.size.width = CGRectGetWidth([[self settingsTableView] bounds]);
    footerFrame.size.height = CGRectGetHeight(textFrame) + HEMSettingsCellTableMargin;
    
    UIView* container = [[UIView alloc] initWithFrame:footerFrame];
    [container setBackgroundColor:[UIColor clearColor]];
    [container addSubview:textView];
    [container setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    return container;
}

- (NSAttributedString*)attributedHelpText {
    NSString* helpFormat = NSLocalizedString(@"settings.help.format", nil);
    NSArray* args = @[[self supportLink],[self helpEmail]];
    UIColor* color = [HelloStyleKit backViewTextColor];
    UIFont* font = [UIFont settingsHelpFont];
    
    NSMutableAttributedString* attrHelp
        = [[NSMutableAttributedString alloc] initWithFormat:helpFormat
                                                       args:args
                                                  baseColor:color
                                                   baseFont:font];
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    [attrHelp addAttribute:NSParagraphStyleAttributeName
                     value:paraStyle
                     range:NSMakeRange(0, [attrHelp length])];
    
    return attrHelp;
}

- (NSAttributedString*)supportLink {
    NSString* hyperLinkText = NSLocalizedString(@"settings.help.support", nil);
    NSString* url = NSLocalizedString(@"help.url.support", nil);
    NSMutableAttributedString* link = [[NSMutableAttributedString alloc] initWithString:hyperLinkText];
    [link addAttributes:@{NSLinkAttributeName : url,
                          NSFontAttributeName : [UIFont settingsHelpFont],
                          NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor]}
                  range:NSMakeRange(0, [hyperLinkText length])];
    return link;
}

- (NSAttributedString*)helpEmail {
    NSString* text = NSLocalizedString(@"help.email.address", nil);
    NSMutableAttributedString* helpEmail = [[NSMutableAttributedString alloc] initWithString:text];
    [helpEmail addAttributes:@{NSFontAttributeName : [UIFont settingsHelpFont],
                          NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor]}
                       range:NSMakeRange(0, [text length])];
    return helpEmail;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSString* lowerScheme = [URL scheme];
    if ([lowerScheme hasPrefix:@"mailto"]) {
        [HEMSupportUtil sendEmailTo:[URL resourceSpecifier]
                        withSubject:NSLocalizedString(@"help.email.subject", nil)
                               from:self
                       mailDelegate:self];
    } else if ([lowerScheme hasPrefix:@"http"]){
        [HEMSupportUtil openURL:[URL absoluteString] from:self];
    }
    return NO;
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

    NSString* nextSegueId = nil;
    switch ([indexPath row]) {
    case HEMSettingsAccountIndex:
        nextSegueId = [HEMMainStoryboard accountSettingsSegueIdentifier];
        break;
    case HEMSettingsUnitsTimeIndex:
        nextSegueId = [HEMMainStoryboard unitsSettingsSegueIdentifier];
        break;
    case HEMSettingsDevicesIndex:
        nextSegueId = [HEMMainStoryboard devicesSettingsSegueIdentifier];
        break;
    case HEMSettingsSignOutIndex:
        [SENAuthorizationService deauthorize];
        [SENAnalytics track:kHEMAnalyticsEventSignOut];
        break;
    default:
        break;
    }

    if (nextSegueId != nil) {
        [self performSegueWithIdentifier:nextSegueId sender:self];
    }
}

- (NSString*)titleForRowAtIndex:(NSInteger)index {
    switch (index) {
        case HEMSettingsAccountIndex:
            return NSLocalizedString(@"settings.account", nil);
        case HEMSettingsDevicesIndex:
            return NSLocalizedString(@"settings.devices", nil);
        case HEMSettingsUnitsTimeIndex:
            return NSLocalizedString(@"settings.units", nil);
        case HEMSettingsSignOutIndex:
            return NSLocalizedString(@"actions.sign-out", nil);
    }
    return nil;
}

#pragma mark - Contact Support Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
