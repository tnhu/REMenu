//
//  AppDelegate.m
//  REMenuExample
//
//  Created by Roman Efimov on 2/20/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  UIViewController *home                        = [[RootViewController alloc] init];
  home.tabBarItem                               = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:1];

  UITabBarController *dashboardTabBarController = [[UITabBarController alloc] init];
  dashboardTabBarController.viewControllers     = @[ [[UINavigationController alloc] initWithRootViewController:home] ];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = dashboardTabBarController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
