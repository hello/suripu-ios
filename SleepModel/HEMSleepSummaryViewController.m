
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import "HEMSleepSummaryViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@interface HEMSleepSummaryViewController () <FCDynamicPaneViewController>

@property (weak, nonatomic) IBOutlet UILabel* lastNightLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreView;
@end

@implementation HEMSleepSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lastNightLabel.alpha = 0.f;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidPop
{
    [UIView animateWithDuration:0.5f animations:^{
        self.lastNightLabel.alpha = 1.f;
        self.view.backgroundColor = [HelloStyleKit lightestBlueColor];
    }];
}

- (void)viewDidPush
{
    [UIView animateWithDuration:0.1f animations:^{
        self.lastNightLabel.alpha = 0.f;
        self.view.backgroundColor = [UIColor whiteColor];
    }];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    [super didMoveToParentViewController:parent];
}

- (void)willMoveToParentViewController:(UIViewController*)parent
{
    [super willMoveToParentViewController:parent];
}

- (IBAction)pinchedHistoryView:(id)sender
{
    //    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    //    HEMSleepHistoryViewController* controller = (HEMSleepHistoryViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sleepHistoryController"];
    //    [self presentViewController:controller animated:YES completion:NULL];
}

@end
