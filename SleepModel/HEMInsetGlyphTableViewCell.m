
#import "HEMInsetGlyphTableViewCell.h"
#import "HelloStyleKit.h"

@interface HEMInsetGlyphTableViewCell ()
@end

@implementation HEMInsetGlyphTableViewCell

- (void)awakeFromNib {
    [[self titleLabel] setTextColor:[HelloStyleKit settingsTextColor]];
    [[self detailLabel] setTextColor:[HelloStyleKit settingsTextColor]];
    [[self descriptionLabel] setTextColor:[HelloStyleKit settingsTextColor]];
}

@end
