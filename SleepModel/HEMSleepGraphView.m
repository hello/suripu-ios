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
#import "HEMSleepGraphViewController.h"
#import "NSAttributedString+HEMUtils.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMAudioCache.h"

@interface HEMSleepGraphView ()
@property (strong, nonatomic) UIView* eventBlurView;
@property (strong, nonatomic) UIView* eventBandView;
@property (strong, nonatomic) UILabel* eventTimelineHeaderLabel;
@property (strong, nonatomic) NSLayoutConstraint* eventInfoWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint* eventInfoHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint* eventInfoLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint* eventInfoTopConstraint;
@end

@implementation HEMSleepGraphView

static CGFloat const HEMSleepEventPopupFullHeight = 90.f;
static CGFloat const HEMSleepEventPopupMinimumHeight = 50.f;
static CGFloat const HEMSleepEventPopupLeftInset = 50.f;
static CGFloat const HEMSleepEventPopupTopInset = 8.f;
static CGFloat const HEMSleepEventPopupWidthInset = 74.f;
static CGFloat const HEMSleepEventPopupMaxWidth = 400.f;

- (void)awakeFromNib
{
    [self configureEventInfoView];
    [self configureEventInfoBackgroundViews];
    [self configureConstraints];
}

- (void)configureEventInfoView
{
    if (!self.eventInfoView) {
        UINib* nib = [UINib nibWithNibName:NSStringFromClass([HEMEventInfoView class]) bundle:nil];
        self.eventInfoView = [[nib instantiateWithOwner:self options:nil] firstObject];
        [self addSubview:self.eventInfoView];
    }
    self.eventInfoView.alpha = 0;
}

- (void)configureEventInfoBackgroundViews
{
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

    self.eventBlurView.alpha = 0;
    self.eventBandView.alpha = 0;
    self.eventTimelineHeaderLabel.alpha = 0;
}

- (void)configureConstraints
{
    if (!self.eventInfoWidthConstraint) {
        self.eventInfoWidthConstraint = [NSLayoutConstraint constraintWithItem:self.eventInfoView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:300];
        self.eventInfoHeightConstraint = [NSLayoutConstraint constraintWithItem:self.eventInfoView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:190];
        self.eventInfoLeftConstraint = [NSLayoutConstraint constraintWithItem:self.eventInfoView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1
                                                                     constant:HEMSleepEventPopupLeftInset];
        self.eventInfoTopConstraint = [NSLayoutConstraint constraintWithItem:self.eventInfoView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:0.f];
        [self.eventInfoView addConstraint:self.eventInfoWidthConstraint];
        [self.eventInfoView addConstraint:self.eventInfoHeightConstraint];
        [self addConstraint:self.eventInfoTopConstraint];
        [self addConstraint:self.eventInfoLeftConstraint];
        [self.eventInfoView setNeedsLayout];
    }
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
    blurRect.size.height += HEMTimelineHeaderCellHeight;
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
        self.eventInfoView.messageLabel.attributedText = [message trim];
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
    HEMEventInfoViewCaretPosition caretPosition = HEMEventInfoViewCaretPositionMiddle;
    CGRect buttonFrame = [self convertRect:view.frame fromView:view.superview];
    CGRect frame = CGRectMake(self.eventInfoLeftConstraint.constant,
                              CGRectGetMinY(buttonFrame) - HEMSleepEventPopupTopInset,
                              MIN(CGRectGetWidth(self.bounds) - HEMSleepEventPopupWidthInset, HEMSleepEventPopupMaxWidth),
                              [self heightBySegment:segment]);

    CGPoint bottomPoint = CGPointMake(1, CGRectGetMaxY(frame));
    NSIndexPath* popupBottomIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:bottomPoint fromView:self]];
    if (popupBottomIndexPath.section != HEMSleepGraphCollectionViewSegmentSection || CGRectGetMaxY(frame) > CGRectGetMaxY(self.bounds)) {
        frame.origin.y = CGRectGetMidY(buttonFrame) - (CGRectGetHeight(frame) / 2);
        bottomPoint = CGPointMake(1, CGRectGetMaxY(frame));
        popupBottomIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:bottomPoint fromView:self]];
        if (popupBottomIndexPath.section != HEMSleepGraphCollectionViewSegmentSection || CGRectGetMaxY(frame) > CGRectGetMaxY(self.bounds)) {
            frame.origin.y = CGRectGetMaxY(buttonFrame) - CGRectGetHeight(frame) + HEMSleepEventPopupTopInset;
            caretPosition = HEMEventInfoViewCaretPositionBottom;
        } else {
            caretPosition = HEMEventInfoViewCaretPositionMiddle;
        }
    } else {
        caretPosition = HEMEventInfoViewCaretPositionTop;
    }
    if (self.eventInfoView.alpha > 0
        && caretPosition == self.eventInfoView.caretPosition
        && fabsf(CGRectGetMinY(frame) - CGRectGetMinY(self.eventInfoView.frame)) < 10.f) {
        [self toggleInfoViewHidden];
    } else {
        self.eventInfoView.caretPosition = caretPosition;
        [self updateEventInfoViewWithSegment:segment];
        [self showEventInfoInFrame:frame];
    }
}

- (CGFloat)heightBySegment:(SENSleepResultSegment*)segment
{
    CGFloat height;
    if (segment.message.length > 0)
        height = HEMSleepEventPopupFullHeight;
    else
        height = HEMSleepEventPopupMinimumHeight;

    if (segment.sound)
        height += CGRectGetHeight(self.eventInfoView.playSoundButton.bounds);
    else if ([segment.eventType isEqual:HEMSleepEventTypeWakeUp])
        height += CGRectGetHeight(self.eventInfoView.verifyDataButton.bounds);
    return height;
}

- (void)toggleInfoViewHidden
{
    [UIView animateWithDuration:0.25f animations:^{
        [self hideEventBlurView];
        self.eventInfoView.alpha = 0;
    } completion:^(BOOL finished) {
        self.eventBandView.alpha = 0;
    }];
}

- (void)showEventInfoInFrame:(CGRect)frame
{
    CGFloat distanceMoved = CGRectGetMinY(self.eventInfoView.frame) - CGRectGetMinY(frame);
    CGFloat movableDistance = CGRectGetHeight([UIScreen mainScreen].bounds) / 10;
    if (fabsf(distanceMoved) > movableDistance) {
        [UIView animateWithDuration:0.15f animations:^{
            self.eventInfoView.alpha = 0;
        } completion:^(BOOL finished) {
            [self showEventBlurView];
            [self moveEventInfoViewToFrame:frame];
            [UIView animateWithDuration:0.25f animations:^{
                self.eventInfoView.alpha = 1;
            }];
        }];
    } else {
        [self showEventBlurView];
        [UIView animateWithDuration:0.25f animations:^{
            [self moveEventInfoViewToFrame:frame];
            self.eventInfoView.alpha = 1;
        }];
    }
}

- (void)moveEventInfoViewToFrame:(CGRect)frame
{
    self.eventInfoTopConstraint.constant = CGRectGetMinY(frame);
    self.eventInfoHeightConstraint.constant = CGRectGetHeight(frame);
    self.eventInfoWidthConstraint.constant = CGRectGetWidth(frame);
    [self.eventInfoView layoutIfNeeded];
}

@end
