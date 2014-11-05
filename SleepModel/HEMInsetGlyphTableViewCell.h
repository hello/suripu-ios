
#import <UIKit/UIKit.h>

@interface HEMInsetGlyphTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView* glyphImageView;
@property (weak, nonatomic) IBOutlet UILabel* detailLabel;

- (void)showDetailBubble:(BOOL)show;

@end
