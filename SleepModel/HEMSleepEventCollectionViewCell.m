
#import "HEMSleepEventCollectionViewCell.h"
#import "HelloStyleKit.h"

@interface HEMSleepEventCollectionViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonHeightConstraint;
@end

@implementation HEMSleepEventCollectionViewCell

static CGFloat const HEMSleepEventSmallButtonSize = 40.f;
static CGFloat const HEMSleepEventLargeButtonSize = 40.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = HEMSleepLineWidth;
    CGFloat height = 0;
    CGFloat x = CGRectGetMidX(rect)  - width;
    CGFloat y = CGRectGetMinY(rect);
    CGFloat halfButton = ceilf(HEMSleepEventSmallButtonSize/2);
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit timelineLineColor].CGColor);
    if ([self isLastSegment] && ![self isFirstSegment]) {
        height = halfButton;
    } else if ([self isFirstSegment] && ![self isLastSegment]) {
        height = CGRectGetHeight(rect) - halfButton;
        y = halfButton;
    } else {
        height = CGRectGetHeight(rect);
    }
    CGRect contentRect = CGRectMake(x, CGRectGetMidY(rect), width, height);
    CGContextFillRect(ctx, contentRect);
}

- (void)showLargeButton:(BOOL)buttonIsLarge
{
    if (buttonIsLarge) {
        if (self.sleepEventButtonWidthConstraint.constant == HEMSleepEventLargeButtonSize)
            return;
        self.sleepEventButtonHeightConstraint.constant = HEMSleepEventLargeButtonSize;
        self.sleepEventButtonWidthConstraint.constant = HEMSleepEventLargeButtonSize;
        self.eventTypeButton.layer.cornerRadius = floorf(HEMSleepEventLargeButtonSize/2);
        self.eventTypeButton.layer.borderWidth = 2.f;
        [self updateConstraintsIfNeeded];
    } else {
        if (self.sleepEventButtonWidthConstraint.constant == HEMSleepEventSmallButtonSize)
            return;
        self.sleepEventButtonHeightConstraint.constant = HEMSleepEventSmallButtonSize;
        self.sleepEventButtonWidthConstraint.constant = HEMSleepEventSmallButtonSize;
        self.eventTypeButton.layer.cornerRadius = floorf(HEMSleepEventSmallButtonSize/2);
        self.eventTypeButton.layer.borderWidth = 1.f;
        [self updateConstraintsIfNeeded];
    }
}

@end
