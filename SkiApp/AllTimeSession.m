//
//  AllTimeSession.m
//  SkiApp
//
//  Created by Kovács Kristóf on 31/03/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "AllTimeSession.h"

@implementation AllTimeSession

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.allTimeDistance = [decoder decodeIntegerForKey:@"allTimeDistance"];
    self.allTimeSpeedAverage = [decoder decodeIntegerForKey:@"allTimeSpeedAverage"];
    self.allTimeDistanceAverage = [decoder decodeIntegerForKey:@"allTimeDistanceAverage"];
    self.allTimeSpeedMax = [decoder decodeIntegerForKey:@"allTimeSpeedMax"];
    self.numberOfSessions = [decoder decodeIntForKey:@"numberOfSessions"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.allTimeDistance forKey:@"allTimeDistance"];
    [encoder encodeInteger:self.allTimeSpeedAverage forKey:@"allTimeSpeedAverage"];
    [encoder encodeInteger:self.allTimeDistanceAverage forKey:@"allTimeDistanceAverage"];
    [encoder encodeInteger:self.allTimeSpeedMax forKey:@"allTimeSpeedMax"];
    [encoder encodeInt:self.numberOfSessions forKey:@"numberOfSessions"];
}

@end
