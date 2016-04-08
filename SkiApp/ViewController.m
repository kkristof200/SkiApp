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

@end