
#import <SpinKit/RTSpinKitView.h>
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@implementation HEMSleepSummaryCollectionViewCell

- (void)awakeFromNib
{
    [self configureSpinner];
}

- (void)configureSpinner
{
    self.spinnerView.color = [UIColor colorWithWhite:0.1 alpha:0.2];
    self.spinnerView.spinnerSize = CGRectGetWidth(self.spinnerView.bounds);
    self.spinnerView.style = RTSpinKitViewStyleArc;
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.backgroundColor = [UIColor clearColor];
}

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated
{
    [self.sleepScoreGraphView setSleepScore:sleepScore animated:animated];
}

@end
