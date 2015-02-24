//
//  HEMTextLinkFooterCollectionReusableView.h
//  Sense
//
//  Created by Jimmy Lu on 2/20/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMTextFooterCollectionReusableView;

@protocol HEMTextFooterDelegate <NSObject>

- (void)didTapOnLink:(NSURL*)url from:(HEMTextFooterCollectionReusableView*)view;

@end

@interface HEMTextFooterCollectionReusableView : UICollectionReusableView

@property (nonatomic, weak) id<HEMTextFooterDelegate> delegate;

- (void)setText:(NSAttributedString*)attributedText;

@end
