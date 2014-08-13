
#import "HEMSleepSummaryViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@interface HEMSleepSummaryViewController ()

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
    self.lastNightLabel.hidden = YES;
}

- (IBAction)pinchedHistoryView:(id)sender
{
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
//    HEMSleepHistoryViewController* controller = (HEMSleepHistoryViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sleepHistoryController"];
//    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)showPreviewContent
{
    self.lastNightLabel.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.lastNightLabel.alpha = 1.f;
        self.view.backgroundColor = [HelloStyleKit lightestBlueColor];
    }];
}

@end
