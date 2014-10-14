
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>
#import <markdown_peg.h>

#import "HEMSleepGraphViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMEventInfoView.h"
#import "HEMPaddedRoundedLabel.h"
#import "HelloStyleKit.h"

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
@property (nonatomic) UIStatusBarStyle oldBarStyle;
@property (strong, nonatomic) IBOutlet UICollectionView* collectionView;
@property (strong, nonatomic) HEMEventInfoView* eventInfoView;
@property (strong, nonatomic) NSDictionary* eventInfoMarkdownAttributes;
@property (strong, nonatomic) NSDateFormatter* eventInfoDateFormatter;
@end

@implementation HEMSleepGraphViewController

static CGFloat const HEMSleepSummaryCellHeight = 300.f;
static CGFloat const HEMSleepEventPopupFullHeight = 100.f;
static CGFloat const HEMSleepEventPopupMinimumHeight = 50.f;
static CGFloat const HEMPresleepHeaderCellHeight = 84.f;
static CGFloat const HEMPresleepItemCellHeight = 48.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 30.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 4.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.panePanGestureRecognizer.delegate = self;
    [self configureEventInfoView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showFirstAvailableEventPopup];
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
    self.collectionView.scrollEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.collectionView.contentOffset = CGPointMake(0, 0);
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
        self.view.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.f];
    }];
    self.collectionView.scrollEnabled = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark Event Info Popup

- (void)showFirstAvailableEventPopup
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray* visibleCellIndexPaths = self.collectionView.indexPathsForVisibleItems;
        NSArray *sortedIndexPaths = [visibleCellIndexPaths sortedArrayUsingSelector:@selector(compare:)];
        for (NSIndexPath* indexPath in sortedIndexPaths) {
            if (indexPath.row > 3)
                break;
            UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
                HEMSleepEventCollectionViewCell* eventCell = (HEMSleepEventCollectionViewCell*)cell;
                if (CGAffineTransformEqualToTransform(CGAffineTransformIdentity, eventCell.eventTypeButton.transform))
                    [eventCell.eventTypeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            }
        }
    });
}

- (void)configureEventInfoView
{
    UIFont* emFont = [UIFont fontWithName:@"Calibre-Medium" size:self.eventInfoView.messageLabel.font.pointSize];
    self.eventInfoMarkdownAttributes = @{
        @(STRONG) : @{
            NSFontAttributeName : emFont,
        }
    };
    self.eventInfoDateFormatter = [NSDateFormatter new];
    self.eventInfoDateFormatter.dateFormat = ([SENSettings timeFormat] == SENTimeFormat12Hour) ? @"h:mm a" : @"H:mm";
    if (!self.eventInfoView) {
        UINib* nib = [UINib nibWithNibName:NSStringFromClass([HEMEventInfoView class]) bundle:nil];
        self.eventInfoView = [[nib instantiateWithOwner:self options:nil] firstObject];
        self.eventInfoView.clockLabel.layer.borderWidth = 1.f;
        self.eventInfoView.clockLabel.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.f].CGColor;
        [self.view addSubview:self.eventInfoView];
    }
    self.eventInfoView.alpha = 0;
}

- (void)presentEventInfoView
{
    if (self.collectionView.numberOfSections > 1 && [self.collectionView numberOfItemsInSection:1] > 0) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        [self positionEventInfoViewRelativeToView:cell];
    }
}

- (void)didTapEventButton:(UIButton*)sender
{
    [self positionEventInfoViewRelativeToView:sender];
}

- (void)positionEventInfoViewRelativeToView:(UIView*)view
{
    CGFloat inset = 40.f;
    CGFloat yAdjustment = 8.f;
    CGFloat clockInset = 14.f;
    CGRect buttonFrame = [self.view convertRect:view.frame fromView:view];
    CGRect frame = CGRectMake(inset, CGRectGetMinY(buttonFrame) - yAdjustment, CGRectGetWidth(self.view.bounds) - inset - clockInset, CGRectGetHeight(self.eventInfoView.bounds));
    NSIndexPath* eventIndexPath = [self indexPathForEventCellWithSubview:view];
    SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:eventIndexPath];
    if (segment.message.length > 0) {
        frame.size.height = HEMSleepEventPopupFullHeight;
    }
    else {
        frame.size.height = HEMSleepEventPopupMinimumHeight;
    }
    CGPoint bottomPoint = CGPointMake(1, CGRectGetMaxY(frame));
    NSIndexPath* popupBottomIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:bottomPoint fromView:self.view]];
    if (popupBottomIndexPath.section != HEMSleepGraphCollectionViewSegmentSection || CGRectGetMaxY(frame) > CGRectGetMaxY(self.view.bounds)) {
        frame.origin.y = CGRectGetMidY(buttonFrame) - (CGRectGetHeight(frame) / 2);
        bottomPoint = CGPointMake(1, CGRectGetMaxY(frame));
        popupBottomIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:bottomPoint fromView:self.view]];
        if (popupBottomIndexPath.section != HEMSleepGraphCollectionViewSegmentSection || CGRectGetMaxY(frame) > CGRectGetMaxY(self.view.bounds)) {
            frame.origin.y = CGRectGetMaxY(buttonFrame) - CGRectGetHeight(frame);
            self.eventInfoView.caretPosition = HEMEventInfoViewCaretPositionBottom;
        }
        else {
            self.eventInfoView.caretPosition = HEMEventInfoViewCaretPositionMiddle;
        }
    }
    else {
        self.eventInfoView.caretPosition = HEMEventInfoViewCaretPositionTop;
    }
    if ((CGRectEqualToRect(self.eventInfoView.frame, frame) || fabsf(CGRectGetMinY(frame) - CGRectGetMinY(self.eventInfoView.frame)) < 10.f) && self.eventInfoView.alpha > 0) {
        [UIView animateWithDuration:0.25f animations:^{
            self.eventInfoView.alpha = 0;
            view.transform = CGAffineTransformIdentity;
        }];
    }
    else {
        [self updateEventInfoViewWithEventAtIndexPath:eventIndexPath];
        [UIView animateWithDuration:0.25f animations:^{
            [self shrinkAllEventButtonsToNormalSize];
            view.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        }];
        if (fabsf(CGRectGetMinY(self.eventInfoView.frame) - CGRectGetMinY(frame)) > (CGRectGetHeight([UIScreen mainScreen].bounds) / 10)) {
            [UIView animateWithDuration:0.15f animations:^{
                self.eventInfoView.alpha = 0;
            } completion:^(BOOL finished) {
                self.eventInfoView.frame = frame;
                [self.eventInfoView setNeedsDisplay];
                [UIView animateWithDuration:0.25f animations:^{
                    self.eventInfoView.alpha = 1;
                }];
            }];
        }
        else {
            [UIView animateWithDuration:0.25f animations:^{
                self.eventInfoView.frame = frame;
                self.eventInfoView.alpha = 1;
                [self.eventInfoView setNeedsDisplay];
            }];
        }
    }
}

