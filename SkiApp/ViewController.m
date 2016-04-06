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
//TODO: (FOC) apply comments from MapView.m
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO: (FOC) always add a newline between calls of super and other logics
    CGRect viewFrame = self.view.bounds;
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, viewFrame.size.height - 50, viewFrame.size.width, 50)];
    loginButton.readPermissions = @[@"email"];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"trans1.png"] forState:UIControlStateNormal];
    //TODO: (FOC) always add a newline between calls of addSubview and other logics
    
    [self.view addSubview:loginButton];
}

@end