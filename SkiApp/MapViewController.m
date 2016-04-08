//
//  MapView.m
//  SkiApp
//
//  Created by Kovács Kristóf on 25/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "MapViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <SKMaps/SKMaps.h>
#import "Backendless.h"

#import "Session.h"
#import "AllTimeSession.h"
#import "FriendUser.h"

//TODO: (FOC) re-structure the imports

//TODO: (FOC) add empty spaces as it follows (after commas, after ')', before & after operations)
//@interface MapView () <SKPositionerServiceDelegate, NSCoding>
@interface MapViewController () <SKPositionerServiceDelegate, NSCoding>

//TODO: (FOC) use properties
@property Session *currentSession;
@property CLLocationManager *locationManager;
@property SKPolyline *polyline;
@property SKMapView *mapView;
@property NSMutableArray *positionsArray;
@property CLLocation *lastLocation;
@property int numberOfPositionUpdatesWithSpeed;
@property NSTimer *updatePositionsTimer;
@property NSMutableArray *friendsArray;

@end

@implementation MapViewController

- (void) viewDidLoad {
    //TODO: (FOC) use same coding standards around the app. Apple uses Egyptian style
    [super viewDidLoad];
    
    //TODO: (FOC) always add a newline between calls of super and other logics
    self.positionsArray = [[NSMutableArray alloc]init];
    
    [self initValues];
    [self initMap];
    [self initButtons];
    [self initPolyLine];
    
    //TODO:(FOC) keep same type of logics in the same 'visual block'. Shortly, the new-line below is not needed
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"friendsMode"] == YES) {
        self.friendsArray = [[NSMutableArray alloc] init];
        [self updateFriends];
    }
    
    [self.locationManager startUpdatingLocation];
    NSLog(@"ViewDidLoad");
}

- (void) initValues {
#warning Initializing Session values
    
    self.currentSession = [[Session alloc]init];
    self.currentSession.distanceInSession = 0;
    self.currentSession.speedAverage = 0;
    self.currentSession.speedMax = 0;
    self.numberOfPositionUpdatesWithSpeed = 0;
    
    //Setting Date
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    self.currentSession.sessionDate = [dateFormat stringFromDate:today];
}

- (void) initMap {
    self.mapView = [[SKMapView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f,  CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) )];
    //TODO: (FOC) always add a newline between calls of addSubview and other logics. In this case, you could add it as subview at the end of the method
    self.mapView.settings.rotationEnabled = NO;
    self.mapView.settings.followUserPosition = YES;
    self.mapView.settings.headingMode = SKHeadingModeRotatingMap;
    [SKPositionerService sharedInstance].delegate = self;
    
    [self.view addSubview:self.mapView];
    
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    region.zoomLevel = 16;
    self.mapView.visibleRegion = region;
}

- (void) initButtons {
    //TODO: (FOC) add empty spaces before & after operations
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(endSession)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.frame = CGRectMake(10, self.view.bounds.size.height - 60, 50, 50);
    [button setBackgroundImage:[UIImage imageNamed:@"mapCancel.png"] forState:UIControlStateNormal];
    
    //TODO: (FOC) always add a newline between calls of addSubview and other logics
    
    [self.view addSubview:button];
}

#warning [Kristof] Saving the array, then ending the session

- (void) endSession {
    NSMutableArray *sessionArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"SessionArray"]];
    
    if (sessionArray == nil) {
        //TODO: (FOC) use tabs to allign your code, or ctrl+i, after selecting it
        //TODO: (FOC) you get the same object for key twice
        //TODO: (FOC) fix: populate 'data', if no object is received, it will be nil. Check using 'data'
        NSLog(@"NoObject");
        sessionArray = [[NSMutableArray alloc] initWithObjects:self.currentSession, nil];
        //TODO: (FOC) synchronize Writes any modifications to the persistent domains to disk and updates all unmodified persistent domains to what is on disk.
        //TODO: (FOC) here, you are only requesting objects from user defaults, not modifying them
    }
    else {
        [sessionArray addObject:self.currentSession];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:sessionArray] forKey:@"SessionArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"friendsMode"];
    [self.updatePositionsTimer invalidate];
    
    [self updateAndSaveAllTimeSession];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) updateAndSaveAllTimeSession {
    AllTimeSession *allTimeSession = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"AllTimeSession"]];
    
    if (allTimeSession == nil) {
        allTimeSession = [[AllTimeSession alloc] init];
        allTimeSession.allTimeDistance = 0;
        allTimeSession.allTimeSpeedAverage = 0;
        allTimeSession.allTimeSpeedMax = 0;
        allTimeSession.numberOfSessions = 0;
        allTimeSession.allTimeDistanceAverage = 0;
    }
    
    //TODO: (FOC) move this line above the if, check the if using 'allTimeSession'
    
