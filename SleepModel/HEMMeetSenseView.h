//
//  HEMMeetSenseView.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMMeetSenseView : UIView

@property (weak, nonatomic) IBOutlet UIButton *videoButton;

/**
 * Create a new instance of HEMMeetSenseView with the given frame
 * @param frame: the frame for the view
 * @return a new instance of the view
 */
+ (nonnull instancetype)createMeetSenseViewWithFrame:(CGRect)frame;

@end
