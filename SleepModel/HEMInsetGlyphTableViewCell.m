
#import "UIFont+HEMStyle.h"

#import "HEMInsetGlyphTableViewCell.h"
#import "HelloStyleKit.h"

@interface HEMInsetGlyphTableViewCell ()
@end

@implementation HEMInsetGlyphTableViewCell

- (void)awakeFromNib {
    [[self titleLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[self titleLabel] setFont:[UIFont settingsTitleFont]];
    
    [[self detailLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[self detailLabel] setFont:[UIFont settingsTableCellDetailFont]];
    
    [[[self detailContainer] layer] setCornerRadius:CGRectGetHeight([[self detailContainer] bounds])/2];
}

@end
