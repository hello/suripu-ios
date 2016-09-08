//
//  HEMRoomConditionsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Charts/Charts-Swift.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSensorStatus.h>

#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"

#import "HEMRoomConditionsPresenter.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMDescriptionHeaderView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSenseRequiredCollectionViewCell.h"
#import "HEMSensorCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMCardFlowLayout.h"
#import "HEMActionButton.h"
#import "HEMMainStoryboard.h"
#import "HEMMarkdown.h"
#import "HEMStyle.h"

static NSString* const kHEMRoomConditionsIntroReuseId = @"intro";
static CGFloat const kHEMRoomConditionsPairViewHeight = 352.0f;

@interface HEMRoomConditionsPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    ChartViewDelegate
>

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) HEMIntroService* introService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, strong) NSAttributedString* attributedIntroTitle;
@property (nonatomic, strong) NSAttributedString* attributedIntroDesc;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) NSError* sensorError;
@property (nonatomic, assign) BOOL loadedIntro;
@property (nonatomic, strong) NSMutableDictionary* chartViewBySensor;
@property (nonatomic, strong) NSMutableDictionary* sensorDataPoints;
@property (nonatomic, strong) SENSensorStatus* sensorStatus;

@end

@implementation HEMRoomConditionsPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                         introService:(HEMIntroService*)introService {
    self = [super init];
    if (self) {
        _sensorService = sensorService;
        _introService = introService;
        _headerViewHeight = -1.0f;
        _chartViewBySensor = [NSMutableDictionary dictionaryWithCapacity:8];
        _sensorDataPoints = [NSMutableDictionary dictionaryWithCapacity:8];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setBackgroundColor:[UIColor grey2]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    [activityIndicator setHidden:YES];
    [activityIndicator stop];
    [self setActivityIndicator:activityIndicator];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [self startPolling];
}

- (void)didDisappear {
    [super didDisappear];
    // TODO: stop polling
}

- (void)userDidSignOut {
    [super userDidSignOut];
    // TODO: stop polling
}

#pragma mark - Data

- (void)startPolling {
    if (![self sensorStatus]) {
        [self setSensorError:nil];
        [[self collectionView] reloadData];
        [[self activityIndicator] setHidden:NO];
        [[self activityIndicator] start];
    }
    
    __weak typeof(self) weakSelf = self;
    HEMSensorService* service = [self sensorService];
    [service roomStatus:^(SENSensorStatus* status, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf activityIndicator] setHidden:YES];
        [[strongSelf activityIndicator] stop];
        [strongSelf setSensorError:error];
        if (!error && status) {
            [strongSelf setSensorStatus:status];
        }
        [[strongSelf collectionView] reloadData];
        // TODO: poll data for a subset of sensors
    }];
}

#pragma mark - Charts

- (ChartViewBase*)chartViewForSensor:(SENSensor*)sensor
                              inCell:(HEMSensorCollectionViewCell*)cell {
    // TODO: for now, use the line chart for every sensor.
    LineChartView* lineChartView = [self chartViewBySensor][@([sensor type])];
    
    if (!lineChartView) {
        lineChartView = [[LineChartView alloc] initWithFrame:[[cell graphContainerView] bounds]];
        [lineChartView setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                         | UIViewAutoresizingFlexibleHeight];
        [lineChartView setBackgroundColor:[UIColor whiteColor]];
        [lineChartView setDrawGridBackgroundEnabled:YES];
        [lineChartView setNoDataText:nil];
        [self chartViewBySensor][@([sensor type])] = lineChartView;
    }
    
    SENCondition condition = [sensor condition];
    UIColor* sensorColor = [UIColor colorForCondition:condition];
    [lineChartView setGridBackgroundColor:sensorColor];
    
    return lineChartView;
}

#pragma mark - Text

- (NSAttributedString*)attributedIntroTitle {
    if (!_attributedIntroTitle) {
        NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary* attrs = @{NSFontAttributeName : [UIFont h5],
                                NSForegroundColorAttributeName : [UIColor grey6],
                                NSParagraphStyleAttributeName : style};
        
        NSString* title = NSLocalizedString(@"room-conditions.intro.title", nil);
        
        _attributedIntroTitle = [[NSAttributedString alloc] initWithString:title attributes:attrs];
    }
    return _attributedIntroTitle;
}

- (NSAttributedString*)attributedIntroDesc {
    if (!_attributedIntroDesc) {
        NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary* attrs = @{NSFontAttributeName : [UIFont body],
                                NSForegroundColorAttributeName : [UIColor grey5],
                                NSParagraphStyleAttributeName : style};
        
        NSString* desc = NSLocalizedString(@"room-conditions.intro.desc", nil);
        
        _attributedIntroDesc = [[NSAttributedString alloc] initWithString:desc attributes:attrs];
    }
    return _attributedIntroDesc;
}

