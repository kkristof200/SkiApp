//
//  StatisticsViewController.m
//  SkiApp
//
//  Created by Kovács Kristóf on 25/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#define facebookErrorTitle @"No Facebook Account detected"
#define facebookErrormessage @"Please go to Settings -> Facebook and connect your Facebook account!"
#define twitterErrorTitle @"No Twitter Account detected"
#define twitterErrormessage @"Please go to Settings -> Twitter and connect your Twitter account!"

#import "StatisticsViewController.h"

#import <Social/Social.h>

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
    self.sessionAvgSpeedLabel.text = [NSString stringWithFormat:@"%.2f km/h",self.thisSession.speedAverage * 3.6];
    self.sessionHighSpeedLabel.text = [NSString stringWithFormat:@"%.2f km/h",self.thisSession.speedMax * 3.6];
    self.sessionDistanceLabel.text = [NSString stringWithFormat:@"%ld km",self.thisSession.distanceInSession / 1000];
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
    
    self.allTimeAvgSpeedLabel.text = [NSString stringWithFormat:@"%.2f km/h",self.allTimeSession.allTimeSpeedAverage * 3.6];
    self.allTimeHighSpeedLabel.text = [NSString stringWithFormat:@"%.2f km/h",self.allTimeSession.allTimeSpeedMax * 3.6];
    self.allTimeAvgDistanceLabel.text = [NSString stringWithFormat:@"%.2f km",self.allTimeSession.allTimeDistanceAverage / 1000];
    self.allTimeDistanceLabel.text = [NSString stringWithFormat:@"%ld km",self.allTimeSession.allTimeDistance / 1000];
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

- (UIImage*)captureView:(UIView *)view
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (IBAction)shareFacebook:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller addImage:[self captureView:self.view]];
        [self presentViewController:controller animated:YES completion:Nil];
    }
    else
    {
        [self showAlertWithTitle:facebookErrorTitle andWithMessage:facebookErrormessage];
    }
}
- (IBAction)shareTwitter:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *controller = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:@"Check out my stats!"];
        [controller addImage:[self captureView:self.view]];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        [self showAlertWithTitle:twitterErrorTitle andWithMessage:twitterErrormessage];
    }
}

- (void) showAlertWithTitle:(NSString *) title andWithMessage: (NSString *) message {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Settings"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)BackToMainVC:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
