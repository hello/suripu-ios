
#import "HEMInsetGlyphTableViewCell.h"

static CGFloat const insetDistance = 0.f;

@interface HEMInsetGlyphTableViewCell ()
@property (nonatomic, strong) UIView* separatorView;
@end

@implementation HEMInsetGlyphTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.separatorView) {
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(insetDistance, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame) - insetDistance, 1.f)];
        self.separatorView.backgroundColor = [UIColor colorWithWhite:0.82f alpha:0.5f];
        [self addSubview:self.separatorView];
    }
}

@end
