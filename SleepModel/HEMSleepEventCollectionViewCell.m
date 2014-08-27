
#import "HEMSleepEventCollectionViewCell.h"

@implementation HEMSleepEventCollectionViewCell

- (void)awakeFromNib
{
    self.expanded = NO;
}

- (void)setExpanded:(BOOL)expanded
{
    self.eventMessageLabel.hidden = !(_expanded = expanded);
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

@end
