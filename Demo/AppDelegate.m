//
//  AppDelegate.m
//  Demo
//
//  Created by Kolyvan on 22.04.15.
//  Copyright (c) 2015 Konstantin Bukreev. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *vc = [ViewController new];
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = naVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
