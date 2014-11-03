
#import "HEMInsetGlyphTableViewCell.h"
#import "HelloStyleKit.h"

@interface HEMInsetGlyphTableViewCell ()
@end

@implementation HEMInsetGlyphTableViewCell

- (void)awakeFromNib {
    [[self titleLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[self detailLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[self descriptionLabel] setTextColor:[HelloStyleKit backViewTextColor]];
}

@end
