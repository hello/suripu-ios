
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>
#import <UIImageEffects/UIImage+ImageEffects.h>
#import <markdown_peg.h>

#import "HEMSleepGraphViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMEventInfoView.h"
#import "HEMPaddedRoundedLabel.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
@property (nonatomic) UIStatusBarStyle oldBarStyle;
@property (strong, nonatomic) IBOutlet UICollectionView* collectionView;
@property (strong, nonatomic) HEMEventInfoView* eventInfoView;
@property (strong, nonatomic) UIView* eventBlurView;
@property (strong, nonatomic) UIView* eventBandView;
@property (strong, nonatomic) UILabel* eventTimelineHeaderLabel;
@property (strong, nonatomic) NSDictionary* eventInfoMarkdownAttributes;
@property (strong, nonatomic) NSDateFormatter* eventInfoDateFormatter;
@end

@implementation HEMSleepGraphViewController

static CGFloat const HEMSleepSummaryCellHeight = 350.f;
static CGFloat const HEMSleepEventPopupFullHeight = 100.f;
static CGFloat const HEMSleepEventPopupMinimumHeight = 50.f;
static CGFloat const HEMPresleepHeaderCellHeight = 84.f;
static CGFloat const HEMTimelineHeaderCellHeight = 50.f;
static CGFloat const HEMPresleepItemCellHeight = 48.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 30.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;

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
    }];
    self.oldBarStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidPush
{
    self.panePanGestureRecognizer.delegate = self;
    self.oldBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.collectionView.scrollEnabled = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark Event Info Popup

- (void)configureEventInfoView
{
    self.eventInfoMarkdownAttributes = @{
        @(STRONG) : @{
            NSFontAttributeName : [UIFont timelineEventMessageBoldFont],
        },
        @(PLAIN) : @{
            NSFontAttributeName : [UIFont timelineEventMessageFont]
        }
    };
    self.eventInfoDateFormatter = [NSDateFormatter new];
    self.eventInfoDateFormatter.dateFormat = ([SENSettings timeFormat] == SENTimeFormat12Hour) ? @"h:mm a" : @"H:mm";
    if (!self.eventInfoView) {
        UINib* nib = [UINib nibWithNibName:NSStringFromClass([HEMEventInfoView class]) bundle:nil];
        self.eventInfoView = [[nib instantiateWithOwner:self options:nil] firstObject];
        [self.view addSubview:self.eventInfoView];
    }
    if (!self.eventBlurView) {
        self.eventBlurView = [UIView new];
        self.eventBandView = [UIView new];
        self.eventTimelineHeaderLabel = [UILabel new];
        self.eventTimelineHeaderLabel.font = [UIFont insightTitleFont];
        self.eventTimelineHeaderLabel.textColor = [UIColor grayColor];
        self.eventTimelineHeaderLabel.text = [NSLocalizedString(@"sleep-event.timeline.title", nil) uppercaseString];
        self.eventBlurView.userInteractionEnabled = NO;
        self.eventBandView.userInteractionEnabled = NO;
        self.eventBandView.layer.cornerRadius = floorf(HEMSleepSegmentMinimumFillWidth/2);
        [self.view insertSubview:self.eventBlurView belowSubview:self.eventInfoView];
        [self.view insertSubview:self.eventBandView aboveSubview:self.eventBlurView];
        [self.view insertSubview:self.eventTimelineHeaderLabel aboveSubview:self.eventBlurView];
    }
    self.eventInfoView.alpha = 0;
    self.eventBlurView.alpha = 0;
    self.eventBandView.alpha = 0;
    self.eventTimelineHeaderLabel.alpha = 0;
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

- (UIImage*)timelineSnapshotInRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [self.collectionView drawViewHierarchyInRect:CGRectMake(-CGRectGetMinX(rect), -CGRectGetMinY(rect), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)positionEventInfoViewRelativeToView:(UIView*)view
{
    CGFloat inset = 50.f;
    CGFloat yAdjustment = 8.f;
    CGFloat clockInset = 24.f;
    CGRect buttonFrame = [self.view convertRect:view.frame fromView:view.superview];
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
        [self hideEventBlurView];
        [UIView animateWithDuration:0.25f animations:^{
            self.eventInfoView.alpha = 0;
        }];
    }
    else {
        [self updateEventInfoViewWithEventAtIndexPath:eventIndexPath];
        if (fabsf(CGRectGetMinY(self.eventInfoView.frame) - CGRectGetMinY(frame)) > (CGRectGetHeight([UIScreen mainScreen].bounds) / 10)) {
            [UIView animateWithDuration:0.15f animations:^{
                self.eventInfoView.alpha = 0;
            } completion:^(BOOL finished) {
                [self showEventBlurView];
                self.eventInfoView.frame = frame;
                [self.eventInfoView setNeedsDisplay];
                [UIView animateWithDuration:0.25f animations:^{
                    self.eventInfoView.alpha = 1;
                }];
            }];
        }
        else {
            [self showEventBlurView];
            [UIView animateWithDuration:0.25f animations:^{
                self.eventInfoView.frame = frame;
                self.eventInfoView.alpha = 1;
                [self.eventInfoView setNeedsDisplay];
            }];
        }
    }
}

- (void)showEventBlurView
{
    CGRect blurRect = CGRectZero;
    CGFloat minX = 0.f;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    UICollectionViewCell* topCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:HEMSleepGraphCollectionViewSegmentSection]];
    UICollectionViewCell* bottomCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self.dataSource numberOfSleepSegments] - 1 inSection:HEMSleepGraphCollectionViewSegmentSection]];
    if (topCell && bottomCell) {
        CGRect topCellRect = [self.view convertRect:topCell.frame fromView:self.collectionView];
        CGRect bottomCellRect = [self.view convertRect:bottomCell.frame fromView:self.collectionView];
        CGFloat height = CGRectGetMaxY(bottomCellRect) - CGRectGetMinY(topCellRect);
        blurRect = CGRectMake(minX, CGRectGetMinY(topCellRect), width, height);
    } else if (topCell) {
        CGRect topCellRect = [self.view convertRect:topCell.frame fromView:self.collectionView];
        blurRect = CGRectMake(minX, CGRectGetMinY(topCellRect), width, CGRectGetHeight(self.view.bounds) - CGRectGetMinX(topCellRect));
    } else if (bottomCell) {
        CGRect bottomCellRect = [self.view convertRect:bottomCell.frame fromView:self.collectionView];
        blurRect = CGRectMake(minX, 0, width, CGRectGetMaxY(bottomCellRect));
    } else {
        blurRect = self.view.bounds;
    }
    blurRect.origin.y -= HEMTimelineHeaderCellHeight;
    blurRect.size.height += HEMTimelineHeaderCellHeight;
    CGFloat bandYOffset = 4.f;
    CGRect bandRect = blurRect;
    bandRect.origin.x = HEMLinedCollectionViewCellLineOffset + HEMLinedCollectionViewCellLineWidth;
    bandRect.origin.y += HEMTimelineHeaderCellHeight;
    bandRect.size.height = CGRectGetHeight(blurRect) - HEMTimelineHeaderCellHeight - bandYOffset/2;
    if (blurRect.origin.y == -HEMTimelineHeaderCellHeight) {
        bandRect.origin.y -= HEMSleepSegmentMinimumFillWidth;
        bandRect.size.height += HEMSleepSegmentMinimumFillWidth;
    } else {
        bandRect.origin.y += bandYOffset;
        bandRect.size.height -= bandYOffset;
    }
    bandRect.size.width = HEMSleepSegmentMinimumFillWidth;
    UIImage* bandSnapshot = [self timelineSnapshotInRect:bandRect];
    UIImage* blurSnapshot = [[self timelineSnapshotInRect:blurRect] applyBlurWithRadius:15
                                                                              tintColor:[UIColor colorWithWhite:1.f alpha:0.1]
                                                                  saturationDeltaFactor:1.2
                                                                              maskImage:nil];
    self.eventBlurView.backgroundColor = [UIColor colorWithPatternImage:blurSnapshot];
    self.eventBlurView.frame = blurRect;
    self.eventBandView.backgroundColor = [UIColor colorWithPatternImage:bandSnapshot];
    self.eventBandView.frame = bandRect;
    self.eventTimelineHeaderLabel.frame = CGRectMake(CGRectGetMinX(bandRect), CGRectGetMinY(blurRect), CGRectGetWidth(self.view.bounds), HEMTimelineHeaderCellHeight);
    [UIView animateWithDuration:0.1f animations:^{
        self.eventBandView.alpha = 1;
        self.eventBlurView.alpha = 1;
        self.eventTimelineHeaderLabel.alpha = 1;
    }];
}

- (void)hideEventBlurView
{
    self.eventBlurView.alpha = 0;
    self.eventBandView.alpha = 0;
    self.eventTimelineHeaderLabel.alpha = 0;
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
        NSString* title = [NSString stringWithFormat:NSLocalizedString(@"sleep-event.title.format", nil), [[self.dataSource localizedNameForSleepEventType:segment.eventType] uppercaseString], [[self.eventInfoDateFormatter stringFromDate:segment.date] lowercaseString]];
        self.eventInfoView.titleLabel.text = title;
        self.eventInfoView.messageLabel.attributedText = markdown_to_attr_string(segment.message, 0, self.eventInfoMarkdownAttributes);
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.eventInfoView.alpha == 0 && self.eventBandView.alpha == 0 && self.eventBlurView.alpha == 0)
        return;
    [self hideEventBlurView];
    [UIView animateWithDuration:0.15f animations:^{
        self.eventInfoView.alpha = 0;
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
    self.collectionView.backgroundColor = [UIColor whiteColor];
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
    case HEMSleepGraphCollectionViewSegmentSection:
        return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineHeaderCellHeight);
    default:
        return CGSizeZero;
    }
}

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
