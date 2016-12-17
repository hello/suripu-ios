//
//  HEMMeetSenseView.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import "HEMMeetSenseView.h"
#import "HEMScreenUtils.h"
#import "HEMStyle.h"

@interface HEMMeetSenseView()

@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *senseImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *senseImageHeightConstraint;

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
    [super awakeFromNib];
    [self configureAppearance];
    [self updateConstraintsForScreenDifferences];
}

- (void)configureAppearance {
    [[self titleLabel] setText:NSLocalizedString(@"welcome.title", nil)];
    [[self titleLabel] setFont:[UIFont h2]];
    [[self titleLabel] setTextColor:[UIColor grey6]];
    
    [[[self videoButton] titleLabel] setFont:[UIFont buttonSmall]];
    [[self videoButton] setTitleColor:[UIColor grey4]
                             forState:UIControlStateNormal];
    
    NSString* description = NSLocalizedString(@"welcome.description", nil);
    NSDictionary* attributes = [self descriptionAttributes];
    NSAttributedString* attrDescription = [[NSAttributedString alloc] initWithString:description
                                                                          attributes:attributes];
    
    [[self descriptionLabel] setAttributedText:attrDescription];
}

- (void)updateConstraintsForScreenDifferences {
    if (HEMIsIPhone4Family()) {
        [[self senseImageTopConstraint] setConstant:31.0f];
        [[self senseImageHeightConstraint] setConstant:170.0f];
        [[self titleTopConstraint] setConstant:-5.0f];
    } else if (HEMIsIPhone5Family()) {
        [[self senseImageTopConstraint] setConstant:50.0f];
        [[self titleTopConstraint] setConstant:5.0f];
    }
}

- (NSDictionary*)descriptionAttributes {
    NSMutableParagraphStyle *style = DefaultBodyParagraphStyle();
    [style setAlignment:NSTextAlignmentCenter];
    
    return @{NSFontAttributeName : [UIFont body],
             NSForegroundColorAttributeName : [UIColor grey4],
             NSParagraphStyleAttributeName : style};
}

@end
