//
//  HEMSnazzBarButton.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSnazzBarButton.h"

@interface HEMSnazzBarButton()

@property (nonatomic, weak) UIImageView* unreadIndicatorView;

@end

@implementation HEMSnazzBarButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureUnreadIndicator];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUnreadIndicator];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureUnreadIndicator];
    }
    return self;
}

- (void)configureUnreadIndicator {
    UIImage* unreadIcon = [UIImage imageNamed:@"unreadIndicator"];

    CGRect iconFrame = CGRectZero;
    iconFrame.size = unreadIcon.size;
    iconFrame.origin.y = (2 * unreadIcon.size.height / 3.0f);
    
    UIImageView* unreadView = [[UIImageView alloc] initWithFrame:iconFrame];
    [unreadView setImage:unreadIcon];
    [unreadView setHidden:YES];
    
    [self addSubview:unreadView];
    
    [self setUnreadIndicatorView:unreadView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIImageView* buttonImageView = [self imageView];
    CGSize iconSize = [[self unreadIndicatorView] image].size;
    CGRect unreadIconFrame = [[self unreadIndicatorView] frame];
    unreadIconFrame.origin.x = CGRectGetMaxX([buttonImageView frame]) - (2 * (iconSize.width / 3.0f));
    [[self unreadIndicatorView] setFrame:unreadIconFrame];
}

- (void)setUnread:(BOOL)unread {
    [[self unreadIndicatorView] setHidden:!unread];
}

@end