- (void)shrinkAllEventButtonsToNormalSize
{
    for (UICollectionViewCell* cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
            HEMSleepEventCollectionViewCell* eventCell = (HEMSleepEventCollectionViewCell*)cell;
            eventCell.eventTypeButton.transform = CGAffineTransformIdentity;
        }
    }
}

- (NSIndexPath*)indexPathForEventCellWithSubview:(UIView*)view
{
    UIView* superview = view.superview;
    if (superview) {
        if ([superview isKindOfClass:[HEMSleepEventCollectionViewCell class]])
            return [self.collectionView indexPathForCell:(UICollectionViewCell*)superview];
        else
            return [self indexPathForEventCellWithSubview:superview];
    }
    return nil;
}

- (void)updateEventInfoViewWithEventAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
    if (segment) {
        self.eventInfoView.titleLabel.text = [self.dataSource localizedNameForSleepEventType:segment.eventType];
        self.eventInfoView.messageLabel.attributedText = markdown_to_attr_string(segment.message, 0, self.eventInfoMarkdownAttributes);
        self.eventInfoView.clockLabel.text = [[self.eventInfoDateFormatter stringFromDate:segment.date] lowercaseString];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (self.eventInfoView.alpha == 0)
        return;
    [UIView animateWithDuration:0.15f animations:^{
        self.eventInfoView.alpha = 0;
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    [UIView animateWithDuration:0.25f animations:^{
        [self shrinkAllEventButtonsToNormalSize];
    }];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return self.collectionView.contentOffset.y < 20.f;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return [self.collectionView contentSize].height > CGRectGetHeight([self.collectionView bounds]);
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:[self view]];
    return fabsf(translation.y) > fabsf(translation.x);
}

#pragma mark UICollectionViewDelegate

- (void)configureCollectionView
{
    self.collectionView.backgroundColor = [HelloStyleKit lightestBlueColor];
    self.dataSource = [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                                  sleepDate:self.dateForNightOfSleep];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    return [cell isKindOfClass:[HEMSleepEventCollectionViewCell class]];
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
        HEMSleepEventCollectionViewCell* eventCell = (HEMSleepEventCollectionViewCell*)cell;
        [eventCell.eventTypeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return NO;
}

- (void)collectionView:(UICollectionView*)cv didEndDisplayingCell:(UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath
{
    if ([cell isKindOfClass:[HEMSleepSummaryCollectionViewCell class]]) {
        [(HEMSleepSummaryCollectionViewCell*)cell setSleepScore:0 animated:NO];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return CGSizeMake(width, HEMSleepSummaryCellHeight);

    case HEMSleepGraphCollectionViewPresleepSection:
        return CGSizeMake(width, HEMPresleepItemCellHeight);

    case HEMSleepGraphCollectionViewSegmentSection: {
        SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];

        CGFloat durationHeight = ([segment.duration doubleValue] / 3600) * (CGRectGetHeight([UIScreen mainScreen].bounds) / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
        if ([self.dataSource segmentForSleepExistsAtIndexPath:indexPath]) {
            return CGSizeMake(width, ceilf(durationHeight));
        }
        else {
            return CGSizeMake(width, MAX(durationHeight, HEMSleepGraphCollectionViewEventMinimumHeight));
        }
    }

    default:
        return CGSizeMake(width, HEMSleepGraphCollectionViewEventMinimumHeight);
    }
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case HEMSleepGraphCollectionViewPresleepSection:
        return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMPresleepHeaderCellHeight);
    default:
        return CGSizeZero;
    }
}

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
