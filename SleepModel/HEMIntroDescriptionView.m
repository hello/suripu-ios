//
//  HEMIntroDescriptionView.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import "NSBundle+HEMUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

#import "HEMIntroDescriptionView.h"
#import "HEMScreenUtils.h"

@interface HEMIntroDescriptionView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation HEMIntroDescriptionView

+ (instancetype)createDescriptionViewWithFrame:(CGRect)frame
                                         title:(NSString*)title
                                andDescription:(NSString*)description {
    
    HEMIntroDescriptionView* view = [NSBundle loadNibWithOwner:self];
    [view setFrame:frame];
    [[view titleLabel] setFont:[UIFont welcomeIntroTitleFont]];
    [[view titleLabel] setTextColor:[UIColor welcomeIntroDescriptionColor]];
    [[view titleLabel] setText:title];

    NSAttributedString* attrDesc = [[NSAttributedString alloc] initWithString:description
                                                                   attributes:[self descriptionAttributes]];
    [[view descriptionLabel] setAttributedText:attrDesc];
    
    return view;
}

+ (NSDictionary*)descriptionAttributes {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    [style setLineHeightMultiple:1.2f];
    
    return @{NSFontAttributeName : [UIFont welcomeIntroDescriptionFont],
             NSForegroundColorAttributeName : [UIColor welcomeIntroDescriptionColor],
             NSParagraphStyleAttributeName : style};
}

@end
