//
//  StatisticsViewController.m
//  SkiApp
//
//  Created by Kovács Kristóf on 25/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "StatisticsViewController.h"

#import "Session.h"
#import "AllTimeSession.h"

//TODO: (FOC) apply comments from MapView.m

@interface StatisticsViewController ()


@property IBOutlet UILabel *sessionDateLabel;
@property IBOutlet UILabel *sessionAvgSpeedLabel;
@property IBOutlet UILabel *sessionHighSpeedLabel;
@property IBOutlet UILabel *sessionDistanceLabel;

@property IBOutlet UILabel *allTimeAvgSpeedLabel;
@property IBOutlet UILabel *allTimeHighSpeedLabel;
@property IBOutlet UILabel *allTimeAvgDistanceLabel;
@property IBOutlet UILabel *allTimeDistanceLabel;
@property IBOutlet UILabel *allTimeSessionCountLabel;

@property IBOutlet UIButton *toPreviousSession;
@property IBOutlet UIButton *toNextSession;

@property long sessionNumber;
@property NSArray *sessionArray;
@property Session *thisSession;
@property AllTimeSession * allTimeSession;

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadValues];
}

- (void)loadValues {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SessionArray"]) {
        self.sessionArray = [[NSArray alloc] init];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"SessionArray"];
        self.sessionArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        self.sessionNumber = self.sessionArray.count - 1;
        
        [self updateThisSessionLabels];
        [self updateAllTimeSessionLabels];
    }
}

- (void)updateThisSessionLabels
{
    self.thisSession = [self.sessionArray objectAtIndex:self.sessionNumber];
    
    self.sessionDateLabel.text = [NSString stringWithFormat:@"%@",self.thisSession.sessionDate];
    self.sessionAvgSpeedLabel.text = [NSString stringWithFormat:@"%f",self.thisSession.speedAverage];
    self.sessionHighSpeedLabel.text = [NSString stringWithFormat:@"%f",self.thisSession.speedMax];
    self.sessionDistanceLabel.text = [NSString stringWithFormat:@"%ld",self.thisSession.distanceInSession];
}

- (void)updateAllTimeSessionLabels {
    
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
    
    self.allTimeSession = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"AllTimeSession"]];
    
    self.allTimeAvgSpeedLabel.text = [NSString stringWithFormat:@"%f",self.allTimeSession.allTimeSpeedAverage];
    self.allTimeHighSpeedLabel.text = [NSString stringWithFormat:@"%f",self.allTimeSession.allTimeSpeedMax];
    self.allTimeAvgDistanceLabel.text = [NSString stringWithFormat:@"%f",self.allTimeSession.allTimeDistanceAverage];
    self.allTimeDistanceLabel.text = [NSString stringWithFormat:@"%ld",self.allTimeSession.allTimeDistance];
    self.allTimeSessionCountLabel.text = [NSString stringWithFormat:@"%i",self.allTimeSession.numberOfSessions];
}

- (IBAction)showPreviousSession:(id)sender {
    //TODO: (FOC) add empty spaces before & after operations e.g.  sessionNumber == 0
    if (self.sessionNumber == 0) {
        self.sessionNumber = self.sessionArray.count - 1;
    }
    else {
        self.sessionNumber--;
    }
    [self updateThisSessionLabels];
}

- (IBAction)showNextSession:(id)sender {
    if (self.sessionNumber == self.sessionArray.count - 1) {
        self.sessionNumber = 0;
    }
    else {
        self.sessionNumber++;
    }
    [self updateThisSessionLabels];
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
