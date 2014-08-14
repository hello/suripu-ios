
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import "HEMSleepSummaryViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMSleepHistoryView.h"
#import "HelloStyleKit.h"

@interface HEMSleepSummaryViewController () <FCDynamicPaneViewController>

@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet HEMSleepHistoryView* sleepHistoryView;
@property (weak, nonatomic) IBOutlet UILabel* lastNightLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreView;
@property (strong, nonatomic) NSDate* dateForNightOfSleep;
@end

@implementation HEMSleepSummaryViewController

+ (NSDateFormatter*)sleepDateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
    });
    return formatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSString* dateText = [[HEMSleepSummaryViewController sleepDateFormatter] stringFromDate:self.dateForNightOfSleep];
    NSString* lastNightDateText = [[HEMSleepSummaryViewController sleepDateFormatter] stringFromDate:[NSDate dateWithTimeInterval:-60 * 60 * 24 sinceDate:[NSDate date]]];
    if ([dateText isEqualToString:lastNightDateText]) {
        NSString* lastNightDateFormatText = NSLocalizedString(@"sleep-history.last-night", nil);
        self.lastNightLabel.text = lastNightDateFormatText;
        [self.sleepScoreView setSleepScoreDateText:lastNightDateFormatText];
    } else {
        self.lastNightLabel.text = dateText;
        [self.sleepScoreView setSleepScoreDateText:dateText];
    }

    [self.sleepScoreView setSleepScore:arc4random() % 90];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lastNightLabel.alpha = 0.f;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidPop
{
    self.scrollView.scrollEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.lastNightLabel.alpha = 1.f;
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.view.backgroundColor = [HelloStyleKit lightestBlueColor];
    }];
}

- (void)viewDidPush
{
    [UIView animateWithDuration:0.1f animations:^{
        self.lastNightLabel.alpha = 0.f;
        self.view.backgroundColor = [UIColor whiteColor];
    }];
    self.scrollView.scrollEnabled = YES;
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    [super didMoveToParentViewController:parent];
}

- (void)willMoveToParentViewController:(UIViewController*)parent
{
    [super willMoveToParentViewController:parent];
}

- (void)setDateForNightOfSleep:(NSDate*)date
{
    _dateForNightOfSleep = date;
    NSString* dateText = [[HEMSleepSummaryViewController sleepDateFormatter] stringFromDate:date];
    self.lastNightLabel.text = dateText;
    [self.sleepScoreView setSleepScoreDateText:dateText];
}

- (IBAction)pinchedHistoryView:(id)sender
{
    //    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    //    HEMSleepHistoryViewController* controller = (HEMSleepHistoryViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sleepHistoryController"];
    //    [self presentViewController:controller animated:YES completion:NULL];
}

@end
