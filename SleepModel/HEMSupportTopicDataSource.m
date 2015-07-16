//
//  HEMSupportTopicDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 6/25/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAPISupport.h>
#import <SenseKit/SENSupportTopic.h>
#import "HEMSupportTopicDataSource.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"

@interface HEMSupportTopicDataSource()

@property (nonatomic, strong) NSArray* topics;

@end

@implementation HEMSupportTopicDataSource

- (BOOL)isLoaded {
    return [[self topics] count] > 0;
}

- (void)reloadData:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPISupport supportTopics:^(NSArray* data, NSError *error) {
        if (!error) {
            [weakSelf setTopics:data];
        }
        if (completion) {
            completion (error);
        }
    }];
}

- (NSString*)topicForRowAtIndexPath:(NSIndexPath*)indexPath {
    SENSupportTopic* topic = [self topics][[indexPath row]];
    return [topic topic];
}

- (NSString*)displayNameForRowAtIndexPath:(NSIndexPath*)indexPath {
    SENSupportTopic* topic = [self topics][[indexPath row]];
    return [topic displayName];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self topics] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard topicCellReuseIdentifier]];
}

@end
