//
//  MapView.m
//  SkiApp
//
//  Created by Kovács Kristóf on 25/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "MapView.h"
#import <CoreLocation/CoreLocation.h>
#import <SKMaps/SKMaps.h>
#import "Session.h"
#import "ViewController.h"
#import "AllTimeSession.h"

@interface MapView ()<SKPositionerServiceDelegate,NSCoding>
{
    CLLocationManager *locationManager;
    SKPolyline *polyline;
    SKMapView *mapView;
    NSMutableArray *positionsArray;
    CLLocation *lastLocation;
    Session *newSession;
    int numberOfPositionUpdatesWithSpeed;
}

@end

@implementation MapView

- (void)viewDidLoad {
    [super viewDidLoad];
    positionsArray = [[NSMutableArray alloc]init];
    
    [self initValues];
    [self initMap];
    [self initButtons];
    
    [self initPolyLine];
    
    [locationManager startUpdatingLocation];
    NSLog(@"ViewDidLoad");
}

- (void)initValues
{
#warning Initializing Session values
    
    newSession = [[Session alloc]init];
    newSession.distanceInSession = 0;
    newSession.speedAverage = 0;
    newSession.speedMax = 0;
    numberOfPositionUpdatesWithSpeed = 0;
    
    //Setting Date
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    newSession.sessionDate = [dateFormat stringFromDate:today];
}

- (void)initMap
{
    mapView = [[SKMapView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f,  CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) )];
    [self.view addSubview:mapView];
    mapView.settings.rotationEnabled = NO;
    mapView.settings.followUserPosition = YES;
    mapView.settings.headingMode = SKHeadingModeRotatingMap;
    [SKPositionerService sharedInstance].delegate = self;
}

- (void)initButtons
{
    for (int i = 0; i<2; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (i==0)
        {
            [button addTarget:self
                       action:@selector(showGroupDetails)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Group" forState:UIControlStateNormal];
            button.frame = CGRectMake(10, (CGRectGetHeight(self.view.frame)-60), 50, 50);
        }
        else
        {
            [button addTarget:self
                       action:@selector(endSession)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"End Session" forState:UIControlStateNormal];
            button.frame = CGRectMake(10, 60, 100, 50);
        }
        [button setBackgroundColor:[UIColor redColor]];
        [self.view addSubview:button];
    }
}

- (void)showGroupDetails
{
    
    
}

#warning [Kristof] Saving the array, then ending the session

- (void)endSession
{
    NSMutableArray *sessionArray;
    NSData *data;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SessionArray"])
    {
    data = [[NSUserDefaults standardUserDefaults] objectForKey:@"SessionArray"];
    sessionArray = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [sessionArray addObject:newSession];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:sessionArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"SessionArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateAndSaveAllTimeSession];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) updateAndSaveAllTimeSession
{
    AllTimeSession *allTimeSession;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"AllTimeSession"])
    {
        allTimeSession.allTimeDistance = 0;
        allTimeSession.allTimeSpeedAverage = 0;
        allTimeSession.allTimeSpeedMax = 0;
        allTimeSession.numberOfSessions = 0;
        allTimeSession.allTimeDistanceAverage = 0;
        
        [[NSUserDefaults standardUserDefaults] setObject:allTimeSession forKey:@"AllTimeSession"];
    }
    
    allTimeSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"AllTimeSession"];
    
#warning [ToDo] KK for Myself - Check later "allTimeSession.allTimeDistanceAverage" and "allTimeSession.numberOfSessions". Maybe not working correctly.
    
    allTimeSession.allTimeDistance += newSession.distanceInSession;
    allTimeSession.allTimeSpeedAverage = (allTimeSession.allTimeSpeedAverage * allTimeSession.numberOfSessions + newSession.speedAverage) / (allTimeSession.numberOfSessions + 1);
    allTimeSession.allTimeDistanceAverage = allTimeSession.allTimeDistance / (allTimeSession.numberOfSessions+1);
    allTimeSession.numberOfSessions += 1;
    if(allTimeSession.allTimeSpeedMax <= newSession.speedMax) allTimeSession.allTimeSpeedMax = newSession.speedMax;
    
    [[NSUserDefaults standardUserDefaults] setObject:allTimeSession forKey:@"AllTimeSession"];
}

- (void)initPolyLine
{
    polyline = [SKPolyline polyline];
    polyline.identifier = 3;
    polyline.fillColor = [UIColor redColor];
    polyline.lineWidth = 10;
    polyline.backgroundLineWidth = 2;
    polyline.borderDotsSize = 20;
    polyline.borderDotsSpacingSize = 5;
}

- (void)positionerService:(SKPositionerService *)positionerService updatedCurrentLocation:(CLLocation *)currentLocation
{
    NSLog(@"Distance in meters: %f", [lastLocation distanceFromLocation:currentLocation]);
    NSLog(@"Speed: %f", currentLocation.speed);
    
#warning Updating Values
    newSession.distanceInSession += [lastLocation distanceFromLocation:currentLocation];
    if (currentLocation.speed>0)
    {
        if (numberOfPositionUpdatesWithSpeed>0)
        {
            newSession.speedAverage *= numberOfPositionUpdatesWithSpeed;
        }
        newSession.speedAverage += currentLocation.speed;
        numberOfPositionUpdatesWithSpeed++;
        newSession.speedAverage /= numberOfPositionUpdatesWithSpeed;
    }
    
    if (currentLocation.speed>newSession.speedMax)
    {
        newSession.speedMax = currentLocation.speed;
    }
    
    [positionsArray addObject:currentLocation];
    [self updatePolyLine];
    lastLocation = currentLocation;
}

-(void)updatePolyLine
{
    polyline.coordinates = positionsArray;
    [mapView addPolyline:polyline];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
