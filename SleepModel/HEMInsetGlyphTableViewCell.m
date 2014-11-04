
#import "UIFont+HEMStyle.h"

#import "HEMInsetGlyphTableViewCell.h"
#import "HelloStyleKit.h"

@interface HEMInsetGlyphTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView* detailContainer;

@end

@implementation HEMInsetGlyphTableViewCell

- (void)awakeFromNib {
    [[self titleLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[self titleLabel] setFont:[UIFont settingsTitleFont]];
    
    [[self detailLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[self detailLabel] setFont:[UIFont settingsTableCellDetailFont]];
    
    CGFloat cornerRadius = CGRectGetHeight([[self detailContainer] bounds])/2;
    [[[self detailContainer] layer] setCornerRadius:cornerRadius];
    [[[self detailContainer] layer] setShadowOpacity:1.0f];
    [[[self detailContainer] layer] setShadowOffset:CGSizeMake(0.0f, 0.5f)];
    [[[self detailContainer] layer] setShadowRadius:1.0f];
    [[[self detailContainer] layer] setShadowColor:[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
    [[[self detailContainer] layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[[self detailContainer] bounds]
                                                                              cornerRadius:cornerRadius] CGPath]];
}

- (void)showDetailBubble:(BOOL)show {
    if (show) {
        [[self detailContainer] setBackgroundColor:[UIColor whiteColor]];
        [[[self detailContainer] layer] setShadowOpacity:1.0f];
    } else {
        [[self detailContainer] setBackgroundColor:[UIColor clearColor]];
        [[[self detailContainer] layer] setShadowOpacity:0.0f];
    }
    
}

@end
