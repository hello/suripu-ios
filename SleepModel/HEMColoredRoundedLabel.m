
#import "HEMColoredRoundedLabel.h"

@interface HEMColoredRoundedLabel ()

@property (nonatomic, strong) CALayer* roundedLayer;
@property (nonatomic, strong) UILabel* textLabel;
@end

@implementation HEMColoredRoundedLabel

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.clipsToBounds = NO;
        _roundedLayer = [[CALayer alloc] init];
        _roundedLayer.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
        _roundedLayer.zPosition = -1;
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = [UIFont fontWithName:@"Agile-Light" size:18.f];
        [self addSubview:_textLabel];
        [self.layer insertSublayer:_roundedLayer atIndex:0];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return self.textLabel.intrinsicContentSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
    self.roundedLayer.frame = CGRectInset(self.layer.bounds, -8.f, -4.f);
    self.roundedLayer.cornerRadius = CGRectGetHeight(self.layer.frame) / 2.f + 4.f;
}

- (void)setText:(NSString*)text
{
    self.textLabel.text = text;
    [self invalidateIntrinsicContentSize];
}

- (NSString*)text
{
    return self.textLabel.text;
}

- (void)setTextColor:(UIColor*)textColor
{
    self.textLabel.textColor = textColor;
}

- (void)hideRoundedBackground
{
    self.roundedLayer.hidden = YES;
    self.textLabel.textAlignment = NSTextAlignmentRight;
}

- (void)showRoundedBackground
{
    self.roundedLayer.hidden = NO;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
}

@end
