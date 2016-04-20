//
//  Session.m
//  SkiApp
//
//  Created by Kovács Kristóf on 12/03/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "Session.h"

@implementation Session

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.distanceInSession = [decoder decodeIntegerForKey:@"distanceInSession"];
    self.speedAverage = [decoder decodeIntegerForKey:@"speedAverage"];
    self.speedMax = [decoder decodeIntegerForKey:@"speedMax"];
    self.sessionDate = [decoder decodeObjectForKey:@"sessionDate"];
    self.sessionImage = [decoder decodeObjectForKey:@"sessionImage"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.distanceInSession forKey:@"distanceInSession"];
    [encoder encodeInteger:self.speedAverage forKey:@"speedAverage"];
    [encoder encodeInteger:self.speedMax forKey:@"speedMax"];
    [encoder encodeObject:self.sessionDate forKey:@"sessionDate"];
    [encoder encodeObject:self.sessionImage forKey:@"sessionImage"];
}

@end
