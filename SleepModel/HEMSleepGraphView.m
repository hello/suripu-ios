//
//  HEMSleepGraphView.m
//  Sense
//
//  Created by Delisa Mason on 12/4/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIImageEffects/UIImage+ImageEffects.h>
#import <SenseKit/SENSleepResult.h>
#import <AttributedMarkdown/markdown_peg.h>

#import "HEMSleepGraphView.h"
#import "HEMEventInfoView.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HEMPresleepHeaderCollectionReusableView.h"
#import "HEMSleepGraphViewController.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMAudioCache.h"

@interface HEMSleepGraphView ()
@property (strong, nonatomic) UIView* eventBlurView;
@property (strong, nonatomic) UIView* eventBandView;
@property (strong, nonatomic) UILabel* eventTimelineHeaderLabel;
@end

@implementation HEMSleepGraphView

static CGFloat const HEMSleepEventPopupFullHeight = 90.f;
static CGFloat const HEMSleepEventPopupMinimumHeight = 50.f;

- (void)awakeFromNib {
    [self configureEventInfoViews];
}

- (void)configureEventInfoViews {
    if (!self.eventInfoView) {
        UINib* nib = [UINib nibWithNibName:NSStringFromClass([HEMEventInfoView class]) bundle:nil];
        self.eventInfoView = [[nib instantiateWithOwner:self options:nil] firstObject];
        [self addSubview:self.eventInfoView];
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
        [self insertSubview:self.eventBlurView belowSubview:self.eventInfoView];
        [self insertSubview:self.eventBandView aboveSubview:self.eventBlurView];
        [self insertSubview:self.eventTimelineHeaderLabel aboveSubview:self.eventBlurView];
    }
    self.eventInfoView.alpha = 0;
    self.eventBlurView.alpha = 0;
    self.eventBandView.alpha = 0;
    self.eventTimelineHeaderLabel.alpha = 0;
}

- (void)addVerifyDataTarget:(id)target action:(SEL)action
{
    [self.eventInfoView.verifyDataButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)showEventBlurView
{
    NSUInteger section = HEMSleepGraphCollectionViewSegmentSection;
    NSIndexPath* topIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSUInteger total = [self.collectionView numberOfItemsInSection:section];
    NSIndexPath* bottomIndexPath = [NSIndexPath indexPathForItem:total - 1 inSection:section];
    UICollectionViewCell* topCell = [self.collectionView cellForItemAtIndexPath:topIndexPath];
    UICollectionViewCell* bottomCell = [self.collectionView cellForItemAtIndexPath:bottomIndexPath];
    [self showEventBlurViewBetweenTopCell:topCell andBottomCell:bottomCell];
}

- (void)showEventBlurViewBetweenTopCell:(UICollectionViewCell*)topCell andBottomCell:(UICollectionViewCell*)bottomCell
{
    if (self.eventBandView.alpha == 1 && self.eventBlurView.alpha == 1)
        return;

    CGRect blurRect;
    CGFloat minX = 0.f;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat bandYOffset = 4.f;
    if (topCell && bottomCell) {
        CGRect topCellRect = [self convertRect:topCell.frame fromView:self.collectionView];
        CGRect bottomCellRect = [self convertRect:bottomCell.frame fromView:self.collectionView];
        CGFloat height = CGRectGetMaxY(bottomCellRect) - CGRectGetMinY(topCellRect);
        blurRect = CGRectMake(minX, CGRectGetMinY(topCellRect), width, height);
    } else if (topCell) {
        CGRect topCellRect = [self convertRect:topCell.frame fromView:self.collectionView];
        blurRect = CGRectMake(minX, CGRectGetMinY(topCellRect), width, CGRectGetHeight(self.bounds));
    } else if (bottomCell) {
        CGRect bottomCellRect = [self convertRect:bottomCell.frame fromView:self.collectionView];
        blurRect = CGRectMake(minX, 0, width, CGRectGetMaxY(bottomCellRect));
    } else {
        blurRect = CGRectInset(self.bounds, 0, -HEMTimelineHeaderCellHeight);
    }

    CGRect bandRect = CGRectMake(HEMLinedCollectionViewCellLineOffset + HEMLinedCollectionViewCellLineWidth,
                                 CGRectGetMinY(blurRect),
                                 HEMSleepSegmentMinimumFillWidth,
                                 CGRectGetHeight(blurRect) - bandYOffset/2);
    blurRect.origin.y -= HEMTimelineHeaderCellHeight;
    blurRect.size.height += (HEMTimelineHeaderCellHeight + HEMPresleepSummaryLineOffset);
    UIImage* bandSnapshot = [self.collectionView snapshotOfRect:bandRect];
    UIImage* blurSnapshot = [[self.collectionView snapshotOfRect:blurRect] applyBlurWithRadius:0
                                                                                     tintColor:[UIColor colorWithWhite:1.f alpha:0.95]
                                                                         saturationDeltaFactor:1.2
                                                                                     maskImage:nil];
    self.eventBlurView.backgroundColor = [UIColor colorWithPatternImage:blurSnapshot];
    self.eventBlurView.frame = blurRect;
    self.eventBandView.backgroundColor = [UIColor colorWithPatternImage:bandSnapshot];
    bandRect.origin.y += 1;
    self.eventBandView.frame = bandRect;
    self.eventTimelineHeaderLabel.frame = CGRectMake(CGRectGetMinX(bandRect), CGRectGetMinY(blurRect), CGRectGetWidth(self.bounds), HEMTimelineHeaderCellHeight);
    self.eventBandView.alpha = 1;
    [UIView animateWithDuration:0.5f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.eventBlurView.alpha = 1;
        self.eventTimelineHeaderLabel.alpha = 1;
    } completion:NULL];
}