#warning [ToDo] KK for Myself - Check later "allTimeSession.allTimeDistanceAverage" and "allTimeSession.numberOfSessions". Maybe not working correctly.
    
    allTimeSession.allTimeDistance += self.currentSession.distanceInSession;
    allTimeSession.allTimeSpeedAverage = (allTimeSession.allTimeSpeedAverage * allTimeSession.numberOfSessions + self.currentSession.speedAverage) / (allTimeSession.numberOfSessions + 1);
    allTimeSession.allTimeDistanceAverage = allTimeSession.allTimeDistance / (allTimeSession.numberOfSessions+1);
    allTimeSession.numberOfSessions ++;
    
    if(allTimeSession.allTimeSpeedMax <= self.currentSession.speedMax) {
        allTimeSession.allTimeSpeedMax = self.currentSession.speedMax;
    }
    
    NSLog(@"NrOfSessions : %i",allTimeSession.numberOfSessions);
    NSLog(@"allTimeDistance : %ld",allTimeSession.allTimeDistance);
    
    //TODO: (FOC) always use '{' '}' This way you avoid a lot of mistakes
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:allTimeSession] forKey:@"AllTimeSession"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //TODO: (FOC) should call synchronize since you are setting something
}

- (void)initPolyLine {
    self.polyline = [SKPolyline polyline];
    self.polyline.identifier = 3;
    self.polyline.fillColor = [UIColor redColor];
    self.polyline.lineWidth = 10;
    self.polyline.backgroundLineWidth = 2;
    self.polyline.borderDotsSize = 20;
    self.polyline.borderDotsSpacingSize = 5;
}

- (void)positionerService:(SKPositionerService *)positionerService updatedCurrentLocation:(CLLocation *)currentLocation {
#warning Updating Values
    self.currentSession.distanceInSession += [self.lastLocation distanceFromLocation:currentLocation];
    //TODO: (FOC) add empty spaces before & after operations e.g. currentLocation.speed > 0
    
    if (currentLocation.speed > 0) {
        //TODO: (FOC) add empty spaces before & after operations
        
        if (self.numberOfPositionUpdatesWithSpeed > 0) {
            self.currentSession.speedAverage *= self.numberOfPositionUpdatesWithSpeed;
        }
        
        self.currentSession.speedAverage += currentLocation.speed;
        self.numberOfPositionUpdatesWithSpeed++;
        self.currentSession.speedAverage /= self.numberOfPositionUpdatesWithSpeed;
    }
    
    if (currentLocation.speed > self.currentSession.speedMax) {
        self.currentSession.speedMax = currentLocation.speed;
    }
    
    [self.positionsArray addObject:currentLocation];
    [self updatePolyLine];
    self.lastLocation = currentLocation;
}

-(void)updatePolyLine {
    self.polyline.coordinates = self.positionsArray;
    [self.mapView addPolyline:self.polyline];
}

- (void) updateFriends {
    self.updatePositionsTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0
                                     target: self
                                   selector: @selector(updatePositions)
                                   userInfo: nil
                                    repeats: YES];
}

-(void) updatePositions {
    //Updating Current User Location
    NSString *userLatitude = [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
    NSString *userLongitude = [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
    
    NSLog(@"ItUpdates");
    [backendless.userService.currentUser updateProperties:@{@"user_latitude" : userLatitude,
                                                           @"user_longitude" : userLongitude}];
    
    [backendless.userService update:backendless.userService.currentUser];
    
    //Getting Friend User Location and ProfilePic
    
    NSString *groupId = [backendless.userService.currentUser getProperty:@"groupId"];
    BackendlessDataQuery *query = [BackendlessDataQuery query];
    query.whereClause = [NSString stringWithFormat:@"groupId = %@", groupId];
    BackendlessCollection *collection = [[backendless.persistenceService of:[BackendlessUser class]] find:query];
    NSArray *currentPage =[collection getCurrentPage];
    BackendlessUser *backendlessFriendUser;
    
    if (self.friendsArray.count < currentPage.count) {
        for (long i = self.friendsArray.count; i < currentPage.count; i++) {
            backendlessFriendUser = [currentPage objectAtIndex:currentPage.count - (i+1)];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                FriendUser *newFriend = [[FriendUser alloc] init];
                NSString *imgURL = [backendlessFriendUser getProperty:@"profilePictureURL"];
                newFriend.profilePic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
                [self.friendsArray addObject:newFriend];
                NSLog(@"ArrayCount : %lu",(unsigned long)self.friendsArray.count);
            });
        }
    }
    
    for (int i = 0; i < self.friendsArray.count; i++) {
        backendlessFriendUser = [currentPage objectAtIndex:i];
        FriendUser *friend = [self.friendsArray objectAtIndex:i];
        
        NSString *friendLatitude = [backendlessFriendUser getProperty:@"user_latitude"];
        NSString *friendLongitude = [backendlessFriendUser getProperty:@"user_longitude"];
        
        UIImageView *friendImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 50)];
        friendImage.layer.masksToBounds = YES;
        friendImage.layer.cornerRadius = 25;
        friendImage.image = friend.profilePic;
        
        SKAnnotationView *view = [[SKAnnotationView alloc] initWithView:friendImage reuseIdentifier:[NSString stringWithFormat:@"ID%i",i]];
        
        SKAnnotation *viewAnnotation = [SKAnnotation annotation];
        viewAnnotation.annotationView = view;
        viewAnnotation.identifier = i;
        viewAnnotation.location = CLLocationCoordinate2DMake([friendLatitude doubleValue], [friendLongitude doubleValue]);
        SKAnimationSettings *animationSettings = [SKAnimationSettings animationSettings];
        [self.mapView addAnnotation:viewAnnotation withAnimationSettings:animationSettings];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [self.locationManager startUpdatingLocation];
}

@end
