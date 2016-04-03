//
//  Statistics.m
//  SkiApp
//
//  Created by Kovács Kristóf on 25/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "Session.h"
#import "AllTimeSession.h"
#import "Statistics.h"

@interface Statistics ()
{
    IBOutlet UILabel *sessionDateLabel;
    IBOutlet UILabel *sessionAvgSpeedLabel;
    IBOutlet UILabel *sessionHighSpeedLabel;
    IBOutlet UILabel *sessionDistanceLabel;
    
    IBOutlet UILabel *allTimeAvgSpeedLabel;
    IBOutlet UILabel *allTimeHighSpeedLabel;
    IBOutlet UILabel *allTimeAvgDistanceLabel;
    IBOutlet UILabel *allTimeDistanceLabel;
    IBOutlet UILabel *allTimeSessionCountLabel;
    
    IBOutlet UIButton *toPreviousSession;
    IBOutlet UIButton *toNextSession;
    
    int sessionNumber;
    NSArray *sessionArray;
    Session *thisSession;
    AllTimeSession * allTimeSession;
}

@end

@implementation Statistics

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadValues];
    [self shouldWeHideButtons:NO];
}

- (void)loadValues
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SessionArray"])
    {
        sessionArray = [[NSArray alloc] init];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"SessionArray"];
        sessionArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        sessionNumber = sessionArray.count - 1;
        
        [self shouldWeHideButtons:NO];
        [self updateThisSessionLabels];
        [self updateAllTimeSessionLabels];
    }
}

- (void)updateThisSessionLabels
{
    thisSession = [sessionArray objectAtIndex:sessionNumber];
    
    sessionDateLabel.text = [NSString stringWithFormat:@"%@",thisSession.sessionDate];
    sessionAvgSpeedLabel.text = [NSString stringWithFormat:@"%f",thisSession.speedAverage];
    sessionHighSpeedLabel.text = [NSString stringWithFormat:@"%f",thisSession.speedMax];
    sessionDistanceLabel.text = [NSString stringWithFormat:@"%ld",thisSession.distanceInSession];
}

- (void)updateAllTimeSessionLabels
{
    
#warning I think this could be working instead of saving/loading "AllTimeSession" object too -------> I can also eliminate the "AllTimeSession" class
    
    /*
     for (int i = 0; i<sessionArray.count; i++)
    {
        allTimeSession.allTimeDistance += thisSession.distanceInSession;
        allTimeSession.allTimeSpeedAverage = (allTimeSession.allTimeSpeedAverage * allTimeSession.numberOfSessions + thisSession.speedAverage) / (allTimeSession.numberOfSessions + 1);
        allTimeSession.numberOfSessions++;
        allTimeSession.allTimeDistanceAverage = allTimeSession.allTimeDistance / allTimeSession.numberOfSessions;
        if(allTimeSession.allTimeSpeedMax <= thisSession.speedMax) allTimeSession.allTimeSpeedMax = thisSession.speedMax;
    }
    */
    
    
    
    allTimeSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"AllTimeSession"];
    
    allTimeAvgSpeedLabel.text = [NSString stringWithFormat:@"%f",allTimeSession.allTimeSpeedAverage];
    allTimeHighSpeedLabel.text = [NSString stringWithFormat:@"%f",allTimeSession.allTimeSpeedMax];
    allTimeAvgDistanceLabel.text = [NSString stringWithFormat:@"%f",allTimeSession.allTimeDistanceAverage];
    allTimeDistanceLabel.text = [NSString stringWithFormat:@"%ld",allTimeSession.allTimeDistance];
    allTimeSessionCountLabel.text = [NSString stringWithFormat:@"%i",allTimeSession.numberOfSessions];
}

- (IBAction)showPreviousSession:(id)sender
{
    if (sessionNumber==0)
    {
        sessionNumber = sessionArray.count - 1;
    }
    else
    {
        sessionNumber--;
    }
    [self updateThisSessionLabels];
}

- (IBAction)showNextSession:(id)sender
{
    if (sessionNumber==sessionArray.count - 1)
    {
        sessionNumber = 0;
    }
    else
    {
        sessionNumber++;
    }
    [self updateThisSessionLabels];
}

- (void)shouldWeHideButtons:(BOOL)boolValue
{
    toPreviousSession.hidden = boolValue;
    toNextSession.hidden = boolValue;
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
