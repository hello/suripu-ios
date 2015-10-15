//
//  HEMMeetSenseView.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMMeetSenseView.h"

@interface HEMMeetSenseView()

@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation HEMMeetSenseView

+ (instancetype)createMeetSenseViewWithFrame:(CGRect)frame {
    
    NSString* nibName = NSStringFromClass([self class]);
    NSArray* contents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    HEMMeetSenseView* view = [contents firstObject];
    [view setFrame:frame];
    
    return view;
}

- (void)awakeFromNib {
    [self configureAppearance];
}

- (void)configureAppearance {
    [[self titleLabel] setText:NSLocalizedString(@"welcome.title", nil)];
    [[self titleLabel] setFont:[UIFont welcomeTitleFont]];
    [[self titleLabel] setTextColor:[UIColor welcomeTitleColor]];
    
    [[[self videoButton] titleLabel] setFont:[UIFont welcomeVideoButtonFont]];
    [[self videoButton] setTitleColor:[UIColor welcomeVideoButtonColor]
                             forState:UIControlStateNormal];
    
    NSString* description = NSLocalizedString(@"welcome.description", nil);
    NSDictionary* attributes = [self descriptionAttributes];
    NSAttributedString* attrDescription = [[NSAttributedString alloc] initWithString:description
                                                                          attributes:attributes];
    
    [[self descriptionLabel] setAttributedText:attrDescription];
}

- (NSDictionary*)descriptionAttributes {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineHeightMultiple:1.2f];
    
    return @{NSFontAttributeName : [UIFont welcomeDescriptionFont],
             NSForegroundColorAttributeName : [UIColor welcomeDescriptionColor],
             NSParagraphStyleAttributeName : style};
}

@end
