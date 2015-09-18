//
//  HEMScreenUtils.h
//  Sense
//
//  Created by Delisa Mason on 7/13/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @return YES if device resolution matches iPhone 4S
 */
BOOL HEMIsIPhone4Family();


/**
 * @return YES if device resolution matches iPhone 5
 */
BOOL HEMIsIPhone5Family();

/**
 *  @return The bounds of the application key window
 */
CGRect HEMKeyWindowBounds();