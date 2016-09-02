//
//  HEMRoomConditionsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import <Charts/Charts-Swift.h>
#import <SenseKit/SENSensor.h>

#import "NSAttributedString+HEMUtils.h"

#import "HEMRoomConditionsPresenter.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMDescriptionHeaderView.h"
#import "HEMSensorGraphCollectionViewCell.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSensorCollectionViewCell.h"
#import "HEMCardFlowLayout.h"
#import "HEMMainStoryboard.h"
#import "HEMMarkdown.h"
#import "HEMStyle.h"

static NSString* const kHEMRoomConditionsIntroReuseId = @"intro";
// static CGFloat const kHEMCurrentConditionsPairViewHeight = 352.0f;

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
@property (nonatomic, strong) NSArray<SENSensor*>* sensors;
@property (nonatomic, strong) NSError* error;
@property (nonatomic, assign) BOOL loadedIntro;
@property (nonatomic, strong) NSMutableDictionary* chartViewBySensor;

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
    [[self sensorService] stopPollingForCurrentConditions];
}

- (void)userDidSignOut {
    [super userDidSignOut];
    [[self sensorService] stopPollingForCurrentConditions];
}

#pragma mark - Data

- (void)startPolling {
    if ([[self sensors] count] == 0) {
        [self setError:nil];
        [[self collectionView] reloadData];
        [[self activityIndicator] setHidden:NO];
        [[self activityIndicator] start];
    }
    
    __weak typeof(self) weakSelf = self;
    [[self sensorService] pollCurrentConditions:^(NSArray<SENSensor *> * sensors, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf activityIndicator] setHidden:YES];
        [[strongSelf activityIndicator] stop];
        
        if (error) {
            if ([[error domain] isEqualToString:kHEMSensorErrorDomain]
                && [error code] == HEMSensorServiceErrorCodePollingAlreadyStarted) {
                // ignore
            } else {
                [strongSelf setError:error];
                [[strongSelf collectionView] reloadData];
                // TODO: handle error
            }
        } else {
            [strongSelf setError:nil];
            [strongSelf setSensors:sensors];
            [[strongSelf collectionView] reloadData];
        }
        
    }];
}

#pragma mark - Charts

- (ChartViewBase*)chartViewForSensor:(SENSensor*)sensor
                              inCell:(HEMSensorCollectionViewCell*)cell {
    // TODO: for now, use the line chart for every sensor.
    LineChartView* lineChartView = [self chartViewBySensor][[sensor name]];
    
    if (!lineChartView) {
        lineChartView = [[LineChartView alloc] initWithFrame:[[cell graphContainerView] bounds]];
        [lineChartView setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                         | UIViewAutoresizingFlexibleHeight];
        [lineChartView setBackgroundColor:[UIColor whiteColor]];
        [lineChartView setDrawGridBackgroundEnabled:YES];
        [lineChartView setNoDataText:nil];
        [self chartViewBySensor][[sensor name]] = lineChartView;
    }
    
    UIColor* sensorColor = [UIColor colorForCondition:[sensor condition]];
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

// TODO: this is a hack, but since server is returning markdown, we need to temporarily
// convert to attributed string, then back
- (NSString*)sensorMessageFrom:(SENSensor*)sensor {
    if ([[sensor message] length] == 0) {
        return nil;
    }
    return [markdown_to_attr_string([sensor message], 0, [HEMMarkdown attributesForSensorMessage]) string];
}

#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    HEMCardFlowLayout* cardLayout = (id)collectionViewLayout;
    CGSize itemSize = [cardLayout itemSize];
    
    SENSensor* sensor = [self sensors][[indexPath row]];
    itemSize.height = [HEMSensorCollectionViewCell heightWithDescription:[self sensorMessageFrom:sensor]
                                                               cellWidth:itemSize.width];
    return itemSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[self sensors] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard sensorReuseIdentifier];
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSensorCollectionViewCell class]]) {
        SENSensor* sensor = [self sensors][[indexPath row]];
        HEMSensorCollectionViewCell* sensorCell = (id)cell;
        ChartViewBase* chartView = [self chartViewForSensor:sensor inCell:sensorCell];
        [[sensorCell descriptionLabel] setText:[self sensorMessageFrom:sensor]];
        [[sensorCell nameLabel] setText:[[sensor localizedName] uppercaseString]];
        [[sensorCell valueLabel] setText:[sensor localizedValue]];
        [[sensorCell valueLabel] setTextColor:[UIColor colorForCondition:[sensor condition]]];
        [[sensorCell unitLabel] setText:nil]; // TODO add it
        [[sensorCell graphContainerView] addSubview:chartView];
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

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
