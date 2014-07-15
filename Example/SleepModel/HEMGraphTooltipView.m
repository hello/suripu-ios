
#import "HEMGraphTooltipView.h"

@interface HEMGraphTooltipView ()

@property (nonatomic, strong) UILabel* topLabel;
@property (nonatomic, strong) UILabel* bottomLabel;
@end

@implementation HEMGraphTooltipView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat labelHeight = ceil(CGRectGetHeight(frame) / 2);
        CGFloat labelWidth = ceil(CGRectGetWidth(frame));
        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
        _topLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        _topLabel.adjustsFontSizeToFitWidth = YES;
        _topLabel.numberOfLines = 1;
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topLabel];

        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelHeight, labelWidth, labelHeight)];
        _bottomLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        _bottomLabel.backgroundColor = [UIColor clearColor];
        _bottomLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        _bottomLabel.adjustsFontSizeToFitWidth = YES;
        _bottomLabel.numberOfLines = 1;
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLabel];
    }
    return self;
}

- (void)setTitleText:(NSString*)text
{
    self.topLabel.text = text;
}

- (void)setDetailText:(NSString*)text
{
    self.bottomLabel.text = text;
}

@end
