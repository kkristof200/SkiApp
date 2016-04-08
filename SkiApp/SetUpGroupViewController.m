//
//  SetUpGroupViewController.m
//  SkiApp
//
//  Created by Kovács Kristóf on 07/04/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#define facebookErrorTitle @"User not Logged in"
#define facebookErrormessage @"Please Log in to Facebook to proceed"
#define wrongIdErrorTitle @"No such Group Id"
#define wrongIdErrorMessage @"Please If you've entered Group Id correnctly"

#import "SetUpGroupViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Backendless.h"

#import "MapViewController.h"

@interface SetUpGroupViewController ()

@property (strong, nonatomic) BackendlessUser *currentUser;
@property NSString *groupId;
@property NSString *errorText;
@property NSString *errorTitle;

@property (strong, nonatomic) IBOutlet UITextField *groupIdTextField;

@end

@implementation SetUpGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (IBAction)Back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)CreateGroup:(id)sender {
    
    [self checkIfTextFieldShouldReturn];
    
    if ([FBSDKAccessToken currentAccessToken] && (backendless.userService.isStayLoggedIn)) {
        NSLog(@"Logged in to FB & Backendless");
        
        self.currentUser = backendless.userService.currentUser;
        
        NSString *facebookId = [self.currentUser getProperty:@"facebookId"];
        NSLog(@"facebookId : %@",facebookId);
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSString *profilePictureURL = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                [self.currentUser updateProperties:@{@"profilePictureURL" : profilePictureURL}];
            }
            
        }];
        
        [self.currentUser updateProperties:@{@"groupId" : facebookId}];
        
        [backendless.userService update:self.currentUser];
        
        BackendlessCollection *collection = [[backendless.persistenceService of:[BackendlessUser class]] find];
        NSArray *currentPage =[collection getCurrentPage];
        BackendlessUser *updatedUser;
        
        for (int i = 0; i < currentPage.count; i++) {
            updatedUser = [currentPage objectAtIndex:i];
            
            NSLog(@"groupId of User nr %i : %@", i, [updatedUser getProperty:@"groupId"]);
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"friendsMode"];
        
        MapViewController *MVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MVC"];
        [self presentViewController:MVC animated:YES completion:nil];
    }
    else {
        NSLog(@"Not logged in");
        
        [self showAlertWithTitle:facebookErrorTitle andWithMessage:facebookErrormessage shouldDismissVC:YES];
    }
}

- (IBAction)JoinGroup:(id)sender {
    
    [self checkIfTextFieldShouldReturn];
    
    if ([FBSDKAccessToken currentAccessToken] && (backendless.userService.isStayLoggedIn)) {
        self.currentUser = backendless.userService.currentUser;
        
        NSString *groupIdOfFriend = self.groupIdTextField.text;
        
        if ([groupIdOfFriend  isEqual: @""]) {
            [self showAlertWithTitle:wrongIdErrorTitle andWithMessage:wrongIdErrorMessage shouldDismissVC:NO];
        }
        else {
            BackendlessDataQuery *query = [BackendlessDataQuery query];
            query.whereClause = [NSString stringWithFormat:@"groupId = %@", groupIdOfFriend];
            BackendlessCollection *collection = [[backendless.persistenceService of:[BackendlessUser class]] find:query];
            NSArray *currentPage =[collection getCurrentPage];
            
            if (currentPage.count == 0) {
                [self showAlertWithTitle:wrongIdErrorTitle andWithMessage:wrongIdErrorMessage shouldDismissVC:NO];
            }
            else {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        NSString *profilePictureURL = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                        [self.currentUser updateProperties:@{@"profilePictureURL" : profilePictureURL}];
                    }
                    
                }];
                
                [self.currentUser updateProperties:@{@"groupId" : groupIdOfFriend}];
                
                [backendless.userService update:self.currentUser];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"friendsMode"];
                
                MapViewController *MVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MVC"];
                [self presentViewController:MVC animated:YES completion:nil];
            }
        }
    }
    else {
        NSLog(@"Not logged in");
        
        [self showAlertWithTitle:facebookErrorTitle andWithMessage:facebookErrormessage shouldDismissVC:YES];
    }
        /*
        BackendlessDataQuery *query = [BackendlessDataQuery query];
            query.whereClause = [NSString stringWithFormat:@"groupId = %@", facebookId];
            BackendlessCollection *collection = [[backendless.persistenceService of:[BackendlessUser class]] find:query];
            NSArray *currentPage =[collection getCurrentPage];
            BackendlessUser *updatedUser;
            
            for (int i = 0; i < currentPage.count; i++) {
                updatedUser = [currentPage objectAtIndex:i];
                NSLog(@"User nr %i : %@", i, [updatedUser getName]);
            }
    */
}

- (void) checkIfTextFieldShouldReturn {
    if (self.groupIdTextField) {
        [self textFieldShouldReturn:self.groupIdTextField];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        [self textFieldShouldReturn:self.groupIdTextField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [(UITextField*)textField resignFirstResponder];
    return YES;
}

- (void) showAlertWithTitle:(NSString *) title andWithMessage: (NSString *) message shouldDismissVC: (BOOL) dismissVC {
    
    UIAlertController * alert =   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             if (dismissVC) {
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
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
