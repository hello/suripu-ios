//
//  HEMSupportTopicDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 6/25/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMSupportTopicDataSource : NSObject <UITableViewDataSource>

- (BOOL)isLoaded;
- (void)reloadData:(void(^)(NSError* error))completion;
- (NSString*)topicForRowAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)displayNameForRowAtIndexPath:(NSIndexPath*)indexPath;

@end
