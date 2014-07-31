
#import "HEMSleepSummaryViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepScoreGraphView.h"

@interface HEMSleepSummaryViewController ()

@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreView;
@end

@implementation HEMSleepSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pinchedHistoryView:(id)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    HEMSleepHistoryViewController* controller = (HEMSleepHistoryViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sleepHistoryController"];
    [self presentViewController:controller animated:YES completion:NULL];
}

@end
