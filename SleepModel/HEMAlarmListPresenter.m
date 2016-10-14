//
//  HEMAlarmListPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 6/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>
#import <SenseKit/SENLocalPreferences.h>

#import "HEMAlarmListPresenter.h"
#import "HEMSubNavigationView.h"
#import "HEMAlarmService.h"
#import "HEMNavigationShadowView.h"
#import "NSString+HEMUtils.h"
#import "HEMAlarmListCell.h"
#import "HEMStyle.h"
#import "HEMMarkdown.h"
#import "HEMMainStoryboard.h"
#import "HEMNoAlarmCell.h"
#import "HEMActionButton.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMAlarmAddButton.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAlarmCache.h"

static CGFloat const HEMAlarmListButtonMinimumScale = 0.95f;
static CGFloat const HEMAlarmListButtonMaximumScale = 1.2f;
static CGFloat const HEMAlarmLoadAnimeDuration = 0.5f;
static CGFloat const HEMAlarmListCellHeight = 96.f;
static CGFloat const HEMAlarmListNoAlarmCellBaseHeight = 292.0f;
static CGFloat const HEMAlarmListItemSpacing = 8.f;
static CGFloat const HEMAlarmNoAlarmHorzMargin = 40.0f;
static NSString *const HEMAlarmListTimeKey = @"alarms.alarm.meridiem.%@";

@interface HEMAlarmListPresenter() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) HEMSubNavigationView* subNav;
@property (nonatomic, weak) HEMAlarmAddButton* addButton;
@property (nonatomic, weak) NSLayoutConstraint* addButtonBottomConstraint;
@property (nonatomic, strong) HEMActivityIndicatorView* addButtonActivityIndicator;
@property (nonatomic, weak) HEMActivityIndicatorView* dataLoadingIndicator;
@property (nonatomic, assign) CGFloat origAddButtonBottomMargin;
@property (nonatomic, weak) HEMAlarmService* alarmService;
@property (nonatomic, strong) NSAttributedString* attributedNoAlarmText;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSError* loadError;
@property (nonatomic, strong) NSDateFormatter *hour24Formatter;
@property (nonatomic, strong) NSDateFormatter *hour12Formatter;
@property (nonatomic, strong) NSDateFormatter *meridiemFormatter;

@end

@implementation HEMAlarmListPresenter

- (instancetype)initWithAlarmService:(HEMAlarmService*)alarmService {
    self = [super init];
    if (self) {
        _alarmService = alarmService;
        _hour12Formatter = [NSDateFormatter new];
        _hour12Formatter.dateFormat = @"hh:mm";
        _hour24Formatter = [NSDateFormatter new];
        _hour24Formatter.dateFormat = @"HH:mm";
        _meridiemFormatter = [NSDateFormatter new];
        _meridiemFormatter.dateFormat = @"a";
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    UICollectionViewFlowLayout *layout = (id)[collectionView collectionViewLayout];
    layout.minimumInteritemSpacing = HEMAlarmListItemSpacing;
    layout.minimumLineSpacing = HEMAlarmListItemSpacing;

    [collectionView setHidden:YES];
    [collectionView setBackgroundColor:[UIColor backgroundColor]];
    
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNav {
    [self setSubNav:subNav];
}

- (void)bindWithAddButton:(HEMAlarmAddButton*)addButton
     withBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [self setOrigAddButtonBottomMargin:[bottomConstraint constant]];
    [self setAddButtonBottomConstraint:bottomConstraint];
    
    [addButton setEnabled:YES];
    [addButton setTitle:@"" forState:UIControlStateDisabled];
    [addButton addTarget:self action:@selector(touchDownAddAlarmButton:) forControlEvents:UIControlEventTouchDown];
    [addButton addTarget:self action:@selector(touchUpOutsideAddAlarmButton:) forControlEvents:UIControlEventTouchUpOutside];
    [addButton addTarget:self action:@selector(addNewAlarm:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setAddButton:addButton];
    [self hideAddButton];
    [self setAddButtonActivityIndicator:[self activityIndicator]];
}

- (void)bindWithDataLoadingIndicator:(HEMActivityIndicatorView*)dataLoadingIndicator {
    [self setDataLoadingIndicator:dataLoadingIndicator];
}

- (void)update {
    [[self collectionView] reloadData];
    [self loadData];
}

#pragma mark - Add Alarm Button Animation

- (void)touchDownAddAlarmButton:(id)sender {
    [UIView animateWithDuration:0.05f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat scale = HEMAlarmListButtonMinimumScale;
                         [[[self addButton] layer] setTransform:CATransform3DMakeScale(scale, scale, 1.f)];
                     }
                     completion:NULL];
}

- (void)touchUpOutsideAddAlarmButton:(id)sender {
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[[self addButton] layer] setTransform:CATransform3DIdentity];
                     }
                     completion:NULL];
}

