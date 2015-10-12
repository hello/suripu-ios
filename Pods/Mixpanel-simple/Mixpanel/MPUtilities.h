//
//  MixpanelUtilities.h
//  mixpanel-simple
//
//  Created by Conrad Kramer on 10/2/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import <Foundation/Foundation.h>

extern id MPJSONSerializableObject(id object);

extern NSDictionary *MPAutomaticProperties();

extern NSURLRequest *MPURLRequestForEventData(NSData *data);
extern NSURLRequest *MPURLRequestForPeopleData(NSData *data);