- (void)hideEventBlurView
{
    self.eventBlurView.alpha = 0;
    self.eventTimelineHeaderLabel.alpha = 0;
}

- (void)hideEventInfoView
{
    [self.eventInfoView stopAudio];
    if (self.eventInfoView.alpha == 0 && self.eventBandView.alpha == 0 && self.eventBlurView.alpha == 0)
        return;
    [self hideEventBlurView];
    [UIView animateWithDuration:0.15f animations:^{
        self.eventInfoView.alpha = 0;
    }];
    self.eventBandView.alpha = 0;
}

- (void)updateEventInfoViewWithSegment:(SENSleepResultSegment*)segment
{
    if (segment) {
        NSString* title = [NSString stringWithFormat:NSLocalizedString(@"sleep-event.title.format", nil),
                           [[HEMSleepGraphCollectionViewDataSource localizedNameForSleepEventType:segment.eventType] uppercaseString],
                           [[self.eventInfoView.timestampDateFormatter stringFromDate:segment.date] lowercaseString]];
        self.eventInfoView.titleLabel.text = title;

        self.eventInfoView.verifyDataButton.hidden = ![segment.eventType isEqual:HEMSleepEventTypeWakeUp];
        NSAttributedString* message = markdown_to_attr_string(segment.message, 0, self.eventInfoView.markdownAttributes);
        while (message.length > 0 && [[message string] characterAtIndex:message.length - 1] == '\n')
            message = [message attributedSubstringFromRange:NSMakeRange(0, message.length - 1)];
        self.eventInfoView.messageLabel.attributedText = message;
        [self.eventInfoView.messageLabel sizeToFit];
        if (segment.sound) {
            [self.eventInfoView showAudioPlayer:YES];
            [self.eventInfoView setLoading:YES];
            [HEMAudioCache cacheURLforAssetAtPath:segment.sound.URLPath completion:^(NSURL *url, NSError *error) {
                if (url) {
                    [self.eventInfoView setAudioURL:url];
                } else {
                    [self.eventInfoView setLoading:NO];
                }
            }];
        } else {
            [self.eventInfoView setLoading:NO];
            [self.eventInfoView showAudioPlayer:NO];
        }
        [self.eventInfoView updateConstraintsIfNeeded];
    }
}

- (void)positionEventInfoViewRelativeToView:(UIView*)view
                                withSegment:(SENSleepResultSegment*)segment
                          totalSegmentCount:(NSUInteger)segmentCount
{
    [self.eventInfoView stopAudio];
    CGFloat inset = 50.f;
    CGFloat yAdjustment = 8.f;
    CGFloat clockInset = 24.f;
    CGRect buttonFrame = [self convertRect:view.frame fromView:view.superview];
    CGRect frame = CGRectMake(inset, CGRectGetMinY(buttonFrame) - yAdjustment, CGRectGetWidth(self.bounds) - inset - clockInset, CGRectGetHeight(self.eventInfoView.bounds));

    if (segment.message.length > 0)
        frame.size.height = HEMSleepEventPopupFullHeight;
    else
        frame.size.height = HEMSleepEventPopupMinimumHeight;

    if (segment.sound)
        frame.size.height += CGRectGetHeight(self.eventInfoView.playSoundButton.bounds);
    else if ([segment.eventType isEqual:HEMSleepEventTypeWakeUp])
        frame.size.height += CGRectGetHeight(self.eventInfoView.verifyDataButton.bounds);

    CGPoint bottomPoint = CGPointMake(1, CGRectGetMaxY(frame));
    NSIndexPath* popupBottomIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:bottomPoint fromView:self]];
    if (popupBottomIndexPath.section != HEMSleepGraphCollectionViewSegmentSection || CGRectGetMaxY(frame) > CGRectGetMaxY(self.bounds)) {
        frame.origin.y = CGRectGetMidY(buttonFrame) - (CGRectGetHeight(frame) / 2);
        bottomPoint = CGPointMake(1, CGRectGetMaxY(frame));
        popupBottomIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:bottomPoint fromView:self]];
        if (popupBottomIndexPath.section != HEMSleepGraphCollectionViewSegmentSection || CGRectGetMaxY(frame) > CGRectGetMaxY(self.bounds)) {
            frame.origin.y = CGRectGetMaxY(buttonFrame) - CGRectGetHeight(frame);
            self.eventInfoView.caretPosition = HEMEventInfoViewCaretPositionBottom;
        } else {
            self.eventInfoView.caretPosition = HEMEventInfoViewCaretPositionMiddle;
        }
    } else {
        self.eventInfoView.caretPosition = HEMEventInfoViewCaretPositionTop;
    }
    if ((CGRectEqualToRect(self.eventInfoView.frame, frame) || fabsf(CGRectGetMinY(frame) - CGRectGetMinY(self.eventInfoView.frame)) < 10.f) && self.eventInfoView.alpha > 0) {
        [UIView animateWithDuration:0.25f animations:^{
            [self hideEventBlurView];
            self.eventInfoView.alpha = 0;
        } completion:^(BOOL finished) {
            self.eventBandView.alpha = 0;
        }];
    } else {
        [self updateEventInfoViewWithSegment:segment];
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
        } else {
            [self showEventBlurView];
            [UIView animateWithDuration:0.25f animations:^{
                self.eventInfoView.frame = frame;
                self.eventInfoView.alpha = 1;
                [self.eventInfoView setNeedsDisplay];
            }];
        }
    }
}

@end
