
#import "HEMSleepHistoryViewController.h"

@interface HEMSleepHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView* historyCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* insightCollectionView;
@property (weak, nonatomic) IBOutlet UILabel* timeFrameLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* timeScopeSegmentedControl;
@end

@implementation HEMSleepHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
}

- (void)configureCollectionView
{
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.insightCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.insightCollectionView.bounds) - 40, CGRectGetHeight(self.insightCollectionView.bounds) - 20);
    CGFloat sideInset = floorf((windowSize.width - layout.itemSize.width) / 2);
    layout.sectionInset = UIEdgeInsetsMake(0, sideInset, 0, sideInset);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.insightCollectionView]) {
        return 4;
    }
    return 9;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    if ([collectionView isEqual:self.insightCollectionView]) {
        UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"insightCell" forIndexPath:indexPath];
        return cell;
    }

    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"timeSliceCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
