//
//  HEMTextCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import "HEMTextCollectionViewCell.h"
#import "UIColor+HEMStyle.h"

static CGFloat const HEMTextCollectionHorzPadding = 24.0f;

@interface HEMTextCollectionViewCell()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* separatorHeightConstraint;

@end

@implementation HEMTextCollectionViewCell

+ (CGFloat)heightWithText:(NSString*)text font:(UIFont*)font cellWidth:(CGFloat)width {
    CGSize constraint = {width - (2*HEMTextCollectionHorzPadding), MAXFLOAT};
    return CGRectGetHeight([text boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:@{NSFontAttributeName : font}
                                              context:nil]);
}

- (void)awakeFromNib {
    [self configureContentView];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (void)configureContentView {
    if (![self textLabel]) {
        CGRect frame = CGRectZero;
        frame.origin.x = HEMTextCollectionHorzPadding;
        frame.size.width = CGRectGetWidth([[self contentView] bounds])-(2*HEMTextCollectionHorzPadding);
        frame.size.height = CGRectGetHeight([[self contentView] bounds]);
        
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self contentView] addSubview:label];
        
        [self setTextLabel:label];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [[self contentView] setBackgroundColor:[UIColor clearColor]];
    
    [[self textLabel] setNumberOfLines:0];
    [[self textLabel] setBackgroundColor:[UIColor clearColor]];
    
    [[self separator] setBackgroundColor:[UIColor separatorColor]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self textLabel] setText:nil];
    [[self separator] setHidden:YES];
}

@end
