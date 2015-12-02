//
//  HEMPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMPresenter : NSObject

/*
 * @discussion
 *
 * View controllers should call this method upon viewWillAppear to give the
 * presenter a chance to refresh data or anything else
 */
- (void)willAppear;

/*
 * @discussion
 *
 * View controllers should call this method upon viewDidAppear to give the
 * presenter a chance to refresh data or anything else when the attached view
 * is now visible.
 */
- (void)didAppear;

/*
 * @discussion
 *
 * View controllers should call this method upon viewWillDisappear to give the
 * presenter a chance to handle the view of the view controller disappearing
 */
- (void)willDisappear;

/*
 * @discussion
 *
 * View controllers should call this method upon viewWillDisappear to give the
 * presenter a chance to handle anything needed while the view controller is
 * not visible
 */
- (void)didDisappear;

/*
 * @discussion
 *
 * View controllers should call this method when the app becomes active again
 * after changing state of the application
 */
- (void)didComeBackFromBackground;

/*
 * @discussion
 *
 * View controllers should call this method when network connectivity is regained
 */
- (void)didGainConnectivity;

@end
