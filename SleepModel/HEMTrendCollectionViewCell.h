//
//  HEMTrendCollectionViewCell.h
//  Sense
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMGraphSectionOverlayView, HEMBarGraphView, BEMSimpleLineGraphView, HEMScopePickerView;

@protocol HEMTrendCollectionViewCellDelegate <NSObject>

@required

- (void)didTapTimeScopeButtonWithText:(NSString*)text;
@end

@interface HEMTrendCollectionViewCell : UICollectionViewCell

- (void)setTimeScopesWithOptions:(NSArray*)options;
- (void)showLineGraphWithData:(NSArray*)points max:(CGFloat)max min:(CGFloat)min;
- (void)showBarGraphWithData:(NSArray*)points max:(CGFloat)max min:(CGFloat)min;

@property (nonatomic, weak) IBOutlet HEMBarGraphView* barGraphView;
@property (nonatomic, weak) IBOutlet HEMGraphSectionOverlayView* overlayView;
@property (nonatomic, weak) IBOutlet BEMSimpleLineGraphView* lineGraphView;
@property (nonatomic, weak) IBOutlet HEMScopePickerView* scopePickerView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) id<HEMTrendCollectionViewCellDelegate> delegate;
@end
