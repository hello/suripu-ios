
#import "HEMSleepDataDetailView.h"
#import "HelloStyleKit.h"

CGFloat const HEMSleepDataDetailViewPadding = 20.f;
CGFloat const HEMSleepDataDetailViewArrowDepth = 5.f;
CGFloat const HEMSleepDataDetailViewRowHeight = 30.f;

@interface HEMSleepDataDetailView ()

@property (nonatomic, strong) UILabel* sleepDepthLabel;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UILabel* eventTitleLabel;
@property (nonatomic, strong) UILabel* eventMessageLabel;
@property (nonatomic) CGFloat yOffsetForArrow;
@end

@implementation HEMSleepDataDetailView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _sleepDepthLabel = [UILabel new];
        _timeLabel = [UILabel new];
        _eventTitleLabel = [UILabel new];
        _eventTitleLabel.hidden = YES;
        _eventMessageLabel = [UILabel new];
        [self addSubview:_sleepDepthLabel];
        [self addSubview:_timeLabel];
        [self addSubview:_eventMessageLabel];
        [self addSubview:_eventTitleLabel];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clipsToBounds = YES;
        [self configureSubviews];
    }

    return self;
}

- (void)configureSubviews
{
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
    self.timeLabel.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.f].CGColor;
    self.timeLabel.layer.borderWidth = 1.f;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.sleepDepthLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
    self.sleepDepthLabel.textColor = [HelloStyleKit mediumBlueColor];
    self.eventTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    self.eventMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
    self.eventMessageLabel.numberOfLines = 0;
}

- (CGSize)intrinsicContentSize
{
    CGFloat width = MAX(CGRectGetWidth(self.eventTitleLabel.bounds) + HEMSleepDataDetailViewPadding,
                        CGRectGetWidth(self.sleepDepthLabel.bounds) + CGRectGetWidth(self.timeLabel.bounds) + HEMSleepDataDetailViewPadding);
    if ([self.eventTitleLabel isHidden]) {
        return CGSizeMake(width, HEMSleepDataDetailViewRowHeight + HEMSleepDataDetailViewPadding);
    }

    return CGSizeMake(width, 3 * HEMSleepDataDetailViewRowHeight + HEMSleepDataDetailViewPadding);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat labelSectionWidth = CGRectGetWidth(self.bounds) / 3 - HEMSleepDataDetailViewPadding;
    CGFloat sidePadding = HEMSleepDataDetailViewPadding / 2;
    CGFloat leftInset = sidePadding + 5.f;
    if ([self.eventTitleLabel isHidden]) {
        self.sleepDepthLabel.frame = CGRectMake(leftInset, sidePadding, labelSectionWidth * 2, HEMSleepDataDetailViewRowHeight);
        self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.bounds) - labelSectionWidth - sidePadding, sidePadding, labelSectionWidth, HEMSleepDataDetailViewRowHeight);
    } else {
        self.sleepDepthLabel.frame = CGRectMake(leftInset, sidePadding, labelSectionWidth * 2, HEMSleepDataDetailViewRowHeight);
        self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.bounds) - labelSectionWidth - sidePadding, sidePadding, labelSectionWidth, HEMSleepDataDetailViewRowHeight);
        self.eventTitleLabel.frame = CGRectMake(leftInset, sidePadding + HEMSleepDataDetailViewRowHeight, labelSectionWidth * 3, HEMSleepDataDetailViewRowHeight);
        self.eventMessageLabel.frame = CGRectMake(leftInset, sidePadding + HEMSleepDataDetailViewRowHeight * 2, labelSectionWidth * 3, HEMSleepDataDetailViewRowHeight);
    }
    self.timeLabel.layer.cornerRadius = CGRectGetHeight(self.timeLabel.bounds) / 2;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGRect bubble = CGRectMake(CGRectGetMinX(rect) + HEMSleepDataDetailViewArrowDepth, CGRectGetMinY(rect), CGRectGetWidth(rect) - HEMSleepDataDetailViewArrowDepth, CGRectGetHeight(rect));
    UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRoundedRect:bubble cornerRadius:5.f];
    [roundedRect fillWithBlendMode:kCGBlendModeNormal alpha:1.0f];
    CGContextMoveToPoint(ctx, 0, self.yOffsetForArrow);
    CGContextAddLineToPoint(ctx, HEMSleepDataDetailViewArrowDepth, self.yOffsetForArrow - (HEMSleepDataDetailViewArrowDepth*1.5f));
    CGContextAddLineToPoint(ctx, HEMSleepDataDetailViewArrowDepth * 2, self.yOffsetForArrow);
    CGContextAddLineToPoint(ctx, HEMSleepDataDetailViewArrowDepth, self.yOffsetForArrow + (HEMSleepDataDetailViewArrowDepth*1.5));
    CGContextAddLineToPoint(ctx, 0, self.yOffsetForArrow);
    CGContextFillPath(ctx);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setOffsetForArrow:(CGFloat)yOffset
{
    self.yOffsetForArrow = yOffset;
    [self setNeedsDisplay];
}

- (void)setTimeLabelText:(NSString*)timeText
{
    self.timeLabel.text = timeText;
}

- (void)setSleepDepthLabelText:(NSString*)sleepDepthText
{
    self.sleepDepthLabel.text = sleepDepthText;
}

- (void)setEventWithTitle:(NSString*)title message:(NSString*)message
{
    self.eventTitleLabel.text = title;
    self.eventMessageLabel.text = message;
    self.eventMessageLabel.hidden = self.eventTitleLabel.hidden = !title && !message;
    [self setNeedsLayout];
}

@end
