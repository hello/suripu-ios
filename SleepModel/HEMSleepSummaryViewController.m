
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import "HEMSleepSummaryViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMSleepHistoryView.h"
#import "HelloStyleKit.h"

@interface HEMSleepSummaryViewController () <FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet HEMSleepHistoryView* sleepHistoryView;
@property (weak, nonatomic) IBOutlet UILabel* lastNightLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreView;
@property (strong, nonatomic) NSDate* dateForNightOfSleep;
@property (nonatomic) UIStatusBarStyle oldBarStyle;
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

- (void)dealloc
{
    self.panePanGestureRecognizer.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self updateTextForDate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lastNightLabel.alpha = 0.f;
    self.view.backgroundColor = [UIColor whiteColor];
    self.panePanGestureRecognizer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.panePanGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.panePanGestureRecognizer.delegate = nil;
}

- (void)viewDidPop
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.oldBarStyle];
    self.scrollView.scrollEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.lastNightLabel.alpha = 1.f;
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.view.backgroundColor = [HelloStyleKit lightestBlueColor];
    }];
    self.oldBarStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidPush
{
    self.panePanGestureRecognizer.delegate = self;
    self.oldBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.1f animations:^{
        self.lastNightLabel.alpha = 0.f;
        self.view.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.f];
    }];
    self.scrollView.scrollEnabled = YES;
    [self setNeedsStatusBarAppearanceUpdate];
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
    //    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //    HEMSleepHistoryViewController* controller = (HEMSleepHistoryViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sleepHistoryController"];
    //    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return self.scrollView.contentOffset.y < 20.f;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Configuration

- (void)updateTextForDate
{
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

@end
