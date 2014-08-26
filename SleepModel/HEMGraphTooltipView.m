
#import "HEMGraphTooltipView.h"
#import "HelloStyleKit.h"

@interface HEMGraphTooltipView ()

@property (nonatomic, strong) UILabel* topLabel;
@property (nonatomic, strong) UILabel* bottomLabel;
@end

@implementation HEMGraphTooltipView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat labelHeight = 14;
        CGFloat labelWidth = ceil(CGRectGetWidth(frame));
        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, labelWidth, labelHeight)];
        _topLabel.font = [UIFont fontWithName:@"Agile-Medium" size:12];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textColor = [UIColor whiteColor];
        _topLabel.adjustsFontSizeToFitWidth = YES;
        _topLabel.numberOfLines = 1;
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topLabel];

        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelHeight, labelWidth, labelHeight)];
        _bottomLabel.font = [UIFont fontWithName:@"Agile-Thin" size:12];
        _bottomLabel.backgroundColor = [UIColor clearColor];
        _bottomLabel.textColor = [UIColor whiteColor];
        _bottomLabel.adjustsFontSizeToFitWidth = YES;
        _bottomLabel.numberOfLines = 1;
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLabel];
        self.backgroundColor = [HelloStyleKit mediumBlueColor];
        self.layer.cornerRadius = 6.f;
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
