//
//  HEMTimelineHeaderCollectionReusableView.h
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTimelineTopBarCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *drawerButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

- (void)setDate:(NSDate*)date;
- (void)setOpened:(BOOL)isOpen;
- (void)setShareEnabled:(BOOL)enabled animated:(BOOL)animated;
- (NSString*)dateTitle;

@end
