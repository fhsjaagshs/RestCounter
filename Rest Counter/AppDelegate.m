//
//  Rest_CounterAppDelegate.m
//  Rest Counter
//
//  Created by Nathaniel Symer on 8/18/11.
//  Copyright 2011 Nathaniel Symer. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]]autorelease];
    _window.rootViewController = [[[ViewController alloc]init]autorelease];
    [_window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [self setWindow:nil];
    [super dealloc];
}

@end