- (HEMActivityIndicatorView*)activityIndicator {
    CGSize buttonSize = [[self addButton] bounds].size;
    UIImage* indicatorImage = [UIImage imageNamed:@"loaderWhite"];
    CGRect indicatorFrame = CGRectZero;
    indicatorFrame.size = indicatorImage.size;
    indicatorFrame.origin.x = (buttonSize.width - indicatorImage.size.width) / 2.f;
    indicatorFrame.origin.y = (buttonSize.height - indicatorImage.size.height) / 2.f;
    return [[HEMActivityIndicatorView alloc] initWithImage:indicatorImage
                                                  andFrame:indicatorFrame];
}

- (void)hideAddButton {
    CGFloat height = CGRectGetHeight([[self addButton] bounds]);
    CGFloat hiddenBottom = absCGFloat([self origAddButtonBottomMargin]) + height;
    [[self addButtonBottomConstraint] setConstant:hiddenBottom];
}

- (void)showAddButton {
    [self showAddButtonAsLoading:NO];
    [[self addButton] setHidden:[[[self alarmService] alarms] count] == 0];
    
    if ([[self addButtonBottomConstraint] constant] != [self origAddButtonBottomMargin]) {
        [UIView animateWithDuration:HEMAlarmLoadAnimeDuration animations:^{
            [[self addButtonBottomConstraint] setConstant:[self origAddButtonBottomMargin]];
            [[self addButton] layoutIfNeeded];
        }];
    }
}

- (void)showAddButtonAsLoading:(BOOL)loading {
    if (loading) {
        [[self addButton] setEnabled:NO];
        [[self addButton] addSubview:[self addButtonActivityIndicator]];
        [[self addButtonActivityIndicator] start];
    } else {
        [[self addButton] setEnabled:YES];
        [[self addButtonActivityIndicator] stop];
        [[self addButtonActivityIndicator] removeFromSuperview];
    }
}

#pragma mark - Presenter Events

- (void)willAppear {
    [super willAppear];
    [self loadData];
    [self.collectionView reloadData];
}

- (void)willDisappear {
    [super willDisappear];
    [self touchUpOutsideAddAlarmButton:nil];
}

- (void)didAppear {
    [super didAppear];
    CGFloat offset = [[self collectionView] contentOffset].y;
    // if there is a subnav, we need to update the visibility in case the neighbor
    // updated the shared shadowview
    [[[self subNav] shadowView] updateVisibilityWithContentOffset:offset];
    [SENAnalytics track:kHEMAnalyticsEventAlarms];
}

- (void)wasRemovedFromParent {
    [super wasRemovedFromParent];
    [self hideAddButton];
}

- (void)didGainConnectivity {
    [super didGainConnectivity];
    [self loadData];
}

#pragma mark - Retrieving Data

- (void)loadData {
    if ([self isLoading]) {
        return;
    }
    
    [self setLoading:YES];
    [self showDataLoadingIndicatorIfNeeded:YES];
    [self showAddButtonAsLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self alarmService] refreshAlarms:^(NSArray<SENAlarm *> * alarms, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoading:NO];
        [strongSelf showDataLoadingIndicatorIfNeeded:NO];
        [strongSelf setLoadError:error];

        if (error) {
            [strongSelf hideAddButton];
            [[strongSelf collectionView] reloadData];
        } else {
            [strongSelf showAddButton];
            [strongSelf setLoading:NO];
            [[strongSelf collectionView] reloadData];

            if ([[strongSelf delegate] respondsToSelector:@selector(didFinishLoadingDataFrom:)]) {
                [[strongSelf delegate] didFinishLoadingDataFrom:strongSelf];
            }
        }
    }];
    
}

- (void)showDataLoadingIndicatorIfNeeded:(BOOL)show {
    if (![[self alarmService] hasLoadedAlarms]) {
        if (show) {
            [[self dataLoadingIndicator] start];
            [[self dataLoadingIndicator] setHidden:NO];
            [[self collectionView] setHidden:YES];
        }
    }
    
    if (!show) {
        [[self dataLoadingIndicator] stop];
        [[self dataLoadingIndicator] setHidden:YES];
        [[self collectionView] setHidden:NO];
    }
}

#pragma mark - Collection View Delegate / Data Source

