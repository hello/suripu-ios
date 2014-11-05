
#import "HEMSleepEventCollectionViewCell.h"
#import "HelloStyleKit.h"

@interface HEMSleepEventCollectionViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonHeightConstraint;
@end

@implementation HEMSleepEventCollectionViewCell

static CGFloat const HEMSleepEventSmallButtonSize = 20.f;
static CGFloat const HEMSleepEventLargeButtonSize = 28.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat inset = HEMLinedCollectionViewCellLineOffset + HEMLinedCollectionViewCellLineWidth;
    CGFloat width = HEMSleepSegmentMinimumFillWidth;
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    if ([self isLastSegment] && ![self isFirstSegment]) {
        CGRect contentRect = CGRectMake(CGRectGetMinX(rect) + inset, CGRectGetMinY(rect), width, CGRectGetMidY(rect));
        CGContextFillRect(ctx, contentRect);
    } else if ([self isFirstSegment] && ![self isLastSegment]) {
        CGRect contentRect = CGRectMake(CGRectGetMinX(rect) + inset, CGRectGetMidY(rect), width, CGRectGetMidY(rect));
        CGContextFillRect(ctx, contentRect);
    }
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