#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    HEMCardFlowLayout* cardLayout = (id)collectionViewLayout;
    CGSize itemSize = [cardLayout itemSize];
    
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk: {
            
            SENSensor* sensor = [[self sensorStatus] sensors][[indexPath row]];
            itemSize.height = [HEMSensorCollectionViewCell heightWithDescription:[sensor localizedMessage]
                                                                       cellWidth:itemSize.width];
            return itemSize;
        }
        case SENSensorStateNoSense:
            itemSize.height = kHEMRoomConditionsPairViewHeight;
            return itemSize;
        default: {
            if ([self sensorError]) {
                NSString* text = NSLocalizedString(@"sensor.data-unavailable", nil);
                UIFont* font = [UIFont errorStateDescriptionFont];
                CGFloat maxWidth = itemSize.width - (HEMStyleCardErrorTextHorzMargin * 2);
                CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
                itemSize.height = textHeight + (HEMStyleCardErrorTextVertMargin * 2);
            }
            return itemSize;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self sensorStatus] ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk:
            return [[[self sensorStatus] sensors] count];
        case SENSensorStateNoSense:
            return 1;
        default: {
            return [self sensorError] ? 1 : 0;
        }
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk:
            reuseId = [HEMMainStoryboard sensorReuseIdentifier];
            break;
        case SENSensorStateNoSense:
            reuseId = [HEMMainStoryboard pairReuseIdentifier];
            break;
        default:
            reuseId = [self sensorError] ? [HEMMainStoryboard errorReuseIdentifier] : nil;
            break;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSensorCollectionViewCell class]]) {
        SENSensor* sensor = [[self sensorStatus] sensors][[indexPath row]];
        HEMSensorCollectionViewCell* sensorCell = (id)cell;
        SENCondition condition = [sensor condition];
        ChartViewBase* chartView = [self chartViewForSensor:sensor inCell:sensorCell];
        [[sensorCell descriptionLabel] setText:[sensor localizedMessage]];
        [[sensorCell nameLabel] setText:[[sensor localizedName] uppercaseString]];
        [[sensorCell valueLabel] setText:[NSString stringWithFormat:@"%@", [sensor value]]];
        [[sensorCell valueLabel] setTextColor:[UIColor colorForCondition:condition]];
        [[sensorCell unitLabel] setText:nil]; // TODO add it
        [[sensorCell graphContainerView] addSubview:chartView];
    } else if ([cell isKindOfClass:[HEMSenseRequiredCollectionViewCell class]]) {
        HEMSenseRequiredCollectionViewCell* senseCell = (id)cell;
        NSString* buttonTitle = NSLocalizedString(@"room-conditions.pair-sense.button.title", nil);
        NSString* message = NSLocalizedString(@"room-conditions.pair-sense.message", nil);
        [[senseCell descriptionLabel] setText:message];
        [[senseCell pairSenseButton] addTarget:self
                                        action:@selector(pairSense)
                              forControlEvents:UIControlEventTouchUpInside];
        [[senseCell pairSenseButton] setTitle:[buttonTitle uppercaseString]
                                     forState:UIControlStateNormal];
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) { // error
        HEMTextCollectionViewCell* textCell = (id)cell;
        [[textCell textLabel] setText:NSLocalizedString(@"sensor.data-unavailable", nil)];
        [[textCell textLabel] setFont:[UIFont errorStateDescriptionFont]];
        [textCell displayAsACard:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeZero;
    if ([[self introService] shouldIntroduceType:HEMIntroTypeRoomConditions]) {
        if ([self headerViewHeight] < 0.0f) {
            HEMCardFlowLayout* flowLayout = (id) collectionViewLayout;
            NSAttributedString* title = [self attributedIntroTitle];
            NSAttributedString* message = [self attributedIntroDesc];
            CGFloat itemWidth = [flowLayout itemSize].width;
            [self setHeaderViewHeight:[HEMDescriptionHeaderView heightWithTitle:title
                                                                     description:message
                                                                widthConstraint:itemWidth]];
        }
        headerSize.height = [self headerViewHeight];
    }
    return headerSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = kHEMRoomConditionsIntroReuseId;
    HEMDescriptionHeaderView* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                          withReuseIdentifier:reuseId
                                                                                 forIndexPath:indexPath];
    
    [[header titlLabel] setAttributedText:[self attributedIntroTitle]];
    [[header descriptionLabel] setAttributedText:[self attributedIntroDesc]];
    [[header descriptionLabel] sizeToFit];
    [[header imageView] setImage:[UIImage imageNamed:@"introRoomConditions"]];
    
    if (![self loadedIntro]) {
        [[self introService] incrementIntroViewsForType:HEMIntroTypeRoomConditions];
        [self setLoadedIntro:YES];
    }
    
    return header;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Actions

- (void)pairSense {
    [[self pairDelegate] pairSenseFrom:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
