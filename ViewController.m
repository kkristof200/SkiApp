//
//  ViewController.m
//  SkiApp
//
//  Created by Kovács Kristóf on 19/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "ViewController.h"
#import "Backendless.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect viewFrame = self.view.bounds;
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, viewFrame.size.height - 50, viewFrame.size.width, 50)];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"trans1.png"] forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
}

- (IBAction)facebookLogin:(id)sender
{
   /* [backendless.userService userServiceeasyLoginWithFacebookFieldsMapping:@{@"email":@"email"},permissions:@[@"email"]
     response:^(NSNumber * response) {
         //response - NSNumber with bool Yes
         NSLog(@"StartViewController -> login: (Facebook) result = %@", response);
     } error:^(Fault *fault) {
         NSLog(@"StartViewController -> login: (FAULT) %@", fault.detail);
     }];*/
}

-(void)easyFacebookLogin {
    
   /* [backendless.userService
     easyLoginWithFacebookFieldsMapping:@{@"email":@"email"},
     permissions:@[@"email"]
     response:^(NSNumber * response) {
         //response - NSNumber with bool Yes
         NSLog(@"StartViewController -> login: (Facebook) result = %@", response);
     } error:^(Fault *fault) {
         NSLog(@"StartViewController -> login: (FAULT) %@", fault.detail);
     }];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
