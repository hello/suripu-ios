//
//  HEMPickerView.h
//  Sense
//
//  Created by Jimmy Lu on 12/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HEMPickerSelectionCompletion)(void);

@interface HEMPickerView : UIPickerView

- (void)selectRow:(NSInteger)row
      inComponent:(NSInteger)component
       completion:(HEMPickerSelectionCompletion)completion;

@end
