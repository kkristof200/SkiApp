//
//  ViewController.m
//  SkiApp
//
//  Created by Kovács Kristóf on 19/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "ViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Backendless.h"
#import "GameCenterManager.h"

#import "AllTimeSession.h"

//TODO: (FOC) apply comments from MapView.m
@interface ViewController ()

@property IBOutlet UIImageView *bgImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO: (FOC) always add a newline between calls of super and other logics
    //TODO: (FOC) move the login button setup logic to another method e.g. setupLoginButton
    
    [self setupFBLoginButton];
    [self setRandomBgImage];
    
    //TODO: (FOC) always add a newline between calls of addSubview and other logics
    //TODO: (FOC) move this also to setupLoginButton method
}

- (void) setupFBLoginButton {
    CGRect viewFrame = self.view.bounds;
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, viewFrame.size.height - 50, viewFrame.size.width, 50)];
    loginButton.readPermissions = @[@"email"];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"trans1.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:loginButton];
}

- (void) setRandomBgImage {
    int i = arc4random() % 5; //TODO: (FOC) add empty spaces before & after operators
    self.bgImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg%i",i]];
}

- (IBAction)showLeaderBoard:(id)sender {
    [self uploadAchievementsAndHighScore];
    
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:self withLeaderboard:@"kovacsKristof.skiApp.mainLeaderBoard"];
}

- (IBAction)showAchievements:(id)sender {
    [self uploadAchievementsAndHighScore];
    
    [[GameCenterManager sharedManager] presentAchievementsOnViewController:self];
}

- (void) uploadAchievementsAndHighScore {
    AllTimeSession *allTimeSession;
    float highScore;
    
    allTimeSession = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"AllTimeSession"]];
    
    highScore = allTimeSession.allTimeDistance/1000;
    
    //Leaderboard
    
    [[GameCenterManager sharedManager] saveAndReportScore:highScore leaderboard:@"kovacsKristof.skiApp.mainLeaderBoard" sortOrder:GameCenterSortOrderHighToLow];
    
    //Achivements
    
    if ([[GameCenterManager sharedManager] progressForAchievement:@"newbie"] != 100) {
        
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"newbie" percentComplete:100 shouldDisplayNotification:YES];
    }
    
    if (([[GameCenterManager sharedManager] progressForAchievement:@"100km"] != 100) && ([[GameCenterManager sharedManager] progressForAchievement:@"100km"] < (int)highScore)) {
        
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"100km" percentComplete:highScore shouldDisplayNotification:YES];
    }
}

@end