- (NSAttributedString*)attributedNoAlarmText {
    if (!_attributedNoAlarmText) {
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineSpacing = 8.f;
        NSMutableDictionary *detailAttributes = [[HEMMarkdown attributesForBackViewText][@(PARA)] mutableCopy];
        
        NSMutableParagraphStyle *paraStyle = [detailAttributes[NSParagraphStyleAttributeName] mutableCopy];
        paraStyle.alignment = NSTextAlignmentCenter;
        detailAttributes[NSParagraphStyleAttributeName] = paraStyle;
        
        [detailAttributes removeObjectForKey:NSForegroundColorAttributeName];
        
        NSString* text = NSLocalizedString(@"alarms.no-alarm.message", nil);
        _attributedNoAlarmText = [[NSAttributedString alloc] initWithString:text attributes:detailAttributes];
    }
    return _attributedNoAlarmText;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray* alarms = [[self alarmService] alarms];
    if (!alarms && ![self loadError]) {
        return 0;
    } else if ([[[self alarmService] alarms] count] > 0) {
        return [[[self alarmService] alarms] count];
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[self alarmService] alarms] count] > 0) {
        return [self collectionView:collectionView alarmCellAtIndexPath:indexPath];
    } else if ([self loadError]) {
        return [self collectionView:collectionView statusCellAtIndexPath:indexPath];
    } else {
        return [self collectionView:collectionView emptyCellAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    alarmCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListCellReuseIdentifier];
    HEMAlarmListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSArray* alarms = [[self alarmService] alarms];
    SENAlarm *alarm = alarms[indexPath.item];
    
    cell.enabledSwitch.on = [alarm isOn];
    cell.enabledSwitch.tag = indexPath.item;
    [cell.enabledSwitch addTarget:self action:@selector(toggleEnableSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateDetailTextInCell:cell fromAlarm:alarm];
    [self updateTimeTextInCell:cell fromAlarm:alarm];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    emptyCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListEmptyCellReuseIdentifier];
    HEMNoAlarmCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [[cell detailLabel] setAttributedText:[self attributedNoAlarmText]];
    [[cell alarmButton] addTarget:self action:@selector(addNewAlarm:) forControlEvents:UIControlEventTouchUpInside];
    [[cell alarmButton] setTitle:[NSLocalizedString(@"alarms.first-alarm.button-title", nil) uppercaseString]
                        forState:UIControlStateNormal];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                   statusCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListStatusCellReuseIdentifier];
    HEMAlarmListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.detailLabel.text = NSLocalizedString(@"alarms.no-data", nil);
    return cell;
}

- (void)updateTimeTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm {
    cell.timeLabel.text = [self localizedTimeForAlarm:alarm];
    if (![[self alarmService] useMilitaryTimeFormat]) {
        NSString *meridiem = alarm.hour < 12 ? @"am" : @"pm";
        NSString *key = [NSString stringWithFormat:HEMAlarmListTimeKey, meridiem];
        cell.meridiemLabel.text = NSLocalizedString(key, nil);
    } else {
        cell.meridiemLabel.text = nil;
    }
}

- (void)updateDetailTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm {
    NSString *detailFormat;
    
    if ([alarm source] == SENAlarmSourceVoice) {
        detailFormat = NSLocalizedString(@"alarms.voice-alarm.format", nil);
    } else if ([alarm isSmartAlarm]) {
        detailFormat = NSLocalizedString(@"alarms.smart-alarm.format", nil);
    } else {
        detailFormat = NSLocalizedString(@"alarms.alarm.format", nil);
    }
    
    NSString *repeatText = [[self alarmService] localizedTextForRepeatFlags:alarm.repeatFlags];
    NSString *detailText = [[NSString stringWithFormat:detailFormat, repeatText] uppercaseString];
    NSDictionary *attributes = [HEMMarkdown attributesForBackViewTitle][@(PARA)];
    
    cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
}

