//
//  ViewController.m
//  asdad
//
//  Created by artur on 6/18/16.
//  Copyright © 2016 Artur Mkrtchyan. All rights reserved.
//

#import "ViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface ViewController () <GIDSignInDelegate, GIDSignInUIDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self signIn];
    });
}

- (void)signIn
{
    [GIDSignIn sharedInstance].clientID = @"896496566202-n04a4prg15jp3b20dghu8semsl7vpcpr.apps.googleusercontent.com";
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES; //Setting the flag will add "email" and "profile" to scopes.
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate   = self;

    NSArray *additionalScopes = @[@"https://www.googleapis.com/auth/contacts.readonly",
                                  @"https://www.googleapis.com/auth/plus.login",
                                  @"https://www.googleapis.com/auth/plus.me"];
    [GIDSignIn sharedInstance].scopes = [[GIDSignIn sharedInstance].scopes arrayByAddingObjectsFromArray:additionalScopes];
    
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - GoogleSignIn delegates
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        //TODO: handle error
    } else {
        NSString *userId = user.userID;
        NSString *fullName = user.profile.name;
        NSString *email = user.profile.email;
        NSURL *imageURL = [user.profile imageURLWithDimension:1024];
        NSString *accessToken = user.authentication.accessToken;
        NSLog(@"%@, %@ : %@", userId,  fullName, email);
        
        //Fetching connections:
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSString *path = [@"https://www.googleapis.com/plus/v1/people/me/people/visible?access_token=" stringByAppendingString:accessToken];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSLog(@"%@", dic);
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                _avatarImageView.image = image;
            });
        });
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
