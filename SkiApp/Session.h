//
//  Session.h
//  SkiApp
//
//  Created by Kovács Kristóf on 12/03/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject<NSCoding>

@property long distanceInSession;
@property float speedAverage;
@property float speedMax;
@property NSString *sessionDate;

@end