- (NSString *)localizedTimeForAlarm:(SENAlarm *)alarm {
    NSString *const HEMAlarm12HourFormat = @"%ld:%@";
    NSString *const HEMAlarm24HourFormat = @"%02ld:%@";
    struct SENAlarmTime time = (struct SENAlarmTime){.hour = alarm.hour, .minute = alarm.minute };
    NSString *minuteText = [NSString stringWithFormat:@"%02ld", (long)time.minute];
    NSString* format = HEMAlarm24HourFormat;
    if (![[self alarmService] useMilitaryTimeFormat]) {
        format = HEMAlarm12HourFormat;
        if (time.hour > 12) {
            time.hour = (long)(time.hour - 12);
        } else if (time.hour == 0) {
            time.hour = 12;
        }
    }
    return [NSString stringWithFormat:format, time.hour, minuteText];
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self alarmService] alarms] count] > indexPath.item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SENAlarm *alarm = [[[self alarmService] alarms] objectAtIndex:indexPath.item];
    [[self delegate] didSelectAlarm:alarm fromPresenter:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat const HEMAlarmListEmptyCellBaseHeight = 98.f;
    static CGFloat const HEMAlarmListEmptyCellWidthInset = 32.f;
    UICollectionViewFlowLayout *layout = (id)collectionViewLayout;
    CGFloat width = layout.itemSize.width;
    
    NSInteger alarmCount = [[[self alarmService] alarms] count];
    if (alarmCount > 0 || [self loadError]) {
        return CGSizeMake(width, HEMAlarmListCellHeight);
    } else if (alarmCount == 0) {
        NSAttributedString* attributedText = [self attributedNoAlarmText];
        CGFloat maxWidth = width - (HEMAlarmNoAlarmHorzMargin * 2);
        CGFloat textHeight = [attributedText sizeWithWidth:maxWidth].height;
        return CGSizeMake(width, textHeight + HEMAlarmListNoAlarmCellBaseHeight);
    }
    
    CGFloat textWidth = width - HEMAlarmListEmptyCellWidthInset;
    NSString *text = NSLocalizedString(@"alarms.no-alarm.message", nil);
    CGFloat textHeight = [text heightBoundedByWidth:textWidth usingFont:[UIFont backViewTextFont]];
    return CGSizeMake(width, textHeight + HEMAlarmListEmptyCellBaseHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = [scrollView contentOffset].y;
    if (![[self subNav] hasControls]) {
        [[self shadowView] updateVisibilityWithContentOffset:yOffset];
    } else {
        [[[self subNav] shadowView] updateVisibilityWithContentOffset:yOffset];
    }
}

#pragma mark - Actions

- (void)addNewAlarm:(id)sender {
    if (![[self addButton] isEnabled]) {
        return;
    }

    if (![[self alarmService] canCreateMoreAlarms]) {
        NSString* message = NSLocalizedString(@"alarms.error.message.limit-reached", nil);
        NSString* title = NSLocalizedString(@"alarms.error.title.limit-reached", nil);
        [[self delegate] showErrorWithTitle:title message:message fromPresenter:self];
    }
    
    [SENAnalytics track:HEMAnalyticsEventCreateNewAlarm];
    
    void (^animations)() = ^{
        [UIView addKeyframeWithRelativeStartTime:0
                                relativeDuration:0.5
                                      animations:^{
                                          CGFloat scale = HEMAlarmListButtonMaximumScale;
                                          self.addButton.layer.transform = CATransform3DMakeScale(scale, scale, 1.f);
                                      }];
        [UIView addKeyframeWithRelativeStartTime:0.5
                                relativeDuration:0.5
                                      animations:^{ self.addButton.layer.transform = CATransform3DIdentity; }];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished) {
        [[self delegate] addNewAlarmFromPresenter:self];
    };
    
    NSUInteger options = (UIViewKeyframeAnimationOptionCalculationModeCubicPaced | UIViewAnimationOptionCurveEaseIn
                          | UIViewKeyframeAnimationOptionBeginFromCurrentState);
    [UIView animateKeyframesWithDuration:0.35f delay:0.15f options:options animations:animations completion:completion];
}


- (void)toggleEnableSwitch:(UISwitch *)sender {
    NSArray* alarms = [[self alarmService] alarms];
    
    __block SENAlarm *alarm = [alarms objectAtIndex:sender.tag];
    
    BOOL on = [sender isOn];
    if (on
        && [[self alarmService] isAlarmTimeTooSoon:alarm]
        && [[self alarmService] willAlarmRingToday:alarm]) {
        [[self delegate] showErrorWithTitle:NSLocalizedString(@"alarm.save-error.too-soon.title", nil)
                                    message:NSLocalizedString(@"alarm.save-error.too-soon.message", nil)
                              fromPresenter:self];
        sender.on = NO;
        return;
    }
    
    alarm.on = on;
    
    __weak typeof(self) weakSelf = self;
    [[self alarmService] updateAlarms:alarms completion:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            alarm.on = !on;
            sender.on = !on;
            [SENAnalytics trackError:error];
            
            NSString* title = NSLocalizedString(@"alarm.save-error.title", nil);
            [[strongSelf delegate] showErrorWithTitle:title
                                              message:[error localizedDescription]
                                        fromPresenter:strongSelf];
        } else {
            [SENAnalytics trackAlarmToggle:alarm];
        }
    }];
}

#pragma mark - Clean Up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
