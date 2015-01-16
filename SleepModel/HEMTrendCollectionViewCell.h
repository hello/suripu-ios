//
//  HEMTrendCollectionViewCell.h
//  Sense
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

typedef NS_ENUM(NSUInteger, HEMTrendCellGraphType) {
    HEMTrendCellGraphTypeLine,
    HEMTrendCellGraphTypeBar,
    HEMTrendCellGraphTypeNone,
};

typedef NS_ENUM(NSUInteger, HEMTrendCellGraphLabelType) {
    HEMTrendCellGraphLabelTypeNone,
    HEMTrendCellGraphLabelTypeValue,
    HEMTrendCellGraphLabelTypeHourValue,
    HEMTrendCellGraphLabelTypeDate,
    HEMTrendCellGraphLabelTypeDayOfWeek,
    HEMTrendCellGraphLabelTypeMonth,
};

@class HEMGraphSectionOverlayView, HEMBarGraphView, BEMSimpleLineGraphView,
HEMScopePickerView, HEMTrendCollectionViewCell;

@protocol HEMTrendCollectionViewCellDelegate <NSObject>

@required

- (void)didTapTimeScopeInCell:(HEMTrendCollectionViewCell*)cell withText:(NSString*)text;
@end

@interface HEMTrendCollectionViewCell : HEMCardCollectionViewCell

- (void)setTimeScopesWithOptions:(NSArray*)options selectedOptionIndex:(NSUInteger)selectedIndex;
- (void)showGraphOfType:(HEMTrendCellGraphType)type withData:(NSArray*)data;

@property (nonatomic, weak) IBOutlet HEMBarGraphView* barGraphView;
@property (nonatomic, weak) IBOutlet HEMGraphSectionOverlayView* overlayView;
@property (nonatomic, weak) IBOutlet BEMSimpleLineGraphView* lineGraphView;
@property (nonatomic, weak) IBOutlet HEMScopePickerView* scopePickerView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@property (nonatomic, weak) id<HEMTrendCollectionViewCellDelegate> delegate;
@property (nonatomic) HEMTrendCellGraphLabelType topLabelType;
@property (nonatomic) HEMTrendCellGraphLabelType bottomLabelType;
@property (nonatomic) NSUInteger numberOfGraphSections;
@property (nonatomic, getter=shouldShowGraphLabels) BOOL showGraphLabels;
@end
